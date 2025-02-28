import AVFoundation

class MediaPlayerAudioTracksProvider {
  private let playerItem: AVPlayerItem
  var audioTracks: [AVMediaSelectionOption] = []

  init(playerItem: AVPlayerItem) {
    self.playerItem = playerItem
    fetchAvailableAudioTracks()
  }
}

// MARK: - Public
extension MediaPlayerAudioTracksProvider {
  func selectAudioTrack(_ track: AVMediaSelectionOption) {
    guard let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else {
      return
    }
    playerItem.select(track, in: group)
  }

  var selectedAudioTrack: AVMediaSelectionOption? {
    guard let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else {
      return nil
    }
    return playerItem.currentMediaSelection.selectedMediaOption(in: group)
  }
}

// MARK: - Private
private extension MediaPlayerAudioTracksProvider {
  func fetchAvailableAudioTracks() {
    guard let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else {
      return
    }
    self.audioTracks = group.options
  }
}
