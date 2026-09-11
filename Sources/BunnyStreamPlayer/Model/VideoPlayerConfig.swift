import Foundation

struct VideoPlayerConfig {
  var vastTagUrl: String? = .none
  var showHeatmap: Bool = false
  var controls: [Control] = Control.allCases
  /// Condensed control bar: drops the secondary controls, keeping the transport essentials.
  /// Set from the dashboard's `enableCompactControls` on the live `/play` response, matching
  /// Android.
  var compactControls: Bool = false

  var hasAds: Bool {
    vastTagUrl != nil
  }

  /// The controls that survive ``compactControls``.
  ///
  /// Compact mode hides settings, captions and the time readouts — the same set Android drops —
  /// so a small player keeps play/seek and loses the rest.
  private static let secondaryControls: Set<Control> = [
    .settings, .captions, .currentTime, .duration, .pip, .airplay
  ]

  /// Whether `control` should be rendered, honoring both the dashboard's control list and
  /// compact mode.
  func shows(_ control: Control) -> Bool {
    guard controls.contains(control) else { return false }
    return !(compactControls && Self.secondaryControls.contains(control))
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
