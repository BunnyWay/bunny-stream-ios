import AVFoundation
import BunnyStreamAPI

final class LivePlaybackController: ObservableObject {
  enum State {
    case connecting
    case live(MediaPlayer)
    case offline(retryIn: TimeInterval)
    case error(Error)
  }

  @Published private(set) var state: State = .connecting

  private let loader: LiveStreamPlayDataLoader
  private let libraryId: Int
  private let streamId: String
  private var reconnectAttempt: Int = 0
  private var reconnectTask: Task<Void, Never>?
  private var stallObserver: NSObjectProtocol?
  private var failureObserver: NSObjectProtocol?

  init(bunnyStreamAPI: BunnyStreamAPI, libraryId: Int, streamId: String) {
    self.loader = LiveStreamPlayDataLoader(bunnyStreamAPI: bunnyStreamAPI)
    self.libraryId = libraryId
    self.streamId = streamId
  }

  deinit {
    reconnectTask?.cancel()
    removeItemObservers()
  }

  func start() {
    reconnectAttempt = 0
    connect()
  }

  func stop() {
    reconnectTask?.cancel()
    reconnectTask = nil
    removeItemObservers()
      if case .live(let player) = state {
          player.pause()
      }
    state = .connecting
  }
}

private extension LivePlaybackController {
  func connect() {
    state = .connecting
    reconnectTask = Task { [weak self] in
      guard let self else { return }
        
      do {
        let playData = try await loader.load(libraryId: libraryId, streamId: streamId)
          guard !Task.isCancelled else {
              return
          }
          
        let player = MediaPlayer.makeLive(url: playData.playbackURL, seekableWindowSeconds: playData.seekableWindow)
        observeItem(player)
        player.play()
          
          await MainActor.run {
              self.state = .live(player)
          }
          
        reconnectAttempt = 0
      } catch {
          guard !Task.isCancelled else {
              return
          }
          
        await MainActor.run { self.scheduleReconnect() }
      }
    }
  }

  func scheduleReconnect() {
    let delay = min(pow(2.0, Double(reconnectAttempt)), 60.0)
    reconnectAttempt += 1
    state = .offline(retryIn: delay)
    reconnectTask = Task { [weak self] in
      try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        guard !Task.isCancelled else {
            return
        }
        
        await MainActor.run {
            self?.connect()
        }
    }
  }

  func observeItem(_ player: MediaPlayer) {
    removeItemObservers()
    let center = NotificationCenter.default
    stallObserver = center.addObserver(
      forName: AVPlayerItem.playbackStalledNotification,
      object: player.currentItem,
      queue: .main
    ) { [weak self] _ in self?.handlePlaybackFailure() }

    failureObserver = center.addObserver(
      forName: AVPlayerItem.failedToPlayToEndTimeNotification,
      object: player.currentItem,
      queue: .main
    ) { [weak self] _ in self?.handlePlaybackFailure() }
  }

  func handlePlaybackFailure() {
    removeItemObservers()
    scheduleReconnect()
  }

  func removeItemObservers() {
    stallObserver.map(NotificationCenter.default.removeObserver)
    failureObserver.map(NotificationCenter.default.removeObserver)
    stallObserver = nil
    failureObserver = nil
  }
}
