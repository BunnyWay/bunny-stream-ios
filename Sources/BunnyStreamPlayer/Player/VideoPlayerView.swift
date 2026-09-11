import SwiftUI
import AVKit

struct VideoPlayerView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  @Environment(\.videoPlayerConfig) var videoPlayerConfig: VideoPlayerConfig
  @Environment(\.playerWatermark) var watermark: PlayerWatermark?
  @ObservedObject var controlsViewModel: VideoPlayerControlsViewModel
  @ObservedObject var viewModel: VideoPlayerViewModel
  @StateObject private var pipManager = PictureInPictureManager()
  private var adComponent: MediaPlayerAdComponent
  private let video: Video
  private let onRetry: (() -> Void)?

  init(controlsViewModel: VideoPlayerControlsViewModel,
       viewModel: VideoPlayerViewModel,
       adComponent: MediaPlayerAdComponent,
       video: Video,
       onRetry: (() -> Void)? = nil) {
    self.controlsViewModel = controlsViewModel
    self.viewModel = viewModel
    self.adComponent = adComponent
    self.video = video
    self.onRetry = onRetry
  }

  /// The playback error to show over the player, if any. Only when a retry path exists (VOD) —
  /// live recovers from player failures itself and must not be covered.
  private var playbackFailure: Error? {
    guard onRetry != nil, case .failed(let error) = controlsViewModel.playbackState else { return nil }
    return error
  }
  
  var body: some View {
    VStack {
      AVPlayerViewControllerRepresentable(player: controlsViewModel.player, pipManager: pipManager) { controller in
        guard videoPlayerConfig.hasAds else { return }
        adComponent.setupAdsInController(controller)
      }
      .overlay {
        if !controlsViewModel.isAdPlaying, playbackFailure == nil {
          ZStack {
            VStack {
              Spacer()
              CaptionsView(captions: controlsViewModel.captions,
                           backgroundColor: theme.caption.backgroundColor,
                           fontColor: theme.caption.fontColor,
                           font: theme.font.size(theme.caption.fontSize))
                .padding(.bottom, viewModel.isVisible ? 50 : 0)
            }
            VideoPlayerControls(viewModel: controlsViewModel, pipManager: pipManager)
              .opacity(viewModel.isVisible ? 1 : 0)
              .background(Color.black.opacity(viewModel.isVisible ? 0.3 : 0.001))
              .environment(\.videoPlayerTheme, theme)
              .environment(\.videoPlayerConfig, videoPlayerConfig)
          }
        }
      }
      .overlay {
        if let watermark, !controlsViewModel.isAdPlaying {
          WatermarkOverlayView(watermark: watermark)
        }
      }
      .overlay {
        if let playbackFailure, let onRetry {
          PlaybackFailureView(error: playbackFailure, onRetry: onRetry)
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
      // The failure overlay hides the controls, including the fullscreen toggle, so leave
      // fullscreen rather than trap the viewer behind the cover. Assign, don't toggle: this fires
      // in both the embedded and the fullscreen instance of this view.
      if playbackFailure != nil, controlsViewModel.isFullScreen {
        controlsViewModel.isFullScreen = false
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
