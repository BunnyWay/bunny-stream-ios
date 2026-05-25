import Foundation
import BunnyStreamAPI

public struct LiveStreamPlayDataLoader {
  private let bunnyStreamAPI: BunnyStreamAPI

  public init(bunnyStreamAPI: BunnyStreamAPI) {
    self.bunnyStreamAPI = bunnyStreamAPI
  }

  public func load(libraryId: Int, streamId: String) async throws -> LiveStreamPlayData {
    let output = try await bunnyStreamAPI.client.liveStreamGetStreamPlayData(
      path: .init(libraryId: Int64(libraryId), streamId: streamId)
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
    guard let urlString = model.playbackUrl, let url = URL(string: urlString) else {
      throw VideoPlayerError.notFound
    }
    self.init(
      playbackURL: url,
      seekableWindow: model.seekableWindow ?? 0,
      isLive: model.isLive ?? false
    )
  }
}
