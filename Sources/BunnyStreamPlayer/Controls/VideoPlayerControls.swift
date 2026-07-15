import SwiftUI
import AVKit
import Combine
#if canImport(UIKit)
import UIKit
#endif

struct VideoPlayerControls: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  @Environment(\.videoPlayerConfig) var videoPlayerConfig: VideoPlayerConfig
  @ObservedObject private var viewModel: VideoPlayerControlsViewModel
  @ObservedObject private var pipManager: PictureInPictureManager
  @State private var airPlayView = AirPlayView()

  init(viewModel: VideoPlayerControlsViewModel, pipManager: PictureInPictureManager) {
    self.viewModel = viewModel
    self.pipManager = pipManager
  }
  
  var body: some View {
    GeometryReader { proxy in
    VStack {
      topControlsView()
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .opacity(viewModel.isDraggingSeekBar ? 0 : 1)

      Spacer()

      centerControlsView()
        .opacity(viewModel.isDraggingSeekBar ? 0 : 1)

      Spacer()

      bottomControlsView()
    }
    // Keep controls clear of the notch / home-indicator when the player is edge-to-edge (fullscreen
    // or full-screen presented). `proxy.safeAreaInsets` reads 0 here because the underlying video
    // layer ignores the safe area, so we read the real window insets and apply them only on the
    // edges the player actually reaches — an embedded, inset player gets no extra padding.
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(edgeSafeAreaPadding(in: proxy))
    .confirmationDialog(Lingua.Settings.actionsTitle, isPresented: $viewModel.isOptionsMenuActive) {
      mainOptionsDialog()
    }
    .confirmationDialog(Lingua.Settings.captionMenuTitle,
                        isPresented: $viewModel.captionsMenuViewModel.showCaptions,
                        titleVisibility: .visible) {
      CaptionsMenuView(viewModel: viewModel.captionsMenuViewModel)
        .environment(\.videoPlayerTheme, theme)
    }
    .confirmationDialog(Lingua.Settings.playbackSpeedMenuTitle,
                        isPresented: $viewModel.playbackSpeedViewModel.showPlaybackSpeed,
                        titleVisibility: .visible) {
      PlaybackSpeedView(viewModel: viewModel.playbackSpeedViewModel)
        .environment(\.videoPlayerTheme, theme)
    }
    .confirmationDialog(Lingua.Settings.qualityMenuTitle,
                        isPresented: $viewModel.resolutionsViewModel.showResolutions,
                        titleVisibility: .visible) {
      ResolutionsView(viewModel: viewModel.resolutionsViewModel)
        .environment(\.videoPlayerTheme, theme)
    }
    .confirmationDialog(Lingua.Settings.audioTrackMenuTitle,
                        isPresented: $viewModel.audioTracksViewModel.showAudioTracks,
                        titleVisibility: .visible) {
      AudioTracksView(viewModel: viewModel.audioTracksViewModel)
        .environment(\.videoPlayerTheme, theme)
      }
    .foregroundColor(theme.tintColor)
    }
  }
}

// MARK: - Views
extension VideoPlayerControls {
  func topControlsView() -> some View {
    HStack {
      liveBadgeView()
        .shouldAddView(viewModel.isLive)
      Spacer()
      fullScreenButton()
        .shouldAddView(controlsToCheck: .fullScreen, in: videoPlayerConfig.controls)
    }
  }
  
  func centerControlsView() -> some View {
    HStack {
      Spacer()
      
      Button(action: viewModel.skipBackward) {
        theme.images.seekBackward
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 30)
          .foregroundColor(.white)
      }
      .shouldAddView(controlsToCheck: .rewind, in: videoPlayerConfig.controls)
      .shouldAddView(!viewModel.isLiveWithoutDVR)

      Spacer()

      Button(action: viewModel.togglePlayPause) {
        (viewModel.isPlaying ? theme.images.pause : theme.images.play)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 40, height: 40)
          .foregroundColor(.white)
      }
      .shouldAddView(controlsToCheck: .play, in: videoPlayerConfig.controls)
      
      Spacer()
      
      Button(action: viewModel.skipForward) {
        theme.images.seekForward
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 30)
          .foregroundColor(.white)
      }
      .shouldAddView(controlsToCheck: .fastForward, in: videoPlayerConfig.controls)
      .shouldAddView(!viewModel.isLiveWithoutDVR)

      Spacer()
    }
  }
  
  func bottomControlsView() -> some View {
    VStack {
      seekBarView()
        .shouldAddView(controlsToCheck: .progress, in: videoPlayerConfig.controls)
        .shouldAddView(!viewModel.isLiveWithoutDVR)
      
      HStack {
        timeView()
          .shouldAddView(!viewModel.isLive)
        goToLiveButton()
          .shouldAddView(viewModel.isLive && !viewModel.isAtLiveEdge)
        Spacer()
        captionsButton()
          .shouldAddView(!viewModel.captionsMenuViewModel.captions.isEmpty)
          .shouldAddView(controlsToCheck: .captions, in: videoPlayerConfig.controls)

        optionsButton()
          .shouldAddView(controlsToCheck: .settings, in: videoPlayerConfig.controls)
        pipButton()
          .shouldAddView(pipManager.isSupported)
          .shouldAddView(controlsToCheck: .pip, in: videoPlayerConfig.controls)
        airplayButton()
          .shouldAddView(controlsToCheck: .airplay, in: videoPlayerConfig.controls)
        volumeButton()
          .shouldAddView(controlsToCheck: .mute, in: videoPlayerConfig.controls)
      }
      .padding(.horizontal, 8)
    }
  }
  
  func fullScreenButton() -> some View {
    Button(action: viewModel.toggleFullScreenMode) {
      (viewModel.isFullScreen ? theme.images.fullscreenExpanded : theme.images.fullscreenCollapsed)
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
        .foregroundColor(.white)
    }
  }
  
  func pipButton() -> some View {
    Button(action: pipManager.toggle) {
      (pipManager.isActive ? theme.images.pictureInPictureActive : theme.images.pictureInPicture)
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
        .foregroundColor(.white)
    }
  }

  func volumeButton() -> some View {
    Button(action: viewModel.toggleMute) {
      (viewModel.isMuted ? theme.images.volumeOff : theme.images.volumeOn)
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
        .foregroundColor(.white)
    }
  }
  
  @ViewBuilder
  func optionsButton() -> some View {
    Button {
      viewModel.isOptionsMenuActive = true
    } label: {
      theme.images.settings
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
        .foregroundColor(.white)
    }
  }
  
  @ViewBuilder
  private func mainOptionsDialog() -> some View {
    Button(Lingua.Settings.audioTrackMenuTitle) {
      viewModel.isOptionsMenuActive = false
      viewModel.audioTracksViewModel.showAudioTracks = true
    }
    .shouldAddView(viewModel.audioTracksViewModel.audioTracks.count > 1)
    .foregroundColor(theme.tintColor)

    Button(Lingua.Settings.captionMenuTitle) {
      viewModel.isOptionsMenuActive = false
      viewModel.captionsMenuViewModel.showCaptions = true
    }
    .shouldAddView(!viewModel.captionsMenuViewModel.captions.isEmpty)
    .shouldAddView(controlsToCheck: .captions, in: videoPlayerConfig.controls)
    .foregroundColor(theme.tintColor)
    
    Button(Lingua.Settings.qualityMenuTitle) {
      viewModel.isOptionsMenuActive = false
      viewModel.resolutionsViewModel.showResolutions = true
    }
    .shouldAddView(!viewModel.resolutionsViewModel.availableResolutions.isEmpty)
    .foregroundColor(theme.tintColor)
    
    Button(Lingua.Settings.playbackSpeedMenuTitle) {
      viewModel.isOptionsMenuActive = false
      viewModel.playbackSpeedViewModel.showPlaybackSpeed = true
    }
    .foregroundColor(theme.tintColor)
    
    Button(Lingua.Settings.cancelAction, role: .cancel) {
      viewModel.isOptionsMenuActive = false
    }
    .foregroundColor(theme.tintColor)
  }
  
  func airplayButton() -> some View {
    Button(action: {
      airPlayView.showAirPlayMenu()
    }) {
      airPlayView
    }
    .buttonStyle(PlainButtonStyle())
    .frame(width: 40, height: 40)
  }
  
  func captionsButton() -> some View {
    Button {
      viewModel.captionsMenuViewModel.toggleCaptions()
    } label: {
      (viewModel.captionsMenuViewModel.enableCaptions ? theme.images.captionsEnabled : theme.images.captions)
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
        .foregroundColor(.white)
    }
  }
  
  func liveBadgeView() -> some View {
    HStack(spacing: 4) {
      Circle()
        .fill(viewModel.isAtLiveEdge ? Color.red : Color.gray)
        .frame(width: 8, height: 8)
      Text(Lingua.LiveStream.indicatorLive)
        .font(.caption.bold())
        .foregroundColor(.white)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(Capsule().fill(Color.black.opacity(0.5)))
  }

  func goToLiveButton() -> some View {
    Button(action: viewModel.snapToLiveEdge) {
      Text(Lingua.LiveStream.indicatorLive)
        .font(.caption.bold())
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.red))
    }
  }

  func seekBarView() -> some View {
    SeekBarView(viewModel: viewModel.seekBarViewModel, isDraggingOutside: $viewModel.isDraggingSeekBar)
      .environment(\.videoPlayerConfig, videoPlayerConfig)
      .padding(.bottom, -16)
  }
  
  func timeView() -> some View {
    HStack(spacing: 0) {
      Text(viewModel.currentFormattedTime)
        .font(theme.font.size(11))
        .foregroundColor(.white)
        .shouldAddView(controlsToCheck: .currentTime, in: videoPlayerConfig.controls)
      
      Text(" / ")
        .font(.caption)
        .foregroundColor(.white)
        .shouldAddView(controlsToCheck: .currentTime, .duration, in: videoPlayerConfig.controls)
      
      Text(viewModel.totalFormattedTime)
        .font(theme.font.size(11))
        .foregroundColor(.white)
        .shouldAddView(controlsToCheck: .duration, in: videoPlayerConfig.controls)
    }
  }
}

// MARK: - Safe-area padding for edge-to-edge playback

private extension VideoPlayerControls {
  /// Window insets applied only on the edges the controls overlay actually reaches, so an
  /// edge-to-edge (fullscreen / full-screen presented) player keeps its controls off the notch and
  /// home-indicator, while an embedded, already-inset player is left untouched.
  func edgeSafeAreaPadding(in proxy: GeometryProxy) -> EdgeInsets {
    #if os(iOS)
    guard let window = keyWindow else { return EdgeInsets() }
    let insets = window.safeAreaInsets
    let frame = proxy.frame(in: .global)
    let bounds = window.bounds
    let tolerance: CGFloat = 1
    return EdgeInsets(
      top: frame.minY <= bounds.minY + tolerance ? insets.top : 0,
      leading: frame.minX <= bounds.minX + tolerance ? insets.left : 0,
      bottom: frame.maxY >= bounds.maxY - tolerance ? insets.bottom : 0,
      trailing: frame.maxX >= bounds.maxX - tolerance ? insets.right : 0
    )
    #else
    return EdgeInsets()
    #endif
  }

  #if os(iOS)
  var keyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }
  #endif
}
