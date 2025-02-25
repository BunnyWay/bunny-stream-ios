import Foundation
import BunnyStreamSDK

final class VideoCreator {
  private let bunnyStreamSDK: BunnyStreamSDK
  private let libraryId: Int
  
  init(bunnyStreamSDK: BunnyStreamSDK,
       libraryId: Int) {
    self.bunnyStreamSDK = bunnyStreamSDK
    self.libraryId = libraryId
  }
  
  func createVideo() async throws -> String? {
    let output = try await bunnyStreamSDK.Api.Video_CreateVideo(path: .init(libraryId: Int64(libraryId)),
                                                                body: .json(.CreateVideoModel(.init(title: "streaming_title"))))
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
    _ = try await bunnyStreamSDK.Api.Video_DeleteVideo(path: .init(libraryId: Int64(libraryId),
                                                                   videoId: videoId.lowercased()))
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
