import AVKit
import SwiftSubtitles

protocol MediaPlayerDelegate: AnyObject {
  func mediaPlayer(didBeginPlayback player: MediaPlayer)
  func mediaPlayer(didEndPlayback player: MediaPlayer)
  func mediaPlayer(didPausePlayback player: MediaPlayer)
  func mediaPlayer(didBeginReplay player: MediaPlayer)
  func mediaPlayer(didBeginBuffering player: MediaPlayer)
  func mediaPlayer(didEndBuffering player: MediaPlayer)
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double)
  func mediaPlayer(_ player: MediaPlayer, onProgressUpdate progress: Float)
  func mediaPlayer(_ player: MediaPlayer, didChangeVolume volume: Float)
  func mediaPlayer(_ player: MediaPlayer, didChangeRate rate: Float)
  func mediaPlayer(_ player: MediaPlayer, didChangeSubtitle subtitle: String?)
  
  func mediaPlayer(_ player: MediaPlayer, didFailWithError error: Error)
  func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState playbackState: MediaPlayer.PlaybackState)
}

extension MediaPlayerDelegate {
  func mediaPlayer(didBeginPlayback player: MediaPlayer) {}
  func mediaPlayer(didEndPlayback player: MediaPlayer) {}
  func mediaPlayer(didPausePlayback player: MediaPlayer) {}
  func mediaPlayer(didBeginReplay player: MediaPlayer) {}
  func mediaPlayer(didBeginBuffering player: MediaPlayer) {}
  func mediaPlayer(didEndBuffering player: MediaPlayer) {}
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double) {}
  func mediaPlayer(_ player: MediaPlayer, didFailWithError error: Error) {}
  func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState playbackState: MediaPlayer.PlaybackState) {}
  func mediaPlayer(_ player: MediaPlayer, onProgressUpdate progress: Float) {}
  func mediaPlayer(_ player: MediaPlayer, didChangeVolume volume: Float) {}
  func mediaPlayer(_ player: MediaPlayer, didChangeRate rate: Float) {}
  func mediaPlayer(_ player: MediaPlayer, didChangeSubtitle subtitle: String?) {}
}

class MediaPlayer: AVPlayer {
  var playbackInterval: (startAt: Double, endAt: Double) = (0, 0)
  
  /// A Boolean value that determines whether the media player should loop playback when it reaches the end of the media.
  ///
  /// If this property is set to `true`, the media player will automatically start playing the media from the beginning once it reaches the end. If set to `false`, the media player will stop playing when it reaches the end of the media.
  /// If the custom time interval is set, it will automatically loop in the selected time interval.
  ///
  /// The default value is `false`.
  var allowsLooping = false

  var kind: PlaybackKind = .vod
  
  /// The time interval in milliseconds at which the player observes the playback time.
  /// This property determines how often the player updates the playback progress.
  /// When this property is set, the player removes the current time observer and sets up a new one.
  /// The default value is `500` milliseconds, which means that the progress delegate methods will get
  /// called every 500 miliseconds
  var timeObservingMiliseconds: Int = 500 {
    didSet {
      // Set up a new time observer with the updated interval
      setupPeriodicTimeObserver()
    }
  }
  
  /// The total duration of the current media item in seconds. This duration does not take into account any custom playback interval set.
  var duration: Double {
    guard kind != .live else { return .infinity }
    guard let duration = currentItem?.asset.duration, duration.isValid, !duration.seconds.isNaN else { return 0 }
    return duration.seconds
  }
  
  /// A Boolean value indicating whether the media player is currently playing.
  var isPlaying: Bool {
    rate > 0.0
  }
  
  /// The current playback time of the media player in seconds.
  /// This property returns the current time of the player converted to seconds.
  var currentTimeSeconds: Double {
    Double(CMTimeGetSeconds(currentTime()))
  }
  
  /// The current state of the media player.
  /// This property is of type `MediaPlayerPlaybackState` and its default value is `.undefined`.
  /// When the state changes, the media player informs its delegate by calling the `mediaPlayer(_:didUpdatePlaybackState:)` method.
  var state: PlaybackState = .preparing {
    didSet { onStateUpdate() }
  }
  
  weak var delegate: MediaPlayerDelegate?
  
  /// Player speed
  var playerSpeed: Float = 1.0 {
    didSet { rate = playerSpeed }
  }
  
  /// Subtitles
  private var subtitlesProvider: MediaPlayerSubtitlesProvider?
  private var currentSubtitleCue: Subtitles.Cue?
  var currentSubtitleLanguage: String? {
    didSet {
      Task { 
        await updateSubtitles(time: currentTime())
        await subtitlesProvider?.loadSubtitlesIfNeeded()
      }
    }
  }
  
  /// Boolean flag `true` when item is prepared and can be played
  private(set) var canPlayVideo: Bool = false
  /// Flipped to `true` when trying to start playing but `canPlayVideo` is false
  private var playWhenReady: Bool = false
  private var playerItemObserver: NSKeyValueObservation?
  private var periodicTimeObserver: Any?
  private var volumeObservation: NSKeyValueObservation?
  private var rateObservation: NSKeyValueObservation?
  private var fairPlayHandler: FairPlayStreamHandler?
  private var cmcdLoader: CMCDResourceLoader?
  private var errorLogObserver: NSObjectProtocol?

  /// Original (pre-CMCD-rewrite) URL for players backed by a CMCDResourceLoader.
  var sourceURL: URL?

  /// Set once a host check has come back saying the CDN host resolves to a sinkhole — Bunny's
  /// DNS-level country block. Unlike a 403 this leaves no trace on the item, so it is remembered
  /// here. Cleared whenever a new item is observed, so a later success is not held against.
  private var isBlockedByDNS = false

  /// The host a check is already running for, so a failure that keeps repeating — every segment
  /// of a blocked stream fails — resolves it once rather than once per event.
  private var hostCheckInFlight: String?

  /// Called on the main actor once a host check concludes the CDN host is sinkholed.
  ///
  /// The check is asynchronous, so a caller that reacts to failure immediately — live playback
  /// re-polls on any failure it thinks is transient — has already moved on by the time the
  /// verdict lands. This is how it learns to stop.
  var onBlockedByDNS: (() -> Void)?

  /// Whether playback was refused for good: an HTTP 403 (geo-blocking, referrer protection,
  /// token auth) or a CDN host that DNS answered with a sinkhole. Either way retrying can't help.
  /// A CMCD-backed (live) player reads its loader's latest status, which any later success
  /// clears — a 403 the stream recovered from never counts. Otherwise only a failed item counts.
  var isRefusedAsForbidden: Bool {
    if isBlockedByDNS { return true }
    if let cmcdLoader { return cmcdLoader.lastFailedStatusCode == 403 }
    guard let currentItem, currentItem.status == .failed else { return false }
    return (playbackError(for: currentItem) as? VideoPlayerError) == .notAvailable
  }

  override init() {
    super.init()
    setupObservers()
  }
  
  override init(url: URL) {
    super.init(url: url)
    setupObservers()
  }
  
  override init(playerItem item: AVPlayerItem?) {
    super.init(playerItem: item)
    setupObservers()
  }
  
  convenience init(asset: AVURLAsset) {
    let item = AVPlayerItem(asset: asset)
    self.init(playerItem: item)
  }
  
  convenience init(url: URL,
                   fairPlayHandler: FairPlayStreamHandler,
                   subtitlesProvider: MediaPlayerSubtitlesProvider? = .none,
                   httpHeaders: [String: String] = [:]) {
    let playerItem = fairPlayHandler.setupAssetPlayback(url: url, httpHeaders: httpHeaders)
    self.init(playerItem: playerItem)
    self.fairPlayHandler = fairPlayHandler
    self.subtitlesProvider = subtitlesProvider
    self.replaceCurrentItem(with: playerItem)
  }

  convenience init(liveURL url: URL, contentId: String, streamType: CMCDSession.StreamType) {
    let cmcdSession = CMCDSession(contentId: contentId, streamType: streamType)
    let loader = CMCDResourceLoader(session: cmcdSession)
    let rewrittenURL = CMCDResourceLoader.rewrite(url)
    let asset = AVURLAsset(url: rewrittenURL)
    let loaderQueue = DispatchQueue(label: "net.bunny.cmcd", qos: .userInitiated)
    asset.resourceLoader.setDelegate(loader, queue: loaderQueue)
    let item = AVPlayerItem(asset: asset)
    self.init(playerItem: item)
    self.cmcdLoader = loader
    self.sourceURL = url
    cmcdSession.player = self
    self.replaceCurrentItem(with: item)
  }
  
  // MARK: - methods
  
  /// Starts playing the media from the current position.
  /// This function also updates the state of the media player to `.playing` and informs the delegate that the playback has started.
  override func play() {
    guard canPlayVideo else {
      setupPlayerItemObserver()
      playWhenReady = true
      return
    }
    
    playWhenReady = false
    setupPlayerItemObserver()
    super.play()
    state = .playing
    rate = playerSpeed
  }
  
  /// Starts playing the media from a specified time.
  ///
  /// - Parameters:
  ///   - fromTime: The time from which to start playing the media. This should be less than the total duration of the media.
  ///
  /// If `fromTime` is greater than or equal to the total duration, this function will do nothing.
  func play(from fromTime: Double) {
    guard fromTime < duration else {
      print("`fromTime` should be less than total duration")
      return
    }
    
    playbackInterval = (fromTime, duration)
    jump(to: fromTime)
    play()
  }
  
  /// Starts playing the media from a specified start time to a specified end time.
  ///
  /// - Parameters:
  ///   - fromTime: The time from which to start playing the media. This should be less than `toTime`.
  ///   - toTime: The time at which to stop playing the media. This should be greater than `fromTime`.
  ///
  /// If `fromTime` is greater than or equal to `toTime`, this function will do nothing.
  func play(from fromTime: Double, to toTime: Double) {
    guard fromTime < toTime else {
      print("`fromTime` should be less than `toTime`")
      return
    }
    
    playbackInterval = (fromTime, toTime)
    setPlaybackPosition(to: fromTime)
    play()
  }
  
  /// Jumps to a specified time in the media.
  ///
  /// - Parameters:
  ///   - time: The time to which to jump. This starts playing the media if not yet playing.
  func jump(to time: Double) {
    if state != .playing { play() }
    setPlaybackPosition(to: time)
  }
  
  /// Stops the media playback and resets the playback position to the start of the playback interval.
  /// Also, updates the state of the media player to `.stopped`.
  func stop() {
    pause()
    setPlaybackPosition(to: playbackInterval.startAt)
    removePeriodicTimeObserver()
    removePlayerItemObserver()
    canPlayVideo = false
    state = .stopped
  }
  
  /// Seeks forward in the media by a specified number of seconds.
  ///
  /// - Parameters:
  ///   - seconds: The number of seconds to seek forward. If the resulting time exceeds the end of the playback interval,
  ///   the function will set the playback position to the end of the interval.
  func seekForward(seconds: Double) {
    setPlaybackPosition(to: min(currentTimeSeconds + seconds, playbackInterval.endAt))
  }
  
  /// Seeks backward in the media by a specified number of seconds.
  ///
  /// - Parameters:
  ///   - seconds: The number of seconds to seek backward. If the resulting time is less than the start of the playback interval,
  ///   the function will set the playback position to the start of the interval.
  func seekBackward(seconds: Double) {
    setPlaybackPosition(to: (max(currentTimeSeconds - seconds, playbackInterval.startAt)))
  }
  
  /// Pauses the media playback, updates the state of the media player to `.paused`, and informs the delegate that the playback has paused.
  override func pause() {
    super.pause()
    state = .paused
  }
  
  /// Replaces the current playing item with the new given item.
  ///
  /// - Parameters:
  ///   - item: The new `AVPlayerItem` to be replaced with. Resets the playback interval to default.
  ///
  /// This does not automatically play the item. To play the replaced item, call the method`play()`-
  override func replaceCurrentItem(with item: AVPlayerItem?) {
    super.replaceCurrentItem(with: item)
    playbackInterval = (0, duration)
    setupPlayerItemObserver()
  }
  
  /// Updates the playback interval with the new range.
  ///
  /// - Parameters:
  ///   - startAt: The new start of the playback range.
  ///   - endAt: The new end of the playback range.
  ///
  /// If the current time is out of new range, this function does nothing.
  func updatePlaybackInterval(startAt: Double, endAt: Double) {
    guard startAt < endAt else {
      print("`startAt` should be less than `endAt`")
      return
    }
    playbackInterval = (startAt, endAt)
    setupPeriodicTimeObserver()
    
    if currentTimeSeconds < startAt || currentTimeSeconds > endAt {
      setPlaybackPosition(to: max(startAt, min(endAt, currentTimeSeconds)))
    }
  }
  
  /// The desired limit, in bits per second, of network bandwidth consumption for this item.
  /// - Parameter bitrate: A value that represents a bitrat
  func setPlayerBitrate(_ bitrate: Double) {
    currentItem?.preferredPeakBitRate = bitrate
  }
}

// MARK: - Private Methods
private extension MediaPlayer {
  func setupObservers() {
    setupPlayerItemObserver()
    setupVolumeObserver()
    setupRateObserver()
  }
  
  func setupPlayerItemObserver() {
    guard playerItemObserver == nil else {
      setupPeriodicTimeObserver()
      return
    }
    removePeriodicTimeObserver()
    playerItemObserver = currentItem?.observe(\.status, options: [.new, .old]) { [weak self] playerItem, _ in
      guard let self else { return }
      switch playerItem.status {
      case .readyToPlay:
        canPlayVideo = true
        // Playback works, so an earlier sinkhole verdict no longer applies (the viewer moved
        // network, or the block was lifted).
        isBlockedByDNS = false
        state = .readyToPlay
        // The asset is loaded now, so `duration` is valid. If the interval's end was captured
        // before the asset resolved — a deferred-loading VOD asset reports `duration == 0` at
        // init — it would still be 0 here, and the first time-observer tick would treat t≈0 as
        // "ended" and freeze playback at 0:00. Backfill a missing end; only when it's unset, so a
        // caller-supplied custom interval is preserved. (Live's end is `.infinity`, never <= 0.)
        if playbackInterval.endAt <= 0 {
          playbackInterval = (playbackInterval.startAt, duration)
        }
        setupPeriodicTimeObserver()
        if playWhenReady {
          play()
        }
      case .unknown:
        canPlayVideo = false
        state = .failed(error: Error.undefinedState)
      case .failed:
        canPlayVideo = false
        state = .failed(error: playbackError(for: playerItem))
        // A refused connection may still turn out to be a DNS-level geo-block; settle it off
        // this path and upgrade the failure if so.
        checkHostForSinkholeIfNeeded(for: playerItem)
      @unknown default:
        canPlayVideo = false
        state = .failed(error: Error.undefinedState)
      }
    }
    // The error log can land after the item has already failed. Once it shows a 403, upgrade the
    // generic failure so the viewer gets "not available" instead of a retry that can't help.
    errorLogObserver = NotificationCenter.default.addObserver(
      forName: AVPlayerItem.newErrorLogEntryNotification,
      object: currentItem,
      queue: .main
    ) { [weak self] _ in
      guard let self, case .failed(let error) = state,
            (error as? VideoPlayerError) != .notAvailable,
            let currentItem else { return }
      let resolved = playbackError(for: currentItem)
      if (resolved as? VideoPlayerError) == .notAvailable {
        state = .failed(error: resolved)
      }
    }
  }

  /// The error a failed item surfaces. Any HTTP 403 — from the CDN (manifest, segments, MP4) or
  /// the FairPlay license server — becomes `VideoPlayerError.notAvailable`, and a device that
  /// plainly has no connection becomes `VideoPlayerError.noInternetConnection`.
  ///
  /// A refused connection is left as-is here and settled asynchronously by
  /// ``checkHostForSinkholeIfNeeded(for:)`` — telling a geo-block apart from an outage needs a
  /// DNS lookup, which must not block this call.
  func playbackError(for item: AVPlayerItem) -> Swift.Error {
    if let event = item.errorLog()?.events.last(where: { PlaybackForbiddenDetector.isForbidden($0) }) {
      print("[BunnyStreamPlayer] playback HTTP 403 — \(event.uri ?? "unknown URI")")
      return VideoPlayerError.notAvailable
    }
    if let error = item.error, PlaybackForbiddenDetector.isForbidden(error) {
      print("[BunnyStreamPlayer] playback HTTP 403 — \(error)")
      return VideoPlayerError.notAvailable
    }
    // Our own loaders' statuses never reach the item's error intact, so they keep them: the
    // FairPlay license server, and the CMCD loader that fetches live manifests and segments.
    if fairPlayHandler?.lastFailedStatusCode == 403 || cmcdLoader?.lastFailedStatusCode == 403 {
      return VideoPlayerError.notAvailable
    }
    if isBlockedByDNS { return VideoPlayerError.notAvailable }
    if let error = item.error, PlaybackFailureClassifier.classify(error) == .noConnection {
      return VideoPlayerError.noInternetConnection
    }
    return item.error ?? Error.undefinedError
  }

  /// Resolves the CDN host behind a refused connection, and upgrades the failure once it answers.
  ///
  /// Bunny's "Blocked countries" block happens in DNS — the host resolves to a loopback sinkhole,
  /// so the connection is refused and no 403 is ever returned. That is indistinguishable from an
  /// outage until the host is resolved, which is why this runs off the failure path rather than
  /// inside ``playbackError(for:)``: `getaddrinfo` blocks.
  func checkHostForSinkholeIfNeeded(for item: AVPlayerItem) {
    guard !isBlockedByDNS,
          let error = item.error,
          PlaybackFailureClassifier.classify(error) == .unreachable,
          let host = failedHost(for: item),
          hostCheckInFlight != host
    else { return }

    hostCheckInFlight = host
    DispatchQueue.global(qos: .utility).async {
      let outcome = SinkholeDetector.resolve(host: host)
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.applyHostCheck(outcome, host: host)
      }
    }
  }

  /// Applies a finished host check on the main actor.
  private func applyHostCheck(_ outcome: SinkholeDetector.Outcome, host: String) {
    hostCheckInFlight = nil
    guard let resolved = PlaybackFailureClassifier.error(for: outcome) else { return }
    if resolved == .notAvailable {
      isBlockedByDNS = true
      print("[BunnyStreamPlayer] playback blocked — \(host) resolves to a sinkhole")
    }
    // Only upgrade a failure that is still on screen, and never downgrade a 403.
    if case .failed(let current) = state,
       (current as? VideoPlayerError) != .notAvailable {
      state = .failed(error: resolved)
    }
    // Told last, so a listener that tears this player down sees the final state first.
    if resolved == .notAvailable { onBlockedByDNS?() }
  }

  /// The host playback was refused from: the item's own URL, falling back to the pre-CMCD URL for
  /// a live player whose item is backed by a custom scheme.
  private func failedHost(for item: AVPlayerItem) -> String? {
    (item.asset as? AVURLAsset)?.url.host ?? sourceURL?.host
  }

  func setupPeriodicTimeObserver() {
    guard periodicTimeObserver == nil else { return }
    periodicTimeObserver = addPeriodicTimeObserver(
      forInterval: CMTimeMake(value: Int64(timeObservingMiliseconds), timescale: 1000),
      queue: .main
    ) { [weak self] time in
      guard let self, time.isValid else { return }
      
      if let currentItem, currentItem.status == .failed, currentItem.error != nil {
        state = .failed(error: playbackError(for: currentItem))
        removePeriodicTimeObserver()
        return
      }
      
      delegate?.mediaPlayer(self, didProgressToTime: ceil(time.seconds))
      delegate?.mediaPlayer(self, onProgressUpdate: Float(time.seconds / duration))
      Task { await self.updateSubtitles(time: time) }
      timeObserverCallback(time: time)
      
      guard let currentItem = self.currentItem, currentItem.status == .readyToPlay else { return }
      currentItem.isPlaybackLikelyToKeepUp
      ? delegate?.mediaPlayer(didEndBuffering: self)
      : delegate?.mediaPlayer(didBeginBuffering: self)
    }
  }
  
  func setupVolumeObserver() {
#if os(iOS)
    volumeObservation = AVAudioSession.sharedInstance().observe(\.outputVolume) { [weak self] (audioSession, change) in
      guard let self = self else { return }
      let volume = audioSession.outputVolume
      self.delegate?.mediaPlayer(self, didChangeVolume: volume)
    }
#endif
  }
  
  func setupRateObserver() {
    rateObservation = observe(\.rate, options: [.new]) { [weak self] (player, change) in
      guard let newRate = change.newValue else { return }
      self?.delegate?.mediaPlayer(player, didChangeRate: newRate)
    }
  }
  
  @objc func volumeChanged(notification: NSNotification) {
    if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
      delegate?.mediaPlayer(self, didChangeVolume: volume)
    }
  }
  
  func timeObserverCallback(time: CMTime) {
    // Never treat an unresolved interval (endAt == 0) as "ended": that would fire on the very
    // first tick at t≈0 and freeze playback. A real VOD always has a positive end; live is .infinity.
    guard playbackInterval.endAt > 0 else { return }
    guard (time.seconds + Double(timeObservingMiliseconds) / 1_000) >= playbackInterval.endAt else { return }
    
    // at this point, item has ended
    if allowsLooping {
      setPlaybackPosition(to: playbackInterval.startAt)
      play()
      delegate?.mediaPlayer(didBeginReplay: self)
    } else {
      removePeriodicTimeObserver()
      state = .ended
    }
  }
  
  func removePlayerItemObserver() {
    playerItemObserver?.invalidate()
    playerItemObserver = nil
    errorLogObserver.map(NotificationCenter.default.removeObserver)
    errorLogObserver = nil
  }
  
  func removePeriodicTimeObserver() {
    periodicTimeObserver.map(removeTimeObserver)
    periodicTimeObserver = nil
  }
  
  func setPlaybackPosition(to value: Double) {
    let seekTime = CMTimeMakeWithSeconds(floor(value), preferredTimescale: 6_000)
    seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
    Task { await updateSubtitles(time: seekTime) }
  }
  
  func updateSubtitles(time: CMTime) async {
    // Check if the subtitle language is set and get the subtitle cue
    guard let language = currentSubtitleLanguage,
          let subtitleCue = await subtitlesProvider?.subtitle(for: time, currentLanguage: language) else {
      await resetSubtitleCueIfNeeded()
      return
    }
    
    // Update the subtitle cue if it has changed
    if subtitleCue != currentSubtitleCue {
      await updateCurrentSubtitleCue(subtitleCue)
    }
    
    @MainActor func resetSubtitleCueIfNeeded() {
      if currentSubtitleCue != nil {
        updateCurrentSubtitleCue(nil)
      }
    }
    
    @MainActor func updateCurrentSubtitleCue(_ newCue: Subtitles.Cue?) {
      currentSubtitleCue = newCue
      delegate?.mediaPlayer(self, didChangeSubtitle: newCue?.text)
    }
  }
  
  func onStateUpdate() {
    delegate?.mediaPlayer(self, didUpdatePlaybackState: state)
    print("Player status: \(state.value)")
    
    switch state {
    case .playing:
      delegate?.mediaPlayer(didBeginPlayback: self)
    case .paused:
      delegate?.mediaPlayer(didPausePlayback: self)
    case .ended:
      delegate?.mediaPlayer(didEndPlayback: self)
    case .failed(error: let error):
      delegate?.mediaPlayer(self, didFailWithError: error)
    case .preparing, .readyToPlay, .stopped:
      break
    }
  }
}
