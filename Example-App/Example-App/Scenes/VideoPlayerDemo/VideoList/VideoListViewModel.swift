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
  /// Keyed by video id — a `VideoResponseInfo` key would miss on every refresh, since its
  /// synthesized `==` also compares `encodeProgress`, `views` and friends.
  @Published var thumbnails: [String: URL] = [:]
  /// Videos whose thumbnail lookup failed often enough that we stopped asking.
  @Published private var thumbnailUnavailable: Set<String> = []
  private var thumbnailAttempts: [String: Int] = [:]
  private var thumbnailsInFlight: Set<String> = []
  /// Retries allowed once the video finished encoding — before that a missing thumbnail is
  /// expected, so the attempts don't count.
  private let maxThumbnailAttempts = 3

  /// How often the list re-polls while a video is still encoding.
  private let pollInterval: Duration = .seconds(5)
  private var pollTask: Task<Void, Never>?
  
  enum LoadingState {
    case loading, loaded, failed(String)
  }

  /// What a row should draw in place of its thumbnail.
  enum ThumbnailState {
    /// The lookup is in flight — a spinner is warranted.
    case loading
    case ready(URL)
    /// Nothing to wait for: the video is still encoding, or the lookup gave up.
    case unavailable
  }
  
  init(
    bunnyStreamAPI: BunnyStreamAPI,
    videoPlayerConfigLoader: VideoPlayerConfigLoader = .init()
  ) {
    self.bunnyStreamAPI = bunnyStreamAPI
    self.videoPlayerConfigLoader = videoPlayerConfigLoader
  }
  
  /// - Parameter showLoadingState: when false, keeps the current list on screen instead of
  ///   swapping to the full-screen spinner. Used for pull-to-refresh and the encoding poll —
  ///   flipping to `.loading` tears the ScrollView out of the hierarchy, loses the scroll
  ///   position and re-triggers every row's thumbnail task.
  func loadVideos(libraryId: Int64, showLoadingState: Bool = true) async {
    do {
      if showLoadingState {
        loadingState = .loading
      }
      let output = try await bunnyStreamAPI.client.listVideos(path: .init(libraryId: libraryId))
      handle(output: output)
      loadMissingThumbnails()
      startPollingIfNeeded(libraryId: libraryId)
    } catch {
      loadingState = .failed(error.localizedDescription)
    }
  }

  /// Stops the encoding poll. Called when the screen goes away so nothing keeps hitting the API
  /// in the background.
  func stopPolling() {
    pollTask?.cancel()
    pollTask = nil
  }

  /// True while at least one video is mid-pipeline. Failed encodes don't count — they never
  /// settle, and polling for them would never stop.
  var isEncodingInProgress: Bool {
    videoInfos.contains { $0.encodingState == .processing }
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
  
  func thumbnailState(for video: VideoResponseInfo) -> ThumbnailState {
    if let url = thumbnails[video.id] {
      return .ready(url)
    }
    // A video mid-encode has no thumbnail yet, so a spinner would just spin until the encoder
    // catches up — the poll swaps in the real image as soon as `/play` hands one over.
    if thumbnailUnavailable.contains(video.id) || !video.isEncodingCompleted {
      return .unavailable
    }
    return .loading
  }

  @MainActor
  func loadThumbnailIfNeeded(_ video: VideoResponseInfo) async {
    guard thumbnails[video.id] == nil,
          !thumbnailUnavailable.contains(video.id),
          !thumbnailsInFlight.contains(video.id) else {
      return
    }
    thumbnailsInFlight.insert(video.id)
    defer { thumbnailsInFlight.remove(video.id) }
    
    do {
      let thumbnailUrl = try await videoPlayerConfigLoader.loadVideoThumbnail(
        libraryId: Int(video.libraryId),
        videoId: video.id
      )
      guard let url = URL(string: thumbnailUrl) else {
        registerThumbnailFailure(for: video)
        return
      }
      thumbnailAttempts[video.id] = nil
      thumbnails[video.id] = url
    } catch {
      registerThumbnailFailure(for: video)
    }
  }
}

// MARK: - Private
private extension VideoListViewModel {
  /// Re-polls the list while any video is still encoding, so a freshly uploaded video flips from
  /// "Processing" to playable on its own — without leaving and re-entering the screen. The loop
  /// ends by itself once everything has settled, and holds `self` weakly so a popped screen's
  /// view model still deallocates.
  func startPollingIfNeeded(libraryId: Int64) {
    guard pollTask == nil, isEncodingInProgress else { return }
    pollTask = Task { [weak self] in
      while let self, self.isEncodingInProgress {
        do {
          try await Task.sleep(for: self.pollInterval)
        } catch {
          break // cancelled
        }
        await self.loadVideos(libraryId: libraryId, showLoadingState: false)
      }
      // Only clear the handle when the loop ended on its own — on cancellation `stopPolling()`
      // already did, and may have handed the slot to a newer task.
      if !Task.isCancelled {
        self?.pollTask = nil
      }
    }
  }

  /// Re-attempts every thumbnail that is still missing. A row's `.task` fires only once, when the
  /// row first appears, so without this a lookup that failed while the video was still encoding
  /// would never be retried — the row would keep its placeholder even after the video went live.
  func loadMissingThumbnails() {
    for video in videoInfos where thumbnails[video.id] == nil && !thumbnailUnavailable.contains(video.id) {
      Task { await loadThumbnailIfNeeded(video) }
    }
  }

  /// `/play` legitimately has no thumbnail for a video that is still encoding, so only a finished
  /// video burns retries — and once they run out the row settles on a placeholder.
  func registerThumbnailFailure(for video: VideoResponseInfo) {
    guard video.isEncodingCompleted else {
      thumbnailAttempts[video.id] = nil
      return
    }
    let attempts = (thumbnailAttempts[video.id] ?? 0) + 1
    thumbnailAttempts[video.id] = attempts
    if attempts >= maxThumbnailAttempts {
      thumbnailUnavailable.insert(video.id)
    }
  }

  /// Unwraps the generated one-of wrapper around `VideoModelStatus` into its raw value.
  static func statusValue(_ payload: Components.Schemas.VideoModel.StatusPayload?) -> Int32? {
    guard case let .VideoModelStatus(status) = payload else { return nil }
    return Int32(status.rawValue)
  }

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
                            status: Self.statusValue($0.status),
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
