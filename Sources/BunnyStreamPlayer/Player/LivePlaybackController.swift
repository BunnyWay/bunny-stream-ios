import AVFoundation
import BunnyStreamAPI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class LivePlaybackController: ObservableObject {
    enum State {
        case loading
        case playable(MediaPlayer, Video)
        case countdown(until: Date, thumbnailUrl: URL?, title: String?)
        case trailer(vodId: String, scheduledStart: Date?, statusMessage: String?, title: String?)
        case offline(message: String, thumbnailUrl: URL?)
        case error(message: String, thumbnailUrl: URL?)
    }

    @Published private(set) var state: State = .loading
    var userWantsPlay = false

    private let api: BunnyStreamAPI
    private let libraryId: Int
    private let streamId: String
    private let playDataLoader: LiveStreamPlayDataLoader

    private var pollTask: Task<Void, Never>?
    private var isStopped = false

    private var stallObserver: NSObjectProtocol?
    private var failureObserver: NSObjectProtocol?
    private var itemStatusObserver: NSKeyValueObservation?
    private var lifecycleObservers: [NSObjectProtocol] = []

    init(bunnyStreamAPI: BunnyStreamAPI, libraryId: Int, streamId: String) {
        self.api = bunnyStreamAPI
        self.libraryId = libraryId
        self.streamId = streamId
        self.playDataLoader = LiveStreamPlayDataLoader(bunnyStreamAPI: bunnyStreamAPI)
    }

    deinit {
        pollTask?.cancel()
    }

    func start() {
        isStopped = false
        configureAudioSession()
        observeLifecycle()
        firePoll()
    }

    /// Activates the `.playback` audio session so audio keeps playing under the silent switch and,
    /// crucially, so Picture in Picture can start (`isPictureInPicturePossible` requires it). The
    /// VOD player does the same; the live path previously skipped it.
    private func configureAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback, options: [])
        try? session.setActive(true)
        #endif
    }

    func stop() {
        isStopped = true
        pollTask?.cancel()
        pollTask = nil
        removeItemObservers()
        teardownCurrentPlayer()
        lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
        lifecycleObservers = []
        state = .loading
    }
}

// MARK: - Polling loop

private extension LivePlaybackController {
    static let pollInterval: UInt64 = 5_000_000_000 // 5s in nanoseconds

    func firePoll() {
        guard !isStopped else { return }
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.executePoll()
                guard !Task.isCancelled, self?.isStopped != true else { break }
                try? await Task.sleep(nanoseconds: Self.pollInterval)
            }
        }
    }

    func executePoll() async {
        guard !isStopped else { return }
        do {
            let model = try await fetchStreamModel()
            guard !Task.isCancelled else { return }
            let displayState = resolveDisplayState(from: model)
            await MainActor.run { [weak self] in self?.apply(displayState: displayState) }
        } catch PollError.permanent {
            await MainActor.run { [weak self] in
                self?.isStopped = true
                self?.state = .error(message: Lingua.LiveStream.streamError, thumbnailUrl: nil)
            }
        } catch {
            // Transient (5xx, network) — loop continues after sleep
        }
    }
}

// MARK: - API fetch

private extension LivePlaybackController {
    enum PollError: Error { case permanent }

    func fetchStreamModel() async throws -> Components.Schemas.LiveStreamModel {
        let output = try await api.client.liveStreamGet(
            path: .init(libraryId: Int64(libraryId), streamId: streamId)
        )
        switch output {
        case .ok(let ok):
            guard case .json(let model) = ok.body else { throw PollError.permanent }
            return model
        case .unauthorized:
            throw PollError.permanent
        case .notFound:
            throw PollError.permanent
        case .internalServerError:
            throw URLError(.badServerResponse)
        case .undocumented(statusCode: let code, _) where [403, 410].contains(code):
            throw PollError.permanent
        default:
            throw URLError(.unknown)
        }
    }
}

// MARK: - State application

private extension LivePlaybackController {
    func apply(displayState: LiveStreamDisplayState) {
        switch displayState {
        case .playable(let url, let isVodRecording):
            handlePlayable(url: url, isVodRecording: isVodRecording)
        case .countdown(let date, let thumbnailUrl, let title):
            teardownCurrentPlayer()
            state = .countdown(until: date, thumbnailUrl: thumbnailUrl, title: title)
        case .trailer(let vodId, let scheduledStart, let statusMessage, let title):
            teardownCurrentPlayer()
            state = .trailer(vodId: vodId, scheduledStart: scheduledStart, statusMessage: statusMessage, title: title)
        case .offline(let message, let thumbnailUrl):
            teardownCurrentPlayer()
            state = .offline(message: message, thumbnailUrl: thumbnailUrl)
        case .error(let message, let thumbnailUrl):
            isStopped = true
            teardownCurrentPlayer()
            state = .error(message: message, thumbnailUrl: thumbnailUrl)
        }
    }

    func handlePlayable(url: URL, isVodRecording: Bool) {
        // Don't restart if already playing the same URL — unless the player item has failed.
        if case .playable(let existing, _) = state {
            let existingURL = existing.sourceURL ?? (existing.currentItem?.asset as? AVURLAsset)?.url
            let itemFailed = existing.currentItem?.status == .failed
            if existingURL == url && !itemFailed { return }
        }

        if isVodRecording {
            loadRecordingPlayer(fallbackURL: url)
        } else {
            // Fetch /play for HLS URL + DVR seekable window.
            // Don't change state yet — current state (trailer/countdown) stays visible until player is ready.
            Task { [weak self] in
                guard let self else { return }
                let player: MediaPlayer
                do {
                    let playData = try await playDataLoader.load(libraryId: libraryId, streamId: streamId)
                    player = MediaPlayer.makeLive(url: playData.playbackURL, seekableWindowSeconds: playData.seekableWindow, contentId: streamId)
                } catch {
                    player = MediaPlayer.makeLive(url: url, seekableWindowSeconds: 0, contentId: streamId)
                }
                observeItem(player)
                if userWantsPlay { player.play() }
                await MainActor.run { [weak self] in
                    guard let self, !self.isStopped else { return }
                    self.teardownCurrentPlayer()
                    // Live has no named renditions from /play, so only "Auto" is offered.
                    self.state = .playable(player, Self.liveStubVideo(streamId: self.streamId, libraryId: self.libraryId))
                }
            }
        }
    }

    /// Builds a VOD player for an ended live stream's recording.
    ///
    /// The recording is a regular VOD once the stream ends, so it plays through the same path as
    /// any other VOD — `/videos/{guid}/play` → `Video` → `MediaPlayer.make` — which sets up
    /// FairPlay, CMCD (`.vod`) and finite/scrubbable playback. The live `playbackUrlHls` points at
    /// the (now-dead) live edge, so it's used only as a fallback while the recording config isn't
    /// available yet. Once the recording player is up, polling stops — the ended state is terminal.
    func loadRecordingPlayer(fallbackURL: URL) {
        Task { [weak self] in
            guard let self else { return }
            let player: MediaPlayer
            let video: Video
            do {
                let config = try await VideoPlayerConfigLoader().load(libraryId: libraryId, videoId: streamId)
                // The real Video carries the recording's resolutions/captions so the quality menu
                // offers actual renditions instead of only "Auto".
                video = Video(response: config)
                player = MediaPlayer.make(video: video)
            } catch {
                video = Self.liveStubVideo(streamId: streamId, libraryId: libraryId)
                player = MediaPlayer(url: fallbackURL)
            }
            observeItem(player)
            if userWantsPlay { player.play() }
            await MainActor.run { [weak self] in
                guard let self, !self.isStopped else { return }
                self.teardownCurrentPlayer()
                self.state = .playable(player, video)
                // The recording is static — stop the 5s poll. Player-failure recovery still re-polls.
                self.pollTask?.cancel()
                self.pollTask = nil
            }
        }
    }

    /// Minimal `Video` for players without a fetched VOD config (live edge, or recording fallback).
    /// Only "Auto" quality is offered since no named renditions are known.
    static func liveStubVideo(streamId: String, libraryId: Int) -> Video {
        Video(
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
    }

    func teardownCurrentPlayer() {
        guard case .playable(let player, _) = state else { return }
        player.pause()
        removeItemObservers()
    }
}

// MARK: - Player item observation

private extension LivePlaybackController {
    func observeItem(_ player: MediaPlayer) {
        removeItemObservers()
        let center = NotificationCenter.default
        stallObserver = center.addObserver(
            forName: AVPlayerItem.playbackStalledNotification,
            object: player.currentItem,
            queue: .main
        ) {
            [weak self] _ in MainActor.assumeIsolated {
                self?.handlePlayerFailure()
            }
        }

        failureObserver = center.addObserver(
            forName: AVPlayerItem.failedToPlayToEndTimeNotification,
            object: player.currentItem,
            queue: .main
        ) {
            [weak self] _ in MainActor.assumeIsolated {
                self?.handlePlayerFailure()
            }
        }

        itemStatusObserver = player.currentItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            guard item.status == .failed else { return }
            Task { @MainActor [weak self] in self?.handlePlayerFailure() }
        }
    }

    func handlePlayerFailure() {
        removeItemObservers()
        firePoll()
    }

    func removeItemObservers() {
        stallObserver.map(NotificationCenter.default.removeObserver)
        failureObserver.map(NotificationCenter.default.removeObserver)
        stallObserver = nil
        failureObserver = nil
        itemStatusObserver = nil
    }
}

// MARK: - App lifecycle

private extension LivePlaybackController {
    func observeLifecycle() {
        lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
        lifecycleObservers = []
        #if canImport(UIKit)
        let center = NotificationCenter.default
        
        lifecycleObservers = [
            center.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil, queue: .main
            ) {
                [weak self] _ in MainActor.assumeIsolated {
                    self?.pollTask?.cancel()
                    self?.pollTask = nil
                }
            },
            center.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil, queue: .main
            ) {
                [weak self] _ in MainActor.assumeIsolated {
                    self?.firePoll()
                }
            }
        ]
        #endif
    }
}
