import Foundation

enum StreamState: Equatable {
  case preparing
  case liveStreaming
  case notStreaming

  /// The equivalent value on the public API surface.
  var publicState: BunnyBroadcastState {
    switch self {
    case .preparing:     return .preparing
    case .liveStreaming: return .live
    case .notStreaming:  return .idle
    }
  }
}
