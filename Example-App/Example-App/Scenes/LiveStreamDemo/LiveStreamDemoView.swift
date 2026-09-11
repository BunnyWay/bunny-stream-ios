import SwiftUI
import BunnyStreamAPI
import BunnyStreamPlayer

struct LiveStreamDemoView: View {
  var dependenciesManager: DependenciesManager

  @State private var streamId: String = ""
  @State private var activeStreamId: String? = nil
  /// Mirrors what the player reports through `onStateChange` — the app never reaches into it.
  @State private var playbackState: BunnyLiveStreamPlaybackState = .loading
  @State private var lastError: String?

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
          streamId: activeStreamId,
          onStateChange: { playbackState = $0 },
          onPlaybackError: { error in
            // Transient failures are reported too; only a permanent one has stopped the player.
            let isPermanent = (error as? BunnyLiveStreamError)?.isPermanent ?? false
            lastError = "\(isPermanent ? "permanent" : "transient"): \(error.localizedDescription)"
          }
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

      if activeStreamId != nil {
        Section("Player state") {
          LabeledContent("State", value: stateDescription)
          if let lastError {
            LabeledContent("Last error", value: lastError)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .ignoresSafeArea(edges: .bottom)
  }

  var stateDescription: String {
    switch playbackState {
    case .loading:
      return "loading"
    case .playing(let isVodRecording):
      return isVodRecording ? "playing (recording)" : "playing (live)"
    case .countdown(let until, _):
      return "countdown until \(until.formatted(date: .omitted, time: .shortened))"
    case .trailer:
      return "trailer"
    case .offline(let message):
      return "offline — \(message)"
    case .failed(let message):
      return "failed — \(message)"
    }
  }

  func loadStream() {
    activeStreamId = streamId
    playbackState = .loading
    lastError = nil
  }
}
