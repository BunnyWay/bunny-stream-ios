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

  /// Original (pre-CMCD-rewrite) URL for players backed by a CMCDResourceLoader.
  var sourceURL: URL?

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
        state = .readyToPlay
        setupPeriodicTimeObserver()
        if playWhenReady {
          play()
        }
      case .unknown:
        canPlayVideo = false
        state = .failed(error: Error.undefinedState)
      case .failed:
        canPlayVideo = false
        state = .failed(error: playerItem.error ?? Error.undefinedError)
      @unknown default:
        canPlayVideo = false
        state = .failed(error: Error.undefinedState)
      }
    }
  }
  
  func setupPeriodicTimeObserver() {
    guard periodicTimeObserver == nil else { return }
    periodicTimeObserver = addPeriodicTimeObserver(
      forInterval: CMTimeMake(value: Int64(timeObservingMiliseconds), timescale: 1000),
      queue: .main
    ) { [weak self] time in
      guard let self, time.isValid else { return }
      
      if currentItem?.status == .failed, let error = currentItem?.error {
        state = .failed(error: error)
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
