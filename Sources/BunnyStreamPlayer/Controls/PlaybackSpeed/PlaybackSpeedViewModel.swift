import SwiftUI

class PlaybackSpeedViewModel: ObservableObject {
  private let player: MediaPlayer
  @Published var playbackSpeed: PlaybackSpeed = .default
  @Published var showPlaybackSpeed = false
  let playbackSpeeds: [PlaybackSpeed]
  
  init(player: MediaPlayer, playbackSpeeds: [PlaybackSpeed] = .playbackSpeeds) {
    self.player = player
    self.playbackSpeeds = playbackSpeeds
    playbackSpeed = .init(speed: player.playerSpeed)
  }
  
  func playbackSpeedAction(_ playbackSpeed: PlaybackSpeed) {
    player.playerSpeed = playbackSpeed.speed
    self.playbackSpeed = playbackSpeed
  }
}
