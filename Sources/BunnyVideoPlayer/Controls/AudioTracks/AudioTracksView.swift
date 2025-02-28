import SwiftUI

struct AudioTracksView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  @ObservedObject var viewModel: AudioTracksViewModel

  var body: some View {
    itemsMenuView()
  }
}

extension AudioTracksView {
  func itemsMenuView() -> some View {
    Group {
      ForEach(viewModel.audioTracks, id: \.self) { track in
        Button {
          viewModel.selectAudioTrack(track)
        } label: {
          Text(track.displayName.addCheckmark(track == viewModel.selectedAudioTrack))
            .font(theme.font.size(14))
        }
      }
    }
  }
}
