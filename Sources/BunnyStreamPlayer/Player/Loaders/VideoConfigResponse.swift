import Foundation

struct VideoConfigResponse: Decodable {
  var video: Video
  var captionsFontSize: Int
  var captionsFontColor: String
  var captionsBackground: String
  var playerKeyColor: String
  var fontFamily: String
  var vastTagUrl: String?
  var showHeatmap: Bool
  var controls: Controls
  var enableDRM: Bool
  var thumbnailUrl: String
  var videoPlaylistUrl: String
  var captionsPath: String?
  var seekPath: String?
}

extension VideoConfigResponse {
  struct Video: Decodable {
    var guid: String
    var videoLibraryId: Int
    var chapters: [Chapter]
    var moments: [Moment]
    var thumbnailCount: Int
    var width: Float
    var height: Float
    var length: Double
    var captions: [Caption]
    let availableResolutions: String
  }
  
  struct Caption: Decodable {
    var srclang: String
    var label: String
  }
  
  struct Chapter: Decodable {
    var title: String
    var start: Double
    var end: Double
  }
  
  struct Moment: Decodable {
    var label: String
    var timestamp: UInt
  }
  
  enum Control: String, Decodable, CaseIterable, Equatable {
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
  
  struct Controls: Decodable {
    var controlList: [Control]
    
    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let controlsString = try container.decode(String.self)
      self.controlList = controlsString.split(separator: ",").compactMap { Control(rawValue: String($0)) }
    }
  }
}
