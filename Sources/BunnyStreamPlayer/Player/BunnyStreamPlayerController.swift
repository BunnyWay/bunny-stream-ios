import AVFoundation
import Combine

public struct BunnyStreamPlaybackSnapshot: Sendable, Equatable {
  public let state: BunnyStreamPlaybackState
  public let position: TimeInterval
  public let duration: TimeInterval
  public let volume: Float
  public let isMuted: Bool
  public let playbackRate: Float
  public let videoSize: CGSize

  public init(
    state: BunnyStreamPlaybackState,
    position: TimeInterval,
    duration: TimeInterval,
    volume: Float,
    isMuted: Bool,
    playbackRate: Float,
    videoSize: CGSize
  ) {
    self.state = state
    self.position = position
    self.duration = duration
    self.volume = volume
    self.isMuted = isMuted
    self.playbackRate = playbackRate
    self.videoSize = videoSize
  }
}

@MainActor
public final class BunnyStreamPlayerController: ObservableObject {
  @Published public private(set) var snapshot = BunnyStreamPlaybackSnapshot(
    state: .idle,
    position: 0,
    duration: 0,
    volume: 1,
    isMuted: false,
    playbackRate: 1,
    videoSize: .zero
  )

  public var onReady: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onStateChange: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onProgress: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onBufferingChange: ((Bool) -> Void)?
  public var onPlay: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onPause: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onEnd: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onVolumeChange: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onPlaybackRateChange: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onVideoSizeChange: ((BunnyStreamPlaybackSnapshot) -> Void)?
  public var onError: ((Error) -> Void)?

  private weak var player: MediaPlayer?
  private var pendingCommands: [(MediaPlayer) -> Void] = []
  private var observations: [NSKeyValueObservation] = []
  private var periodicTimeObserver: Any?
  private var endObserver: NSObjectProtocol?
  private var failureObserver: NSObjectProtocol?
  private var selectedPlaybackRate: Float = 1
  private var previousVolume: Float = 1
  private var isDisposed = false

  public init() {}

  public func play() {
    withPlayer { $0.play() }
  }

  public func pause() {
    withPlayer { $0.pause() }
  }

  public func seek(to seconds: TimeInterval) {
    withPlayer {
      let wasPlaying = $0.isPlaying
      let target = CMTime(seconds: max(0, min(seconds, $0.duration)), preferredTimescale: 600)
      $0.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
      if !wasPlaying { $0.pause() }
    }
  }

  public func setVolume(_ volume: Float) {
    withPlayer {
      let value = max(0, min(volume, 1))
      $0.volume = value
      if value > 0 { self.previousVolume = value }
    }
  }

  public func setPlaybackRate(_ rate: Float) {
    withPlayer {
      let value = max(0.25, min(rate, 4))
      self.selectedPlaybackRate = value
      $0.playerSpeed = value
      if $0.isPlaying { $0.rate = value }
      self.publishSnapshot()
      self.onPlaybackRateChange?(self.snapshot)
    }
  }

  public func mute() {
    withPlayer {
      if $0.volume > 0 { self.previousVolume = $0.volume }
      $0.isMuted = true
    }
  }

  public func unmute() {
    withPlayer {
      $0.isMuted = false
      if $0.volume == 0 { $0.volume = self.previousVolume }
    }
  }

  public func dispose() {
    guard !isDisposed else { return }
    isDisposed = true
    detach()
    pendingCommands.removeAll()
    onReady = nil
    onStateChange = nil
    onProgress = nil
    onBufferingChange = nil
    onPlay = nil
    onPause = nil
    onEnd = nil
    onVolumeChange = nil
    onPlaybackRateChange = nil
    onVideoSizeChange = nil
    onError = nil
    snapshot = BunnyStreamPlaybackSnapshot(
      state: .idle,
      position: 0,
      duration: 0,
      volume: 1,
      isMuted: false,
      playbackRate: selectedPlaybackRate,
      videoSize: .zero
    )
  }

  func attach(to player: MediaPlayer) {
    guard !isDisposed else { return }
    detach()
    self.player = player
    selectedPlaybackRate = player.playerSpeed
    previousVolume = player.volume > 0 ? player.volume : previousVolume
    observe(player)
    let commands = pendingCommands
    pendingCommands.removeAll()
    commands.forEach { $0(player) }
    publishSnapshot()
  }

  func report(_ error: Error) {
    guard !isDisposed else { return }
    update(state: .failed)
    onError?(error)
  }

  private func withPlayer(_ command: @escaping (MediaPlayer) -> Void) {
    guard !isDisposed else { return }
    guard let player else {
      pendingCommands.append(command)
      return
    }
    command(player)
  }

  private func observe(_ player: MediaPlayer) {
    observations = [
      player.observe(\.status, options: [.initial, .new]) { [weak self] player, _ in
        Task { @MainActor in self?.handleStatus(player.status) }
      },
      player.observe(\.rate, options: [.initial, .new]) { [weak self] player, _ in
        Task { @MainActor in self?.handleRate(player.rate) }
      },
      player.observe(\.volume, options: [.initial, .new]) { [weak self] _, _ in
        Task { @MainActor in self?.publishVolume() }
      },
      player.observe(\.isMuted, options: [.initial, .new]) { [weak self] _, _ in
        Task { @MainActor in self?.publishVolume() }
      },
      player.observe(\.currentItem, options: [.initial, .new]) { [weak self] player, _ in
        Task { @MainActor in self?.observeItem(player.currentItem) }
      }
    ]
    periodicTimeObserver = player.addPeriodicTimeObserver(
      forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        guard let self, !self.isDisposed else { return }
        self.publishSnapshot()
        self.onProgress?(self.snapshot)
      }
    }
  }

  private func observeItem(_ item: AVPlayerItem?) {
    if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
    if let failureObserver { NotificationCenter.default.removeObserver(failureObserver) }
    guard let item else { return }
    observations.append(item.observe(\.isPlaybackBufferEmpty, options: [.initial, .new]) { [weak self] item, _ in
      Task { @MainActor in self?.publishBuffering(item.isPlaybackBufferEmpty) }
    })
    observations.append(item.observe(\.isPlaybackLikelyToKeepUp, options: [.initial, .new]) { [weak self] item, _ in
      Task { @MainActor in self?.publishBuffering(!item.isPlaybackLikelyToKeepUp) }
    })
    observations.append(item.observe(\.presentationSize, options: [.initial, .new]) { [weak self] _, _ in
      Task { @MainActor in
        self?.publishSnapshot()
        if let self { self.onVideoSizeChange?(self.snapshot) }
      }
    })
    endObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.update(state: .ended)
        if let self { self.onEnd?(self.snapshot) }
      }
    }
    failureObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemFailedToPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak self] notification in
      let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
      Task { @MainActor in self?.report(error ?? VideoPlayerError.unknownError) }
    }
  }

  private func handleStatus(_ status: AVPlayer.Status) {
    switch status {
    case .unknown:
      update(state: .preparing)
    case .readyToPlay:
      update(state: .ready)
      onReady?(snapshot)
    case .failed:
      report(player?.error ?? VideoPlayerError.unknownError)
    @unknown default:
      update(state: .failed)
    }
  }

  private func handleRate(_ rate: Float) {
    let oldState = snapshot.state
    if rate > 0 {
      selectedPlaybackRate = rate
      update(state: .playing)
      if oldState != .playing { onPlay?(snapshot) }
    } else if oldState == .playing {
      update(state: .paused)
      onPause?(snapshot)
    } else {
      publishSnapshot()
    }
  }

  private func publishBuffering(_ isBuffering: Bool) {
    guard !isDisposed else { return }
    if isBuffering { update(state: .buffering) }
    onBufferingChange?(isBuffering)
  }

  private func publishVolume() {
    guard let player, !isDisposed else { return }
    if player.volume > 0 { previousVolume = player.volume }
    publishSnapshot()
    onVolumeChange?(snapshot)
  }

  private func update(state: BunnyStreamPlaybackState) {
    publishSnapshot(state: state)
    onStateChange?(snapshot)
  }

  private func publishSnapshot(state: BunnyStreamPlaybackState? = nil) {
    guard let player, !isDisposed else { return }
    let position = player.currentTimeSeconds.isFinite ? player.currentTimeSeconds : 0
    let duration = player.duration.isFinite ? player.duration : 0
    snapshot = BunnyStreamPlaybackSnapshot(
      state: state ?? snapshot.state,
      position: position,
      duration: duration,
      volume: player.volume,
      isMuted: player.isMuted,
      playbackRate: selectedPlaybackRate,
      videoSize: player.currentItem?.presentationSize ?? .zero
    )
  }

  private func detach() {
    observations.removeAll()
    if let periodicTimeObserver, let player { player.removeTimeObserver(periodicTimeObserver) }
    periodicTimeObserver = nil
    if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
    if let failureObserver { NotificationCenter.default.removeObserver(failureObserver) }
    endObserver = nil
    failureObserver = nil
    player = nil
  }
}
