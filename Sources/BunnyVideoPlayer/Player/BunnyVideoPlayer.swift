import AVFoundation
import SwiftUI

public struct BunnyVideoPlayer: View {
  let videoPlayerConfigLoader = VideoPlayerConfigLoader()
  let heatmapLoader: HeatmapLoader
  let accessKey: String
  let videoId: String
  let libraryId: Int
  let cdn: String
  @State private var loadingState: VideoLoadingState = .loading
  @State var player: MediaPlayer?
  @State var theme: VideoPlayerTheme = .defaultTheme
  @State var videoConfig = VideoPlayerConfig()
  internal var playerIcons: PlayerIcons?
  
  enum VideoLoadingState {
    case loading, loaded(MediaPlayer, Video, Heatmap), failed, loaderFailed(VideoPlayerError)
  }
  
  public var body: some View {
    VStack(alignment: .center) {
      switch loadingState {
      case .loading:
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      case .loaded(let mediaPlayer, let video, let heatmap):
        BunnyVideoPlayerContainerView(player: mediaPlayer, video: video, heatmap: heatmap)
          .environment(\.videoPlayerTheme, theme)
          .environment(\.videoPlayerConfig, videoConfig)
          .onAppear {
            setupAudioSession()
            mediaPlayer.play()
          }
      case .failed:
        reloadButton()
      case .loaderFailed(let error):
        switch error {
        case .notFound:
          VStack(spacing: 8) {
            theme.images.videoNotFound
              .resizable()
              .scaledToFill()
              .frame(width: 40, height: 40)
            Text(Lingua.Player.videoNotFound)
              .font(theme.font.size(11))
          }
        case .audioError:
          VStack(spacing: 8) {
            Text(Lingua.Error.audioError)
              .font(theme.font.size(13))
            reloadButton()
          }
        default:
          reloadButton()
        }
      }
    }
    .task {
      await loadVideo()
    }
    .onDisappear {
      player?.pause()
    }
  }
  
  @MainActor
  func loadVideo() async {
    loadingState = .loading
    do {
      let videoConfigResponse = try await videoPlayerConfigLoader.load(libraryId: libraryId, videoId: videoId)
      var video = Video(videoConfigResponse: videoConfigResponse.video, cdn: cdn)
      let heatmap = try? await heatmapLoader.loadHeatmap(videoId: videoId, libraryId: libraryId, cdn: cdn)
      VideoPlayerConfig(response: videoConfigResponse).map { self.videoConfig = $0 }
      let player = MediaPlayer.make(video: video)
      self.player = player
      video.adjustLength(player.duration)
      self.theme = VideoPlayerTheme(config: videoConfigResponse) ?? theme
      if let playerIcons {
        self.theme.images = playerIcons
      }
      loadingState = .loaded(player, video, heatmap ?? Heatmap(data: [:]))
    } catch let error as VideoPlayerError {
      loadingState = .loaderFailed(error)
    } catch {
      loadingState = .failed
    }
  }
}

private extension BunnyVideoPlayer {
  func reloadButton() -> some View {
    Button {
      Task { await loadVideo() }
    } label: {
      theme.images.reload
        .resizable()
        .scaledToFill()
        .frame(width: 40, height: 40)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  
  func setupAudioSession() {
#if os(iOS)
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .moviePlayback, options: [])
      try session.setActive(true)
    } catch {
      player?.stop()
      loadingState = .loaderFailed(.audioError)
    }
#endif
  }
}
