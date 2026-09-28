public enum BunnyStreamPlaybackState: String, Sendable {
  case idle
  case preparing
  case ready
  case playing
  case paused
  case buffering
  case ended
  case failed
}
