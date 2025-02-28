import Combine
import AVKit
import SwiftUI

class VideoPlayerControlsViewModel: ObservableObject {
  let player: MediaPlayer
  var playbackSpeedViewModel: PlaybackSpeedViewModel
  var captionsMenuViewModel: CaptionsMenuViewModel
  var resolutionsViewModel: ResolutionsViewModel
  var audioTracksViewModel: AudioTracksViewModel
  @Published var seekBarViewModel: SeekBarViewModel
  @Published var isFullScreen: Bool = false
  @Published var isMuted: Bool = false
  @Published var isPlaying: Bool = false
  @Published var playbackState: MediaPlayer.PlaybackState = .preparing
  @Published var isDraggingSeekBar: Bool = false
  @Published var isOptionsMenuActive = false
  @Published var captions: String?
  @Published var isAdPlaying: Bool = false
  private var cancellables = Set<AnyCancellable>()
  
  
  init(player: MediaPlayer, video: Video, heatmap: Heatmap) {
    self.player = player
    playbackSpeedViewModel = PlaybackSpeedViewModel(player: player)
    seekBarViewModel = SeekBarViewModel(player: player, video: video, heatmap: heatmap)
    captionsMenuViewModel = CaptionsMenuViewModel(player: player, captions: video.captions)
    resolutionsViewModel = ResolutionsViewModel(player: player, video: video)
    audioTracksViewModel = AudioTracksViewModel(playerItem: player.currentItem)
    setupPlayer()
  }
}

extension VideoPlayerControlsViewModel {
  var duration: Double {
    ceil(player.duration)
  }
  
  var currentFormattedTime: String {
    seekBarViewModel.elapsedTime.toFormattedTime()
  }
  
  var totalFormattedTime: String {
    duration.toFormattedTime()
  }

  func togglePlayPause() {
    if player.isPlaying {
      player.pause()
    } else {
      handlePlayerSeekTimeStateIsEnded()
      player.play()
      player.playerSpeed = playbackSpeedViewModel.playbackSpeed.speed
    }
  }
  
  func skipBackward() {
    guard playbackState != .readyToPlay else { return }
    let elapsedTime = max(seekBarViewModel.elapsedTime - 10, .zero)
    seekBarViewModel.elapsedTime = elapsedTime
    player.jump(to: elapsedTime)
  }
  
  func skipForward() {
    let elapsedTime = min(seekBarViewModel.elapsedTime + 10, player.duration)
    seekBarViewModel.elapsedTime = elapsedTime
    player.jump(to: ceil(elapsedTime))
  }
  
  func toggleFullScreenMode() {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction) {
      isFullScreen.toggle()
    }
  }
  
  func toggleMute() {
    isMuted.toggle()
    player.isMuted = isMuted
  }
}

private extension VideoPlayerControlsViewModel {
  func setupPlayer() {
    player.delegate = self
    player.allowsExternalPlayback = true
    isMuted = player.isMuted
    isPlaying = player.isPlaying
    playbackState = player.state
    seekBarViewModel.elapsedTime = player.currentTimeSeconds
    setupListeners()
  }
  
  func setupListeners() {
    seekBarViewModel.objectWillChange
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }
  
  func handlePlayerSeekTimeStateIsEnded() {
    guard playbackState == .ended else { return }
    player.jump(to: seekBarViewModel.elapsedTime == duration ? .zero : seekBarViewModel.elapsedTime)
  }
}

// MARK: - MediaPlayerDelegate
extension VideoPlayerControlsViewModel: MediaPlayerDelegate {
  func mediaPlayer(didBeginPlayback player: MediaPlayer) {
    isPlaying = true
  }
  
  func mediaPlayer(didPausePlayback player: MediaPlayer) {
    isPlaying = false
  }
  
  func mediaPlayer(didEndPlayback player: MediaPlayer) {
    isPlaying = false
  }
  
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double) {
    seekBarViewModel.elapsedTime = seconds
  }
  
  func mediaPlayer(_ player: MediaPlayer, didFailWithError error: Error) {
    playbackState = .failed(error: error)
  }
  
  func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState playbackState: MediaPlayer.PlaybackState) {
    self.playbackState = playbackState
  }
  
  func mediaPlayer(_ player: MediaPlayer, didChangeVolume volume: Float) {
    isMuted = volume.isZero
    player.isMuted = isMuted
  }
  
  func mediaPlayer(_ player: MediaPlayer, didChangeRate rate: Float) {
    isPlaying = player.isPlaying
  }
  
  func mediaPlayer(_ player: MediaPlayer, didChangeSubtitle subtitle: String?) {
    captions = subtitle
  }
}
