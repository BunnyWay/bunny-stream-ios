import SwiftUI
import AVKit
import Combine

struct VideoPlayerControls: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  @Environment(\.videoPlayerConfig) var videoPlayerConfig: VideoPlayerConfig
  @ObservedObject private var viewModel: VideoPlayerControlsViewModel
  @State private var airPlayView = AirPlayView()
  
  init(viewModel: VideoPlayerControlsViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
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

// MARK: - Views
extension VideoPlayerControls {
  func topControlsView() -> some View {
    HStack {
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
      
      Spacer()
    }
  }
  
  func bottomControlsView() -> some View {
    VStack {
      seekBarView()
        .shouldAddView(controlsToCheck: .progress, in: videoPlayerConfig.controls)
      
      HStack {
        timeView()
        Spacer()
        captionsButton()
          .shouldAddView(!viewModel.captionsMenuViewModel.captions.isEmpty)
          .shouldAddView(controlsToCheck: .captions, in: videoPlayerConfig.controls)

        optionsButton()
          .shouldAddView(controlsToCheck: .settings, in: videoPlayerConfig.controls)
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
