import AVFoundation
import AVKit
import SwiftUI
import BunnyStreamAPI

/// A SwiftUI view that provides a live stream playback experience using BunnyStream.
///
/// `BunnyStreamLivePlayer` handles connecting to a live stream, polling for status changes,
/// countdown timers, pre-stream trailers, and DVR playback when the stream supports it.
///
/// ### Usage Example:
/// ```swift
/// BunnyStreamLivePlayer(accessKey: "your_access_key", libraryId: 123, streamId: "stream-guid")
/// ```
public struct BunnyStreamLivePlayer: View {
    @StateObject private var controller: LivePlaybackController
    @Environment(\.videoPlayerTheme) private var theme: VideoPlayerTheme
    private let accessKey: String
    private let libraryId: Int
    private let streamId: String

    public init(accessKey: String, libraryId: Int, streamId: String) {
        self.accessKey = accessKey
        self.libraryId = libraryId
        self.streamId = streamId
        self._controller = StateObject(wrappedValue: LivePlaybackController(
            bunnyStreamAPI: BunnyStreamAPI(accessKey: accessKey),
            libraryId: libraryId,
            streamId: streamId
        ))
    }

    public var body: some View {
        Group {
            switch controller.state {
            case .loading:
                loadingView
            case .playable(let player):
                liveContainerView(player)
            case .countdown(let date, let thumbnailUrl):
                countdownView(until: date, thumbnailUrl: thumbnailUrl)
            case .trailer(let vodId, let scheduledStart, let statusMessage):
                trailerWithOverlay(vodId: vodId, scheduledStart: scheduledStart, statusMessage: statusMessage)
            case .offline(let message, let thumbnailUrl):
                offlineView(message: message, thumbnailUrl: thumbnailUrl)
            case .error(let message, let thumbnailUrl):
                errorView(message: message, thumbnailUrl: thumbnailUrl)
            }
        }
        .onAppear {
            controller.userWantsPlay = true
            controller.start()
        }
        .onDisappear { controller.stop() }
    }
}

// MARK: - Sub-views

private extension BunnyStreamLivePlayer {
    var loadingView: some View {
        ZStack {
            Color.black
            VStack(spacing: 12) {
                ProgressView().tint(theme.tintColor)
                Text("Connecting…")
                    .font(theme.font.size(12))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    func liveContainerView(_ player: MediaPlayer) -> some View {
        let video = Video(
            guid: streamId,
            chaptersList: nil,
            moments: [],
            thumbnailCount: 0,
            width: 0,
            height: 0,
            length: 0,
            captions: [],
            libraryId: libraryId,
            resolutions: [.auto],
            seekPath: nil,
            playlistUrl: nil
        )
        return BunnyStreamPlayerContainerView(player: player, video: video, heatmap: Heatmap(data: [:]))
    }

    func countdownView(until date: Date, thumbnailUrl: URL?) -> some View {
        ZStack {
            if let thumbnailUrl {
                AsyncImage(url: thumbnailUrl) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(Color.black.opacity(0.5))
                    } else {
                        Color.black
                    }
                }
            } else {
                Color.black
            }
            VStack(spacing: 16) {
                Image(systemName: "clock")
                    .font(.system(size: 40))
                    .foregroundStyle(theme.tintColor.opacity(0.8))
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    countdownLabel(until: date)
                }
            }
        }
    }

    func countdownLabel(until date: Date) -> some View {
        let remaining = date.timeIntervalSinceNow
        if remaining > 0 {
            let h = Int(remaining) / 3600
            let m = Int(remaining) / 60 % 60
            let s = Int(remaining) % 60
            return Text(String(format: "%02d:%02d:%02d", h, m, s))
                .font(.system(size: 48, weight: .thin, design: .monospaced))
                .foregroundStyle(.white)
        } else {
            return Text(Lingua.LiveStream.streamStartingSoon)
                .font(theme.font.size(16))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    func trailerWithOverlay(vodId: String, scheduledStart: Date?, statusMessage: String?) -> some View {
        ZStack(alignment: .bottom) {
            LoopingTrailerView(libraryId: libraryId, vodId: vodId)
                .ignoresSafeArea()
            if let scheduledStart {
                trailerCountdownOverlay(until: scheduledStart)
            } else if let statusMessage {
                trailerStatusOverlay(message: statusMessage)
            }
        }
    }

    func trailerStatusOverlay(message: String) -> some View {
        Text(message)
            .font(theme.font.size(14))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.black.opacity(0.55))
            .clipShape(Capsule())
            .padding(.bottom, 32)
    }

    func trailerCountdownOverlay(until date: Date) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .foregroundStyle(theme.tintColor)
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                let remaining = date.timeIntervalSinceNow
                if remaining > 0 {
                    let h = Int(remaining) / 3600
                    let m = Int(remaining) / 60 % 60
                    let s = Int(remaining) % 60
                    Text(String(format: "%02d:%02d:%02d", h, m, s))
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                } else {
                    Text(Lingua.LiveStream.streamStartingSoon)
                        .font(theme.font.size(14))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.black.opacity(0.55))
        .clipShape(Capsule())
        .padding(.bottom, 32)
    }

    func offlineView(message: String, thumbnailUrl: URL?) -> some View {
        ZStack {
            if let thumbnailUrl {
                AsyncImage(url: thumbnailUrl) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(Color.black.opacity(0.55))
                    } else {
                        Color.black
                    }
                }
            } else {
                Color.black
            }

            VStack(spacing: 12) {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 40))
                    .foregroundStyle(theme.tintColor.opacity(0.8))
                Text(message)
                    .font(theme.font.size(16))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }

    func errorView(message: String, thumbnailUrl: URL?) -> some View {
        ZStack {
            if let thumbnailUrl {
                AsyncImage(url: thumbnailUrl) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(Color.black.opacity(0.65))
                    } else {
                        Color.black
                    }
                }
            } else {
                Color.black
            }

            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(theme.tintColor)
                Text(message)
                    .font(theme.font.size(16))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

// MARK: - Looping trailer player

private struct LoopingTrailerView: View {
    let libraryId: Int
    let vodId: String

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .disabled(true) // hide tap-to-pause gesture, keep controls hidden
            } else {
                Color.black
            }
        }
        .ignoresSafeArea()
        .task(id: vodId) { await loadAndPlay() }
        .onDisappear {
            looper?.disableLooping()
            player?.pause()
            player = nil
            looper = nil
        }
    }

    private func loadAndPlay() async {
        do {
            let config = try await VideoPlayerConfigLoader().load(libraryId: libraryId, videoId: vodId)
            guard let url = URL(string: config.videoPlaylistUrl) else { return }
            let item = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer()
            let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            queuePlayer.play()
            looper = playerLooper
            player = queuePlayer
        } catch {}
    }
}
