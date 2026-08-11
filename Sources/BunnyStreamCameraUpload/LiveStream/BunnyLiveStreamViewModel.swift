import AVFoundation
import BunnyStreamAPI
import Combine
import SwiftUI
import HaishinKit
import VideoToolbox

final class BunnyStreamCameraUploadViewModel: ObservableObject {
  private var streamConfig: StreamConfig
  private var retryCount: Int = 0
  private let maxRetryCount: Int = 5
  /// Whether the current reconnect attempt targets the backup ingest. Alternates
  /// primary <-> backup on each retry so a dead primary fails over to backup quickly.
  private var usingBackup: Bool = false
  /// In-flight reconnect (delay + connect). Non-nil while a retry is scheduled, which
  /// also de-duplicates the two failure sources (.rtmpStatus and .ioError).
  private var reconnectTask: Task<Void, Never>?
  /// Proactive failover: whether the ingest we're currently publishing to has reported live at
  /// least once. Guards against acting on the startup window where the ingest hasn't seen data yet.
  private var currentIngestConfirmedLive: Bool = false
  /// Consecutive `/status` polls reporting the current ingest as not-live after it was confirmed live.
  private var consecutiveIngestMisses: Int = 0
  /// How many consecutive not-live polls (≈5s each) trigger a proactive failover to the other ingest.
  private let proactiveFailoverMissThreshold: Int = 2
  private var notifications = NotificationCenter.default
  private var rtmpConnection = RTMPConnection()
  private var subscriptions = Set<AnyCancellable>()
  private var elapsedTimePublisher: AnyCancellable?
  private var countdownTimerPublisher: AnyCancellable?
  private var startStreamingTime: Date?
  private var totalCountdownDuration: Int = 4
  private var videoId: String?
  private let videoCreator: VideoCreator?

  /// Live stream operations in domain terms. Built lazily because `streamConfig.accessKey`
  /// is what identifies the account, and it's set at init.
  private lazy var liveStreams: DefaultLiveStreamRepository = {
    DefaultLiveStreamRepository(bunnyStreamAPI: BunnyStreamAPI(accessKey: streamConfig.accessKey))
  }()

  /// The public handle, when the host app supplied one. Everything user-visible is mirrored
  /// onto it so callers can drive and observe the broadcast from outside the view.
  weak var broadcastController: BunnyBroadcastController?

  @Published var snackbarMessage: String? = nil {
    didSet {
      guard let message = snackbarMessage, message != oldValue else { return }
      broadcastController?.emit(.failed(message: message))
    }
  }
  @Published var countdownProgress: CGFloat = 1.0
  @Published var state: StreamState = .notStreaming {
    didSet {
      guard state != oldValue else { return }
      broadcastController?.update(state: state.publicState)
      switch state {
      case .preparing:   broadcastController?.emit(.preparing)
      case .liveStreaming: broadcastController?.emit(.started)
      case .notStreaming:  broadcastController?.emit(.stopped)
      }
    }
  }
  @Published var isMuted = false {
    didSet { broadcastController?.update(isMuted: isMuted) }
  }
  @Published var isCreatingVideo = false
  @Published var rtmpStream: RTMPStream
  @Published var currentPosition: AVCaptureDevice.Position = .back {
    didSet { broadcastController?.update(cameraPosition: currentPosition == .front ? .front : .back) }
  }
  @Published var elapsedTime: String? {
    didSet { broadcastController?.update(elapsedTime: elapsedTime) }
  }
  @Published var primaryLive: Bool? = nil
  @Published var backupLive: Bool? = nil

  private var ingestStatusTask: Task<Void, Never>?

  init(streamConfig: StreamConfig, videoCreator: VideoCreator? = nil) {
    self.streamConfig = streamConfig
    self.rtmpStream = RTMPStream(connection: rtmpConnection)
    self.videoCreator = videoCreator
  }
}

// MARK: - Stream
extension BunnyStreamCameraUploadViewModel {
  func configureStream() {
    setupAudioSession()
    
#if os(iOS)
    if let orientation = DeviceUtil.videoOrientation(by: UIDevice.current.orientation) {
      rtmpStream.videoOrientation = orientation
    }

    let quality = streamConfig.quality
    rtmpStream.frameRate = quality.frameRate
    rtmpStream.sessionPreset = quality.resolution.sessionPreset
    rtmpStream.videoSettings.videoSize = quality.resolution.videoSize
    rtmpStream.videoSettings.bitRate = quality.videoBitrate
    // High profile lifts the Baseline-3.1 ceiling (which caps at 720p30) so 1080p/60fps encode correctly.
    rtmpStream.videoSettings.profileLevel = kVTProfileLevel_H264_High_AutoLevel as String
    rtmpStream.audioSettings.bitRate = quality.audioBitrate
    // Single-camera broadcast: MultiCam sessions are capped well below 1080p on most devices,
    // so keep it off to unlock the full-resolution capture formats. Camera flips reuse channel 0.
    rtmpStream.isMultiCamSessionEnabled = false
    
    notifications.publisher(for: UIDevice.orientationDidChangeNotification)
      .sink { [rtmpStream] _ in
        guard let orientation = DeviceUtil.videoOrientation(by: UIDevice.current.orientation) else { return }
        rtmpStream.videoOrientation = orientation
      }
      .store(in: &subscriptions)
#endif
  }
  
  func registerForPublishEvent() {
    rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio))
    rtmpStream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition), channel: 0)
  }
  
  func unregisterForPublishEvent() {
    rtmpStream.close()
  }
  
  func startPublish() {
    setIsIdleTimerDisabled(true)
    retryCount = 0
    usingBackup = false
    currentIngestConfirmedLive = false
    consecutiveIngestMisses = 0
    reconnectTask?.cancel()
    reconnectTask = nil
    startStreamingTimer()
    rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
    rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    rtmpConnection.connect(streamConfig.uri)
  }
  
  func stopPublish() {
    videoId = nil
    setIsIdleTimerDisabled(false)
    state = .notStreaming
    reconnectTask?.cancel()
    reconnectTask = nil
    stopStreamingTimer()
    stopIngestStatusPolling()
    rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
    rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    Task { [weak self] in
      self?.rtmpStream.close()
      self?.rtmpConnection.close()
      do {
        try await self?.completeStream()
      } catch let error as LifecycleError {
        await MainActor.run { self?.snackbarMessage = error.errorDescription }
      } catch {
        await MainActor.run { self?.snackbarMessage = "Failed to stop the live stream cleanly." }
      }
    }
  }
}

// MARK: - Controls
extension BunnyStreamCameraUploadViewModel {
  func startStreamingCountdown() {
    Task {
      do {
        // Activation is best-effort: surface any backend error but DON'T abort the broadcast.
        // RTMP publishing can still succeed, and aborting here left the user stuck on "Offline"
        // with the record button appearing to do nothing (notably the camera-upload flow, whose
        // config has no streamId to activate).
        do {
          try await activateStream()
        } catch {
          let message = (error as? LifecycleError)?.errorDescription
            ?? "Couldn't activate the live stream."
          await MainActor.run { snackbarMessage = message }
        }
        if videoId == nil, let creator = videoCreator {
            await MainActor.run {
                isCreatingVideo = true
            }

          videoId = try await creator.createVideo()

            await MainActor.run {
                isCreatingVideo = false
            }
        }
        streamConfig.videoId = videoId
        await startTimer()
      } catch let error as LifecycleError {
        await MainActor.run {
          isCreatingVideo = false
          state = .notStreaming
          snackbarMessage = error.errorDescription
        }
      } catch let error as VideoCreator.VideoCreatorError {
        await MainActor.run {
          isCreatingVideo = false
          snackbarMessage = error.errorDescription
        }
      } catch {
        await MainActor.run {
          isCreatingVideo = false
          snackbarMessage = "Failed to start streaming!"
        }
      }
    }
  }
  
  func stopCountdownStreamingTimer() {
    countdownTimerPublisher?.cancel()
    countdownTimerPublisher = nil
    state = .notStreaming
  }
  
  @MainActor
  private func startTimer() {
    state = .preparing
    countdownProgress = 1.0
    countdownTimerPublisher = Timer.publish(every: 0.05, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.updateStreamingCountdown()
      }

  }
  
  func tapScreen(touchPoint: CGPoint) {
#if os(iOS)
    guard let device = rtmpStream.videoCapture(for: 0)?.device,
          device.isFocusPointOfInterestSupported else { return }
    
    let pointOfInterest = CGPoint(x: touchPoint.x / UIScreen.main.bounds.size.width,
                                  y: touchPoint.y / UIScreen.main.bounds.size.height)
    try? device.lockForConfiguration()
    device.focusPointOfInterest = pointOfInterest
    device.focusMode = .continuousAutoFocus
    device.unlockForConfiguration()
#endif
  }
  
  func rotateCamera() {
    let position: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
    if let connection = rtmpStream.videoCapture(for: 0) {
      connection.isVideoMirrored = position == .front
    }
    rtmpStream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position), channel: 0)
    currentPosition = position
  }
  
  func toggleMute() {
    isMuted.toggle()
    rtmpStream.hasAudio = !isMuted
  }
}

// MARK: - Audio session
private extension BunnyStreamCameraUploadViewModel {
  func setupAudioSession() {
    #if os(iOS)
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
      try session.setActive(true)
    } catch {
      snackbarMessage = Lingua.Error.audioError
    }
    #endif
  }
}

// MARK: - Error handling
private extension BunnyStreamCameraUploadViewModel {
  @objc
  private func rtmpStatusHandler(_ notification: Notification) {
    let event = Event.from(notification)
    guard let data: ASObject = event.data as? ASObject,
          let code: String = data["code"] as? String else { return }
    
    Task { await handleRtmpCode(code) }
  }
  
  @objc
  private func rtmpErrorHandler(_ notification: Notification) {
    // Route through the same reconnect path as .rtmpStatus so both failure sources
    // share one retry budget, backoff and failover (no immediate, uncounted connect).
    Task { @MainActor [weak self] in self?.scheduleReconnect() }
  }

  @MainActor func handleRtmpCode(_ code: String) {
    switch code {
    case RTMPConnection.Code.connectSuccess.rawValue:
      // Connected (possibly after a reconnect): clear the retry budget and any pending retry.
      retryCount = 0
      reconnectTask?.cancel()
      reconnectTask = nil
      state = .liveStreaming
      updateElapsedTime()
      rtmpStream.publish(streamConfig.streamKey)
      startIngestStatusPolling()
    case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
      scheduleReconnect()
    default:
      break
    }
  }

  /// Schedules a single reconnect attempt with exponential backoff, failing over
  /// between the primary and backup ingest URLs. Gives up after `maxRetryCount` attempts.
  @MainActor private func scheduleReconnect() {
    // Only one reconnect in flight — de-duplicates concurrent .ioError/.rtmpStatus events.
    guard reconnectTask == nil else { return }

    guard retryCount < maxRetryCount else {
      stopStreamingTimer()
      stopIngestStatusPolling()
      broadcastController?.emit(.reconnectFailed)
      state = .notStreaming
      snackbarMessage = Lingua.LiveStream.streamFailedMessage
      return
    }
    retryCount += 1

    // We're changing/re-establishing the connection: the target ingest is not confirmed live yet.
    currentIngestConfirmedLive = false
    consecutiveIngestMisses = 0

    // Alternate primary <-> backup when a backup URL is configured; otherwise stay on primary.
    if let backup = streamConfig.backupUri, !backup.isEmpty {
      usingBackup.toggle()
    }
    let targetUri = (usingBackup ? streamConfig.backupUri : nil) ?? streamConfig.uri
    let delay = reconnectDelay(for: retryCount)
    broadcastController?.emit(.reconnecting(attempt: retryCount, usingBackup: usingBackup))

    reconnectTask = Task { [weak self] in
      try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
      guard let self, !Task.isCancelled else { return }
      await MainActor.run {
        self.reconnectTask = nil
        self.rtmpConnection.connect(targetUri)
      }
    }
  }

  /// Exponential backoff capped at 8s: 1, 2, 4, 8, 8 seconds for attempts 1...5.
  private func reconnectDelay(for attempt: Int) -> Double {
    min(pow(2.0, Double(attempt - 1)), 8.0)
  }
  
  func setIsIdleTimerDisabled(_ disabled: Bool) {
#if os(iOS)
    UIApplication.shared.isIdleTimerDisabled = disabled
#endif
  }
}

// MARK: - Timer
private extension BunnyStreamCameraUploadViewModel {
  func startStreamingTimer() {
    startStreamingTime = Date()
    elapsedTimePublisher = Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.updateElapsedTime()
      }
  }
  
  func stopStreamingTimer() {
    elapsedTimePublisher?.cancel()
    elapsedTimePublisher = nil
    elapsedTime = nil
  }
  
  func updateElapsedTime() {
    guard let startTime = startStreamingTime else { return }
    let timeInterval = Date().timeIntervalSince(startTime)
    
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) / 60 % 60
    let seconds = Int(timeInterval) % 60
    elapsedTime = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
  }
  
  private func updateStreamingCountdown() {
    let decrement = 0.1 / CGFloat(totalCountdownDuration)
    if countdownProgress - decrement > 0 {
      countdownProgress -= decrement
    } else {
      countdownProgress = 0
      countdownTimerPublisher?.cancel()
      countdownTimerPublisher = nil
      
      startPublish()
    }
  }
}

// MARK: - Ingest status polling

private extension BunnyStreamCameraUploadViewModel {
  func startIngestStatusPolling() {
    guard let streamId = streamConfig.streamId, !streamConfig.accessKey.isEmpty else { return }
    ingestStatusTask?.cancel()
    ingestStatusTask = Task { [weak self] in
      while !Task.isCancelled {
        await self?.fetchIngestStatus(streamId: streamId)
        try? await Task.sleep(nanoseconds: 5_000_000_000)
      }
    }
  }

  func stopIngestStatusPolling() {
    ingestStatusTask?.cancel()
    ingestStatusTask = nil
    primaryLive = nil
    backupLive = nil
  }

  func fetchIngestStatus(streamId: String) async {
    // Lightweight /status endpoint, suited for frequent polling. (The full live stream
    // model doesn't expose primaryLive/backupLive — only /status does.)
    guard let status = try? await liveStreams.ingestStatus(
      libraryId: streamConfig.libraryId,
      streamId: streamId
    ) else { return }
    await MainActor.run { [weak self] in
      guard let self else { return }
      self.primaryLive = status.primaryLive
      self.backupLive = status.backupLive
      self.broadcastController?.update(primaryLive: status.primaryLive, backupLive: status.backupLive)
      self.proactiveFailoverIfNeeded()
    }
  }

  /// Proactively fails over to the other ingest when `/status` reports the ingest we're publishing
  /// to as not-live for `proactiveFailoverMissThreshold` consecutive polls — catching "silent"
  /// degradations where the RTMP/TCP connection stays up but Bunny stops receiving (so the reactive
  /// reconnect never fires). Works by dropping the degraded connection; the reactive path then
  /// toggles primary<->backup and republishes.
  @MainActor func proactiveFailoverIfNeeded() {
    // Only while publishing, with a backup to switch to, and no reactive reconnect already running.
    guard state == .liveStreaming,
          reconnectTask == nil,
          let backup = streamConfig.backupUri, !backup.isEmpty else { return }

    let liveOnCurrent = usingBackup ? backupLive : primaryLive
    switch liveOnCurrent {
    case .some(true):
      currentIngestConfirmedLive = true
      consecutiveIngestMisses = 0
    case .some(false):
      // Ignore the startup window: only act once the current ingest was actually confirmed live.
      guard currentIngestConfirmedLive else { return }
      consecutiveIngestMisses += 1
      guard consecutiveIngestMisses >= proactiveFailoverMissThreshold else { return }
      consecutiveIngestMisses = 0
      currentIngestConfirmedLive = false
      // The reconnect that follows alternates the ingest, so report where we're heading.
      broadcastController?.emit(.failedOver(usingBackup: !usingBackup))
      // Drop the silently-degraded connection; connectClosed -> scheduleReconnect fails over.
      rtmpConnection.close()
    case .none:
      break // Unknown status this tick — wait for the next poll.
    }
  }
}

// MARK: - Bunny Live Stream lifecycle (activate / complete)

extension BunnyStreamCameraUploadViewModel {
  /// Errors surfaced when starting/stopping a live stream on the Bunny backend.
  enum LifecycleError: LocalizedError {
    case missingConfiguration
    case unauthorized
    case notFound
    case server
    case http(Int)

    var errorDescription: String? {
      switch self {
      case .missingConfiguration: return "Live stream is not configured correctly."
      case .unauthorized:         return "Unauthorized — check your Access Key."
      case .notFound:             return "Live stream not found."
      case .server:               return "Server error. Please try again."
      case .http(let code):       return "Request failed (HTTP \(code))."
      }
    }

    /// Restates a repository failure in the wording the broadcaster UI uses.
    init(_ error: BunnyLiveStreamError) {
      switch error.kind {
      case .unauthorized:
        self = .unauthorized
      case .notFound:
        self = .notFound
      case .server:
        self = .server
      case .invalidRequest, .unprocessable, .transport, .invalidResponse, .unexpected:
        self = error.statusCode.map(LifecycleError.http) ?? .server
      }
    }
  }
}

private extension BunnyStreamCameraUploadViewModel {
  /// Activates the stream on the Bunny backend. HTTP failures throw a `LifecycleError` that the
  /// caller surfaces to the user — but activation is NOT a precondition for publishing, so the
  /// caller does not abort the broadcast on failure. When there's nothing to activate (no streamId,
  /// e.g. the camera-upload-to-VOD flow, or a missing access key) this skips silently.
  func activateStream() async throws {
    guard let streamId = streamConfig.streamId, !streamConfig.accessKey.isEmpty else {
      return
    }
    do {
      try await liveStreams.startLiveStream(
        libraryId: streamConfig.libraryId,
        streamId: streamId
      )
    } catch let error as BunnyLiveStreamError {
      throw LifecycleError(error)
    }
  }

  /// Completes the stream on the Bunny backend. Best-effort: the local broadcast is already
  /// torn down before this is called, so failures are surfaced but don't block stopping.
  func completeStream() async throws {
    guard let streamId = streamConfig.streamId, !streamConfig.accessKey.isEmpty else { return }
    do {
      try await liveStreams.stopLiveStream(
        libraryId: streamConfig.libraryId,
        streamId: streamId
      )
    } catch let error as BunnyLiveStreamError {
      throw LifecycleError(error)
    }
  }
}
