import Foundation

extension Video {
  enum Resolution: String, Identifiable, Equatable {
    var id: Self {
      self
    }
    
    case auto = "0"
    case res240p = "240p"
    case res360p = "360p"
    case res480p = "480p"
    case res720p = "720p"
    case res1080p = "1080p"
    
    var label: String {
      switch self {
      case .auto:
        return Lingua.Settings.qualityAuto
      default:
        return self.rawValue
      }
    }
    
    var bitrate: Double {
      switch self {
      case .auto:
        return 0
      case .res240p:
        return 600000
      case .res360p:
        return 800000
      case .res480p:
        return 1400000
      case .res720p:
        return 2800000
      case .res1080p:
        return 5000000
      }
    }
  }
}
