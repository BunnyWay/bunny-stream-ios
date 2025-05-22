import SwiftUI
import AVKit

struct VideoPlayerView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  @Environment(\.videoPlayerConfig) var videoPlayerConfig: VideoPlayerConfig
  @ObservedObject var controlsViewModel: VideoPlayerControlsViewModel
  @ObservedObject var viewModel: VideoPlayerViewModel
  private var adComponent: MediaPlayerAdComponent
  private let video: Video
  
  init(controlsViewModel: VideoPlayerControlsViewModel,
       viewModel: VideoPlayerViewModel,
       adComponent: MediaPlayerAdComponent,
       video: Video) {
    self.controlsViewModel = controlsViewModel
    self.viewModel = viewModel
    self.adComponent = adComponent
    self.video = video
  }
  
  var body: some View {
    VStack {
      AVPlayerViewControllerRepresentable(player: controlsViewModel.player) { controller in
        guard videoPlayerConfig.hasAds else { return }
        adComponent.setupAdsInController(controller)
      }
      .overlay {
        if !controlsViewModel.isAdPlaying {
          ZStack {
            VStack {
              Spacer()
              CaptionsView(captions: controlsViewModel.captions,
                           backgroundColor: theme.caption.backgroundColor,
                           fontColor: theme.caption.fontColor,
                           font: theme.font.size(theme.caption.fontSize))
                .padding(.bottom, viewModel.isVisible ? 50 : 0)
            }
            VideoPlayerControls(viewModel: controlsViewModel)
              .opacity(viewModel.isVisible ? 1 : 0)
              .background(Color.black.opacity(viewModel.isVisible ? 0.3 : 0.001))
              .environment(\.videoPlayerTheme, theme)
              .environment(\.videoPlayerConfig, videoPlayerConfig)
          }
        }
      }
      .onTapGesture {
        viewModel.toggleControlsVisibility()
      }
      .onChange(of: controlsViewModel.isPlaying, perform: viewModel.isPlayingChange)
      .onChange(of: controlsViewModel.isMuted, perform: viewModel.resetControlsHideTimer)
      .onChange(of: controlsViewModel.isDraggingSeekBar, perform: viewModel.isDraggingSeekBarChange)
      .onChange(of: controlsViewModel.isFullScreen, perform: viewModel.resetControlsHideTimer)
      .onChange(of: controlsViewModel.playbackState, perform: viewModel.playBackStateChange)
      .onAppear {
        viewModel.resetControlsHideTimer()
      }
    }
    .onChange(of: controlsViewModel.playbackState) { newState in
      if newState == .playing, let tagUrl = videoPlayerConfig.vastTagUrl {
        adComponent.requestAds(adTagUrl: tagUrl)
      }
    }
    .onAppear {
      adComponent.onAdPlaybackChanged = { isPlaying in
        controlsViewModel.isAdPlaying = isPlaying
      }
    }
    .onDisappear {
      adComponent.destroy()
    }
  }
}
