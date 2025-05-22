import Foundation

struct VideoPlayerConfig {
  var vastTagUrl: String? = .none
  var showHeatmap: Bool = false
  var controls: [Control] = Control.allCases
  
  var hasAds: Bool {
    vastTagUrl != nil
  }
}

extension VideoPlayerConfig {
  init?(response: VideoConfigResponse?) {
    guard let response else { return nil }
    self.vastTagUrl = response.vastTagUrl
    self.showHeatmap = response.showHeatmap
    self.controls = response.controls.controlList.compactMap { VideoPlayerConfig.Control(rawValue: $0.rawValue) }
  }
}

extension VideoPlayerConfig {
  enum Control: String, CaseIterable, Equatable {
    case airplay
    case rewind
    case fastForward = "fast-forward"
    case playLarge = "play-large"
    case captions
    case currentTime = "current-time"
    case duration
    case fullScreen = "fullscreen"
    case mute
    case pip
    case play
    case progress
    case settings
    case volume
  }
}
