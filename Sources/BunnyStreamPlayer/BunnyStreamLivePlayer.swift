import AVFoundation
import AVKit
import SwiftUI
import Kingfisher
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
    private let watermark: PlayerWatermark?
    private let onStateChange: ((BunnyLiveStreamPlaybackState) -> Void)?
    private let onPlaybackError: ((Error) -> Void)?
    @State private var isTrailerMuted = true

    /// - Parameters:
    ///   - accessKey: The access key for authentication.
    ///   - libraryId: The ID of the video library.
    ///   - streamId: The GUID of the live stream.
    ///   - watermark: Optional client-side watermark rendered on top of the live video.
    ///   - token: Optional playback token, required when the library enforces token authentication.
    ///   - expires: Expiration timestamp that `token` was signed with.
    ///   - onStateChange: Called on the main actor whenever what the player is showing changes —
    ///     use it to keep surrounding UI or analytics in step. Not called for changes that don't
    ///     alter the public state.
    ///   - onPlaybackError: Called on the main actor when a poll fails, including transient
    ///     failures the player recovers from on its own, or when the CDN refuses playback
    ///     (HTTP 403, reported as a permanent `BunnyLiveStreamError`). Check
    ///     `(error as? BunnyLiveStreamError)?.isPermanent` to tell the two apart: after a
    ///     permanent failure the player stops polling and settles on
    ///     ``BunnyLiveStreamPlaybackState/failed(message:)``.
    public init(
        accessKey: String,
        libraryId: Int,
        streamId: String,
        watermark: PlayerWatermark? = nil,
        token: String? = nil,
        expires: Int64? = nil,
        onStateChange: ((BunnyLiveStreamPlaybackState) -> Void)? = nil,
        onPlaybackError: ((Error) -> Void)? = nil
    ) {
        self.accessKey = accessKey
        self.libraryId = libraryId
        self.streamId = streamId
        self.watermark = watermark
        self.onStateChange = onStateChange
        self.onPlaybackError = onPlaybackError
        self._controller = StateObject(wrappedValue: LivePlaybackController(
            bunnyStreamAPI: BunnyStreamAPI(accessKey: accessKey),
            accessKey: accessKey,
            libraryId: libraryId,
            streamId: streamId,
            token: token,
            expires: expires
        ))
    }

    public var body: some View {
        Group {
            switch controller.state {
            case .loading:
                loadingView
            case .playable(let player, let video):
                liveContainerView(player, video: video)
            case .countdown(let date, let thumbnailUrl, let title):
                countdownView(until: date, thumbnailUrl: thumbnailUrl, title: title)
            case .trailer(let vodId, let scheduledStart, let statusMessage, let title):
                trailerWithOverlay(vodId: vodId, scheduledStart: scheduledStart, statusMessage: statusMessage, title: title)
            case .offline(let message, let thumbnailUrl):
                offlineView(message: message, thumbnailUrl: thumbnailUrl)
            case .error(let message, let thumbnailUrl):
                errorView(message: message, thumbnailUrl: thumbnailUrl)
            }
        }
        .onAppear {
            // Wire the observers before starting, so the first state is reported too.
            controller.onPlaybackError = onPlaybackError
            controller.onStateChange = onStateChange
            controller.userWantsPlay = true
            controller.start()
        }
        .onDisappear {
            controller.stop()
            controller.onStateChange = nil
            controller.onPlaybackError = nil
        }
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

    /// The ambient theme with the live stream's dashboard font/primary-color applied on top, so the
    /// live transport bar reflects the Bunny-configured player settings (falls back to the ambient
    /// theme for any field the /play endpoint doesn't provide).
    var resolvedTheme: VideoPlayerTheme {
        guard let customization = controller.customization else { return theme }
        var resolved = theme
        if let family = customization.fontFamily, let font = Fonts(rawValue: family) {
            resolved.font = font
        }
        if let hex = customization.playerKeyColor, let color = Color(hex: hex) {
            resolved.tintColor = color
        }
        return resolved
    }

    /// The language the dashboard pinned the player UI to, if any. `nil` leaves the overlay
    /// strings following the device's own language.
    var uiLanguage: String? {
        controller.customization?.uiLanguage
    }

    /// The player config built from the /play endpoint: honors the dashboard's control list,
    /// heatmap and compact-controls settings. Falls back to the default (all controls) when the
    /// API doesn't specify them.
    var resolvedConfig: VideoPlayerConfig {
        var config = VideoPlayerConfig()
        guard let customization = controller.customization else { return config }
        if !customization.controlTokens.isEmpty {
            config.controls = customization.controlTokens.compactMap { VideoPlayerConfig.Control(rawValue: $0) }
        }
        config.showHeatmap = customization.showHeatmap
        config.compactControls = customization.enableCompactControls
        return config
    }

    func liveContainerView(_ player: MediaPlayer, video: Video) -> some View {
        // `video` carries real resolutions/captions for an ended-live recording (so the quality
        // menu offers actual renditions); for the live edge it's a minimal "Auto-only" stub.
        BunnyStreamPlayerContainerView(player: player, video: video, heatmap: Heatmap(data: [:]))
            .environment(\.playerWatermark, watermark)
            .environment(\.videoPlayerTheme, resolvedTheme)
            .environment(\.videoPlayerConfig, resolvedConfig)
    }

    func countdownView(until date: Date, thumbnailUrl: URL?, title: String?) -> some View {
        ZStack {
            Color.black
            posterImage(thumbnailUrl)
            countdownOverlay(until: date, title: title)
        }
        .ignoresSafeArea()
    }

    /// Poster image shown behind live-state overlays (countdown / offline / error).
    ///
    /// Uses Kingfisher with the Bunny CDN Referer so the image still loads when the library
    /// has "Block direct URL file access" enabled (a plain `AsyncImage` cannot send the header
    /// and would be rejected with HTTP 403, leaving a black poster).
    @ViewBuilder
    func posterImage(_ url: URL?, dim: Double = 0) -> some View {
        if let url {
            KFImage.url(url)
                .requestModifier(BunnyCDN.refererModifier)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(dim > 0 ? Color.black.opacity(dim) : Color.clear)
        }
    }

    func trailerWithOverlay(vodId: String, scheduledStart: Date?, statusMessage: LiveStreamMessage?, title: String?) -> some View {
        ZStack {
            LoopingTrailerView(libraryId: libraryId, vodId: vodId, accessKey: accessKey, isMuted: $isTrailerMuted)
                .ignoresSafeArea()
            if let scheduledStart {
                countdownOverlay(until: scheduledStart, title: title)
            } else if let statusMessage {
                trailerStatusOverlay(message: statusMessage)
            }
            muteButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(20)
        }
    }

    /// Centered countdown overlay matching the Bunny web player:
    /// "<title> will start in" on top, large bold H:MM:SS timer below.
    func countdownOverlay(until date: Date, title: String?) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = date.timeIntervalSince(context.date)
            VStack(spacing: 8) {
                if remaining > 0 {
                    Text(countdownTitle(title))
                        .font(theme.font.size(22))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.45), radius: 3, y: 1)
                    Text(Self.countdownString(from: remaining))
                        .font(theme.font.size(40))
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                } else {
                    Text(LiveStreamMessage.startingSoon.localized(languageCode: uiLanguage))
                        .font(theme.font.size(20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.45), radius: 3, y: 1)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
        }
    }

    var muteButton: some View {
        Button {
            isTrailerMuted.toggle()
        } label: {
            (isTrailerMuted ? theme.images.volumeOff : theme.images.volumeOn)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.black.opacity(0.45), in: Circle())
        }
        .buttonStyle(.plain)
    }

    func countdownTitle(_ title: String?) -> String {
        let name = (title?.isEmpty == false) ? title! : "Live stream"
        return "\(name) will start in"
    }

    static func countdownString(from remaining: TimeInterval) -> String {
        let total = max(0, Int(remaining))
        let h = total / 3600
        let m = total / 60 % 60
        let s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    func trailerStatusOverlay(message: LiveStreamMessage) -> some View {
        Text(message.localized(languageCode: uiLanguage))
            .font(theme.font.size(14))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.black.opacity(0.55))
            .clipShape(Capsule())
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 32)
    }

    func offlineView(message: LiveStreamMessage, thumbnailUrl: URL?) -> some View {
        ZStack {
            Color.black
            posterImage(thumbnailUrl, dim: 0.55)

            VStack(spacing: 12) {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 40))
                    .foregroundStyle(theme.tintColor.opacity(0.8))
                Text(message.localized(languageCode: uiLanguage))
                    .font(theme.font.size(16))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }

    func errorView(message: LiveStreamMessage, thumbnailUrl: URL?) -> some View {
        ZStack {
            Color.black
            posterImage(thumbnailUrl, dim: 0.65)

            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(theme.tintColor)
                Text(message.localized(languageCode: uiLanguage))
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
    let accessKey: String
    @Binding var isMuted: Bool

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
        .onChange(of: isMuted) { newValue in
            player?.isMuted = newValue
        }
        .onDisappear {
            looper?.disableLooping()
            player?.pause()
            player = nil
            looper = nil
        }
    }

    private func loadAndPlay() async {
        do {
            let config = try await VideoPlayerConfigLoader().load(libraryId: libraryId, videoId: vodId, accessKey: accessKey)
            guard let url = URL(string: config.videoPlaylistUrl) else { return }
            let item = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer()
            let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            queuePlayer.isMuted = isMuted
            queuePlayer.play()
            looper = playerLooper
            player = queuePlayer
        } catch {}
    }
}
