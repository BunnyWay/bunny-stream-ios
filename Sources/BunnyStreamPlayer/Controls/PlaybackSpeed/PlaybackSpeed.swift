import Foundation

struct PlaybackSpeed: Hashable {
  let speed: Float
  
  var title: String {
    guard speed != 1.0 else { return Lingua.Settings.playbackSpeedNormal }
    let formattedString = String(format: "%.2f", speed)
    if formattedString.hasSuffix("0") {
      return String(format: "%.1fx", speed)
    }
    return "\(formattedString)x"
  }
}

extension PlaybackSpeed {
  static var `default`: PlaybackSpeed { .init(speed: 1.0) }
}

extension [PlaybackSpeed] {
  static var playbackSpeeds: [PlaybackSpeed] {
    let startSpeed: Float = 0.5
    let endSpeed: Float = 2.0
    let step: Float = 0.25
    
    return stride(from: startSpeed, through: endSpeed, by: step).map(PlaybackSpeed.init)
  }

  init(librarySetting: String?) {
    let speeds = (librarySetting ?? "")
      .split(separator: ",")
      .compactMap { Float($0.trimmingCharacters(in: .whitespaces)) }
      .filter { $0.isFinite && $0 > 0 }
    let unique = Set(speeds).sorted()
    self = unique.isEmpty ? .playbackSpeeds : unique.map(PlaybackSpeed.init)
  }
}
