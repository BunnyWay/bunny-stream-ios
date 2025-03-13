import Foundation
import BunnyStreamAPI

final class VideoCreator {
  private let bunnyStreamAPI: BunnyStreamAPI
  private let libraryId: Int
  
  init(bunnyStreamAPI: BunnyStreamAPI,
       libraryId: Int) {
    self.bunnyStreamAPI = bunnyStreamAPI
    self.libraryId = libraryId
  }
  
  func createVideo() async throws -> String? {
    let output = try await bunnyStreamAPI.client.createVideo(
      path: .init(libraryId: Int64(libraryId)),
      body: .json(.CreateVideoModel(.init(title: "streaming_title")))
    )

    switch output {
    case .ok(let okResponse):
      if case .json(let viewModel) = okResponse.body {
        return viewModel.guid
      }
    case .unauthorized:
      throw VideoCreatorError.failedToCreateVideoWithReason(message: "Not authorized to create videos in this library!")
    default:
      throw VideoCreatorError.failedToCreateVideo
    }
    throw VideoCreatorError.failedToCreateVideo
  }
  
  func deleteVideo(_ videoId: String) async throws {
    _ = try await bunnyStreamAPI.client.deleteVideo(
      path: .init(
        libraryId: Int64(libraryId),
        videoId: videoId.lowercased()
      )
    )
  }
}

extension VideoCreator {
  enum VideoCreatorError: LocalizedError {
    case failedToCreateVideoWithReason(message: String)
    case failedToCreateVideo
    
    public var errorDescription: String? {
      switch self {
      case .failedToCreateVideoWithReason(let message):
        return "An error occurred while creating the video! \nReason: \(message)"
      case .failedToCreateVideo:
        return "An error occurred while creating the video!"
      }
    }
  }
}
