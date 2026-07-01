import AVFoundation
import BunnyStreamAPI
import Combine
import SwiftUI
import HaishinKit

final class BunnyStreamCameraUploadViewModel: ObservableObject {
  private var streamConfig: StreamConfig
  private var retryCount: Int = 0
  private let maxRetryCount: Int = 5
  private var notifications = NotificationCenter.default
  private var rtmpConnection = RTMPConnection()
  private var subscriptions = Set<AnyCancellable>()
  private var elapsedTimePublisher: AnyCancellable?
  private var countdownTimerPublisher: AnyCancellable?
  private var startStreamingTime: Date?
  private var totalCountdownDuration: Int = 4
  private var videoId: String?
  private let videoCreator: VideoCreator?

  @Published var snackbarMessage: String? = nil
  @Published var countdownProgress: CGFloat = 1.0
  @Published var state: StreamState = .notStreaming
  @Published var isMuted = false
  @Published var isCreatingVideo = false
  @Published var rtmpStream: RTMPStream
  @Published var currentPosition: AVCaptureDevice.Position = .back
  @Published var elapsedTime: String?
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
    rtmpStream.sessionPreset = .hd1280x720
    rtmpStream.videoSettings.videoSize = .init(width: 720, height: 1280)
    rtmpStream.isMultiCamSessionEnabled = true
    
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
    startStreamingTimer()
    rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
    rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    rtmpConnection.connect(streamConfig.uri)
  }
  
  func stopPublish() {
    videoId = nil
    setIsIdleTimerDisabled(false)
    state = .notStreaming
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
        // Activate first — if this fails the stream won't go live, so abort before publishing.
        try await activateStream()
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
    rtmpConnection.connect(streamConfig.uri)
  }
  
  @MainActor func handleRtmpCode(_ code: String) {
    switch code {
    case RTMPConnection.Code.connectSuccess.rawValue:
      state = .liveStreaming
      updateElapsedTime()
      rtmpStream.publish(streamConfig.streamKey)
      startIngestStatusPolling()
    case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
      guard retryCount <= maxRetryCount else {
        stopStreamingTimer()
        stopIngestStatusPolling()
        state = .notStreaming
        snackbarMessage = Lingua.LiveStream.streamFailedMessage
        return
      }
      rtmpConnection.connect(streamConfig.uri)
      retryCount += 1
    default:
      break
    }
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
    let api = BunnyStreamAPI(accessKey: streamConfig.accessKey)
    // Lightweight /status endpoint, suited for frequent polling. (The full live stream
    // model doesn't expose primaryLive/backupLive — only /status does.)
    guard case .ok(let ok) = try? await api.client.liveStreamGetStreamStatus(
      path: .init(libraryId: Int64(streamConfig.libraryId), streamId: streamId)
    ), case .json(let model) = ok.body else { return }
    await MainActor.run { [weak self] in
      self?.primaryLive = model.primaryLive
      self?.backupLive = model.backupLive
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
  }
}

private extension BunnyStreamCameraUploadViewModel {
  /// Activates the stream on the Bunny backend. Throws on failure so the caller can abort
  /// before publishing — an unactivated stream won't go live even if RTMP publishing succeeds.
  func activateStream() async throws {
    guard let streamId = streamConfig.streamId, !streamConfig.accessKey.isEmpty else {
      throw LifecycleError.missingConfiguration
    }
    let output = try await BunnyStreamAPI(accessKey: streamConfig.accessKey).client.liveStreamActivate(
      path: .init(libraryId: Int64(streamConfig.libraryId), streamId: streamId)
    )
    switch output {
    case .ok:
      break
    case .unauthorized:
      throw LifecycleError.unauthorized
    case .notFound:
      throw LifecycleError.notFound
    case .internalServerError:
      throw LifecycleError.server
    case .undocumented(statusCode: let code, _):
      throw LifecycleError.http(code)
    }
  }

  /// Completes the stream on the Bunny backend. Best-effort: the local broadcast is already
  /// torn down before this is called, so failures are surfaced but don't block stopping.
  func completeStream() async throws {
    guard let streamId = streamConfig.streamId, !streamConfig.accessKey.isEmpty else { return }
    let output = try await BunnyStreamAPI(accessKey: streamConfig.accessKey).client.liveStreamComplete(
      path: .init(libraryId: Int64(streamConfig.libraryId), streamId: streamId)
    )
    switch output {
    case .ok:
      break
    case .unauthorized:
      throw LifecycleError.unauthorized
    case .notFound:
      throw LifecycleError.notFound
    case .internalServerError:
      throw LifecycleError.server
    case .undocumented(statusCode: let code, _):
      throw LifecycleError.http(code)
    }
  }
}
