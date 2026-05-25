import AVFoundation
import SwiftUI
import BunnyStreamAPI

/// A SwiftUI view that provides a live stream playback experience using BunnyStream.
///
/// `BunnyStreamLivePlayer` handles connecting to a live stream, auto-reconnect on dropout,
/// and DVR playback when the stream supports it.
///
/// ### Usage Example:
/// ```swift
/// BunnyStreamLivePlayer(accessKey: "your_access_key", libraryId: 123, streamId: "stream-guid")
/// ```
public struct BunnyStreamLivePlayer: View {
  @StateObject private var controller: LivePlaybackController
  private let libraryId: Int
  private let streamId: String

  public init(accessKey: String, libraryId: Int, streamId: String) {
    self._controller = StateObject(wrappedValue: LivePlaybackController(
      bunnyStreamAPI: BunnyStreamAPI(accessKey: accessKey),
      libraryId: libraryId,
      streamId: streamId
    ))
    self.libraryId = libraryId
    self.streamId = streamId
  }

  public var body: some View {
    Group {
      switch controller.state {
      case .connecting:
        connectingView
      case .live(let player):
        liveContainerView(player)
      case .offline(let retryIn):
        offlineView(retryIn: retryIn)
      case .error(let error):
        errorView(error)
      }
    }
    .onAppear { controller.start() }
    .onDisappear { controller.stop() }
  }
}

// MARK: - Sub-views

private extension BunnyStreamLivePlayer {
  var connectingView: some View {
    ZStack {
      Color.black
      VStack(spacing: 12) {
        ProgressView().tint(.white)
        Text("Connecting…")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.7))
      }
    }
  }

  func liveContainerView(_ player: MediaPlayer) -> some View {
    let video = Video(
      guid: streamId,
      chaptersList: nil,
      moments: [],
      thumbnailCount: 0,
      width: 0,
      height: 0,
      length: 0,
      captions: [],
      libraryId: libraryId,
      resolutions: [.auto],
      seekPath: nil,
      playlistUrl: nil
    )
    return BunnyStreamPlayerContainerView(player: player, video: video, heatmap: Heatmap(data: [:]))
  }

  func offlineView(retryIn seconds: TimeInterval) -> some View {
    ZStack {
      Color.black
      VStack(spacing: 8) {
        Image(systemName: "antenna.radiowaves.left.and.right.slash")
          .font(.system(size: 40))
          .foregroundStyle(.white.opacity(0.5))
        Text(Lingua.LiveStream.indicatorOffline)
          .font(.headline)
          .foregroundStyle(.white)
        Text("Retrying in \(Int(seconds))s…")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.6))
      }
    }
  }

  func errorView(_ error: Error) -> some View {
    ZStack {
      Color.black
      VStack(spacing: 8) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 40))
          .foregroundStyle(.yellow)
        Text(error.localizedDescription)
          .font(.caption)
          .foregroundStyle(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
    }
  }
}
