import Foundation
import BunnyStreamAPI

public struct LiveStreamPlayDataLoader {
  private let bunnyStreamAPI: BunnyStreamAPI

  public init(bunnyStreamAPI: BunnyStreamAPI) {
    self.bunnyStreamAPI = bunnyStreamAPI
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
    let output = try await bunnyStreamAPI.client.liveStreamGetStreamPlayData(
      path: .init(libraryId: Int64(libraryId), streamId: streamId),
      query: .init(token: token, expires: expires)
    )

    switch output {
    case .ok(let okResponse):
      if case .json(let model) = okResponse.body {
        return try LiveStreamPlayData(from: model)
      }
      throw VideoPlayerError.unknownError
    case .unauthorized:
      throw VideoPlayerError.unauthorized
    case .notFound:
      throw VideoPlayerError.notFound
    case .internalServerError:
      throw VideoPlayerError.internalServerError
    default:
      throw VideoPlayerError.unknownError
    }
  }
}

private extension LiveStreamPlayData {
  init(from model: Components.Schemas.LiveStreamPlayDataModel) throws {
    let live = model.liveStream

    // The API returns the HLS playlist as `videoPlaylistUrl`; the nested live stream's
    // `playbackUrlHls` is the same value and serves as a fallback. (`fallbackUrl` is an
    // MP4 rendition prefix, not a playable master playlist, so it's not used here.)
    guard let urlString = model.videoPlaylistUrl ?? live?.playbackUrlHls,
          let url = URL(string: urlString) else {
      throw VideoPlayerError.notFound
    }

    // The /play endpoint doesn't expose the seekable window directly; derive it from the
    // nested live stream's DVR settings so the player can offer rewind when DVR is enabled.
    let seekableWindow: Double = {
      guard live?.dvrEnabled == true, let seconds = live?.dvrWindowSeconds else { return 0 }
      return Double(seconds)
    }()

    let isLive: Bool = {
      guard let status = live?.status, case .LiveStreamStatus(let value) = status else { return false }
      return value == .running
    }()

    // Player UI customization configured in the Bunny dashboard, so the live player reflects it.
    let customization = LiveStreamPlayData.PlayerCustomization(
      fontFamily: model.fontFamily,
      playerKeyColor: model.playerKeyColor,
      uiLanguage: model.uiLanguage,
      showHeatmap: model.showHeatmap ?? false,
      enableCompactControls: model.enableCompactControls ?? false,
      controlTokens: model.controls?
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty } ?? []
    )

    self.init(playbackURL: url, seekableWindow: seekableWindow, isLive: isLive, customization: customization)
  }
}
