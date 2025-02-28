import AVFoundation
import SwiftUI

class AudioTracksViewModel: ObservableObject {
  private var audioTracksProvider: MediaPlayerAudioTracksProvider?
  @Published var showAudioTracks = false

  init(playerItem: AVPlayerItem?) {
    guard let playerItem else { return }
    audioTracksProvider = .init(playerItem: playerItem)
  }
}

// MARK: - Public
extension AudioTracksViewModel {
  var audioTracks: [AVMediaSelectionOption] {
    audioTracksProvider?.audioTracks ?? []
  }

  var selectedAudioTrack: AVMediaSelectionOption? {
    audioTracksProvider?.selectedAudioTrack
  }

  func selectAudioTrack(_ track: AVMediaSelectionOption) {
    audioTracksProvider?.selectAudioTrack(track)
  }
}
