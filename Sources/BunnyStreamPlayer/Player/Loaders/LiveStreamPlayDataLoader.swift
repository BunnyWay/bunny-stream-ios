import Foundation
import BunnyStreamAPI

public struct LiveStreamPlayDataLoader {
  private let liveStreams: DefaultLiveStreamRepository

  public init(bunnyStreamAPI: BunnyStreamAPI) {
    self.liveStreams = DefaultLiveStreamRepository(bunnyStreamAPI: bunnyStreamAPI)
  }

  /// - Parameters:
  ///   - libraryId: The ID of the video library.
  ///   - streamId: The GUID of the live stream.
  ///   - token: Optional playback token for token-authenticated streams.
  ///   - expires: Expiration timestamp that the token was signed with.
  public func load(
    libraryId: Int,
    streamId: String,
    token: String? = nil,
    expires: Int64? = nil
  ) async throws -> LiveStreamPlayData {
    do {
      let playData = try await liveStreams.fetchPlayData(
        libraryId: libraryId,
        streamId: streamId,
        token: token,
        expires: expires
      )
      return try LiveStreamPlayData(from: playData)
    } catch let error as BunnyLiveStreamError {
      throw VideoPlayerError(error)
    }
  }
}

private extension LiveStreamPlayData {
  init(from playData: BunnyLiveStreamPlayData) throws {
    // The API returns the HLS playlist as `videoPlaylistUrl`; the nested live stream's
    // playback URL is the same value and serves as a fallback. (`fallbackUrl` is an
    // MP4 rendition prefix, not a playable master playlist, so it's not used here.)
    guard let urlString = playData.videoPlaylistUrl ?? playData.liveStream?.playbackUrl,
          let url = URL(string: urlString) else {
      throw VideoPlayerError.notFound
    }

    // The /play endpoint doesn't expose the seekable window directly; derive it from the
    // stream's DVR settings so the player can offer rewind when DVR is enabled.
    let seekableWindow = Double(playData.liveStream?.dvrWindowSeconds ?? 0)

    // Player UI customization configured in the Bunny dashboard, so the live player reflects it.
    let customization = LiveStreamPlayData.PlayerCustomization(
      fontFamily: playData.fontFamily,
      playerKeyColor: playData.playerKeyColor,
      uiLanguage: playData.uiLanguage,
      showHeatmap: playData.showHeatmap,
      enableCompactControls: playData.enableCompactControls,
      controlTokens: playData.controls
    )

    self.init(
      playbackURL: url,
      seekableWindow: seekableWindow,
      isLive: playData.liveStream?.status == .running,
      customization: customization
    )
  }
}

private extension VideoPlayerError {
  init(_ error: BunnyLiveStreamError) {
    switch error.kind {
    case .unauthorized:
      self = .unauthorized
    case .notFound:
      self = .notFound
    case .server:
      self = .internalServerError
    case .invalidRequest, .unprocessable, .transport, .invalidResponse, .unexpected:
      self = .unknownError
    }
  }
}
