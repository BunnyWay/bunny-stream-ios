import SwiftUI
import BunnyStreamPlayer

struct LiveStreamDemoView: View {
  var dependenciesManager: DependenciesManager

  @State private var streamId: String = ""
  @State private var activeStreamId: String? = nil

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        playerView(geometry: geometry)
        inputView
      }
    }
    .navigationTitle("Live Stream")
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - Player

private extension LiveStreamDemoView {
  @ViewBuilder
  func playerView(geometry: GeometryProxy) -> some View {
    let isPortrait = geometry.size.width < geometry.size.height
    let playerHeight = isPortrait ? geometry.size.width * (9 / 16) : geometry.size.height

    Group {
      if let activeStreamId {
        BunnyStreamLivePlayer(
          accessKey: dependenciesManager.accessKey,
          libraryId: dependenciesManager.libraryId,
          streamId: activeStreamId
        )
      } else {
        ZStack {
          Color.black
          Image(systemName: "antenna.radiowaves.left.and.right")
            .font(.system(size: 48))
            .foregroundStyle(.white.opacity(0.4))
        }
      }
    }
    .frame(width: geometry.size.width, height: playerHeight)
  }
}

// MARK: - Input

private extension LiveStreamDemoView {
  var inputView: some View {
    List {
      Section("Stream ID") {
        TextField("Enter stream ID", text: $streamId)
          .autocapitalization(.none)
          .disableAutocorrection(true)
        Button(action: loadStream) {
          HStack {
            Spacer()
            Text(activeStreamId == nil ? "Load Stream" : "Change Stream")
              .bold()
            Spacer()
          }
        }
        .disabled(streamId.isEmpty)
      }
    }
    .ignoresSafeArea(edges: .bottom)
  }

  func loadStream() {
    activeStreamId = streamId
  }
}
