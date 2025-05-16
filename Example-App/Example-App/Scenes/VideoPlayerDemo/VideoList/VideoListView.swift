//
//  VideoListView.swift
//  Example-App
//
//  Created by Egzon Arifi on 06/10/2023.
//

import SwiftUI

struct VideoListView: View {
  @EnvironmentObject var dependenciesManager: DependenciesManager
  @ObservedObject private var viewModel: VideoListViewModel
  @State private var selectedVideoInfo: VideoResponseInfo? = nil
  
  init(viewModel: VideoListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationStack {
      switch viewModel.loadingState {
      case .loading:
        ProgressView()
          .frame(maxWidth: .infinity)
      case .loaded:
        ScrollView {
          LazyVStack {
            ForEach(viewModel.videoInfos) { videoInfo in
              Button {
                selectedVideoInfo = videoInfo
              } label: {
                VideoListRow(
                  video: videoInfo,
                  thumbnailURL: viewModel.thumbnails[videoInfo]
                )
              }
              .task {
                await viewModel.loadThumbnailIfNeeded(videoInfo)
              }
              .disabled(!videoInfo.isEncodingCompleted)
            }
          }
          .padding(.vertical, 12)
        }
      case .failed(let string):
        Text(string)
      }
    }
    .navigationTitle("Video List")
    .task {
      await viewModel.loadVideos(libraryId: Int64(dependenciesManager.libraryId))
    }
    .sheet(item: $selectedVideoInfo) { videoInfo in
      VideoPlayerDemoView(
        dependenciesManager: dependenciesManager,
        videoInfo: videoInfo,
        deleteVideoCallback: {
          selectedVideoInfo = nil
          Task { @MainActor in
            await viewModel.deleteVideo(videoInfo)
          }
        }
      )
    }
  }
}
