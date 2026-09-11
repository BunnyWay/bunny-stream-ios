import SwiftUI

struct BunnyStreamPlayerContainerView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  @Environment(\.videoPlayerConfig) var videoPlayerConfig: VideoPlayerConfig
  @State var player: MediaPlayer
  @StateObject var controlsViewModel: VideoPlayerControlsViewModel
  @StateObject var videoPlayerViewModel: VideoPlayerViewModel
  private var adComponent: MediaPlayerAdComponent
  private let video: Video
  /// Rebuilds playback after a failure. When `nil` (live), no failure overlay is shown — the live
  /// controller recovers on its own.
  private let onRetry: (() -> Void)?

  init(player: MediaPlayer, video: Video, heatmap: Heatmap, onRetry: (() -> Void)? = nil) {
    self.player = player
    self.video = video
    self.onRetry = onRetry
    self._controlsViewModel = StateObject(wrappedValue: VideoPlayerControlsViewModel(player: player,
                                                                                     video: video,
                                                                                     heatmap: heatmap))
    self._videoPlayerViewModel = StateObject(wrappedValue: VideoPlayerViewModel())
    self.adComponent = MediaPlayerAdComponent(player: player)
  }
  
  var body: some View {
#if os(iOS)
    videoPlayerView()
      .fullScreenCover(isPresented: $controlsViewModel.isFullScreen) {
        videoPlayerView()
          .background(Color.black.scaleEffect(controlsViewModel.isFullScreen ? 2 : 0))
      }
#elseif os(macOS)
    videoPlayerView()
      .sheet(isPresented: $controlsViewModel.isFullScreen) {
        videoPlayerView()
      }
#endif
  }
}

private extension BunnyStreamPlayerContainerView {
  func videoPlayerView() -> some View {
    VideoPlayerView(controlsViewModel: controlsViewModel,
                    viewModel: videoPlayerViewModel,
                    adComponent: adComponent,
                    video: video,
                    onRetry: onRetry)
    .environment(\.videoPlayerTheme, theme)
    .environment(\.videoPlayerConfig, videoPlayerConfig)
  }
}
