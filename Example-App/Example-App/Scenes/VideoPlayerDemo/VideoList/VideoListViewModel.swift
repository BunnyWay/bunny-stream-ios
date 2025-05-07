//
//  VideoListViewModel.swift
//  Example-App
//
//  Created by Egzon Arifi on 06/10/2023.
//

import Foundation
import BunnyStreamAPI
import BunnyStreamPlayer
import SwiftUI

@MainActor
class VideoListViewModel: ObservableObject {
  let bunnyStreamAPI: BunnyStreamAPI
  let videoPlayerConfigLoader: VideoPlayerConfigLoader
  @Published var videoInfos: [VideoResponseInfo] = []
  @Published var loadingState: LoadingState = .loading
  @Published var thumbnails: [VideoResponseInfo: URL] = [:]
  
  enum LoadingState {
    case loading, loaded, failed(String)
  }
  
  init(
    bunnyStreamAPI: BunnyStreamAPI,
    videoPlayerConfigLoader: VideoPlayerConfigLoader = .init()
  ) {
    self.bunnyStreamAPI = bunnyStreamAPI
    self.videoPlayerConfigLoader = videoPlayerConfigLoader
  }
  
  func loadVideos(libraryId: Int64) async {
    do {
      loadingState = .loading
      let output = try await bunnyStreamAPI.client.listVideos(path: .init(libraryId: libraryId))
      handle(output: output)
    } catch {
      loadingState = .failed(error.localizedDescription)
    }
  }
  
  func deleteVideo(_ video: VideoResponseInfo) async {
    do {
      let result = try await bunnyStreamAPI.client.deleteVideo(path: .init(
        libraryId: video.libraryId,
        videoId: video.id
      ))
      switch result {
      case .ok:
        if let index = videoInfos.firstIndex(where: { $0.id == video.id }) {
          withAnimation {
            _ = videoInfos.remove(at: index)
          }
        }
      case _:
        break
      }
    } catch {
      ///
    }
  }
  
  @MainActor
  func loadThumbnailIfNeeded(_ video: VideoResponseInfo) async {
    if thumbnails[video] != nil {
      return
    }
    
    do {
      let thumbnailUrl = try await videoPlayerConfigLoader.loadVideoThumbnail(
        libraryId: Int(video.libraryId),
        videoId: video.id
      )
      guard let url = URL(string: thumbnailUrl) else {
        return
      }
      thumbnails[video] = url
    } catch {
      ///
    }
  }
}

// MARK: - Private
private extension VideoListViewModel {
  private func handle(output: Operations.listVideos.Output) {
    switch output {
    case .ok(let okResponse):
      switch okResponse.body {
      case .json(let viewModel):
        guard let items = viewModel.items else { return }
        videoInfos = items.map {
          VideoResponseInfo(id: $0.guid ?? "",
                            title: $0.title,
                            thumbnailCount: $0.thumbnailCount ?? .zero,
                            width: Float($0.width ?? .zero),
                            height: Float($0.height ?? .zero),
                            length: $0.length ?? .zero,
                            libraryId: $0.videoLibraryId ?? .zero,
                            encodeProgress: $0.encodeProgress ?? .zero,
                            storageSize: Double($0.storageSize ?? .zero),
                            thumbnailFileName: $0.thumbnailFileName,
                            averageWatchTime: $0.averageWatchTime ?? .zero,
                            views: Int($0.views ?? .zero))
        }
        withAnimation {
          loadingState = .loaded
        }
      }
    case .undocumented(statusCode: let statusCode, _):
      loadingState = .failed("🥺 undocumented response: \(statusCode)")
    case .unauthorized:
      loadingState = .failed("Unauthorized")
    case .internalServerError(_):
      loadingState = .failed("Internal Server Error")
    }
  }
}
