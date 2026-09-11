import Foundation

/// What ``BunnyStreamLivePlayer`` is currently showing.
///
/// The player drives itself — it polls the stream and swaps between playback, countdown,
/// trailer and offline on its own. Observe this to keep surrounding UI (titles, share buttons,
/// analytics) in step with it, not to control it.
public enum BunnyLiveStreamPlaybackState: Equatable, Sendable {
  /// Fetching the stream for the first time; nothing is on screen yet.
  case loading
  /// Video is playing.
  /// - Parameter isVodRecording: `true` when this is the recording of a finished stream
  ///   rather than the live edge.
  case playing(isVodRecording: Bool)
  /// The stream is scheduled and the countdown is on screen.
  case countdown(until: Date, title: String?)
  /// A pre-stream trailer is looping while viewers wait.
  case trailer(vodId: String, scheduledStart: Date?, title: String?)
  /// Nothing to play — not started yet, or already ended.
  case offline(message: String)
  /// Playback can't proceed. Polling has stopped.
  case failed(message: String)

  /// Whether video is on screen, live or recorded.
  public var isPlaying: Bool {
    if case .playing = self { return true }
    return false
  }
}
