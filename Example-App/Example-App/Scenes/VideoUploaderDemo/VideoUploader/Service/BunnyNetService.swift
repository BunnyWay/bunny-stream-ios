//
//  BunnyNetService.swift
//  Example-App
//
//  Created by Egzon Arifi on 16/10/2023.
//

import Foundation
import BunnyStreamSDK

final class BunnyNetService {
  private let bunnyStreamSDK: BunnyStreamSDK
  
  init(bunnyStreamSDK: BunnyStreamSDK) {
    self.bunnyStreamSDK = bunnyStreamSDK
  }
  
  func createVideo(title: String, libraryId: Int) async throws -> String? {
    let output = try await bunnyStreamSDK.Api.Video_CreateVideo(path: .init(libraryId: Int64(libraryId)),
                                                                body: .json(.CreateVideoModel(.init(title: title))))
    switch output {
    case .ok(let okResponse):
      if case .json(let viewModel) = okResponse.body {
        return viewModel.guid
      }
    case .unauthorized:
      throw VideoUploaderError.failedToCreateVideoWithReason(message: "Not authorized to create videos in this library!")
    default:
      throw VideoUploaderError.failedToCreateVideo
    }
    return nil
  }
  
  func deleteVideo(_ videoId: String, libraryId: Int) async throws {
    _ = try await bunnyStreamSDK.Api.Video_DeleteVideo(path: .init(libraryId: Int64(libraryId),
                                                                   videoId: videoId.lowercased()))
  }
}

extension BunnyNetService {
  enum VideoUploaderError: LocalizedError {
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
