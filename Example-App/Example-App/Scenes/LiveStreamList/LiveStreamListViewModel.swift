import BunnyStreamAPI
import BunnyStreamPlayer
import BunnyStreamUploader
import Foundation

@MainActor
class LiveStreamListViewModel: ObservableObject {
    enum LoadingState {
        case loading, loaded, failed(String)
    }

    @Published var streams: [BunnyLiveStream] = []
    @Published var loadingState: LoadingState = .loading
    @Published var actionError: String?

    private let api: BunnyStreamAPI
    /// Live stream operations in domain terms. The raw generated client is only still used for
    /// the VOD calls below, which this repository doesn't cover.
    private let liveStreams: DefaultLiveStreamRepository
    private let configLoader = VideoPlayerConfigLoader()
    let libraryId: Int
    let accessKey: String

    init(api: BunnyStreamAPI, libraryId: Int, accessKey: String) {
        self.api = api
        self.liveStreams = api.liveStreams
        self.libraryId = libraryId
        self.accessKey = accessKey
    }

    /// Resolves the thumbnail URL for a library video (trailer preview, live stream row, etc.).
    func videoThumbnailURL(videoId: String) async -> URL? {
        guard let urlString = try? await configLoader.loadVideoThumbnail(
            libraryId: libraryId,
            videoId: videoId
        ) else { return nil }
        return URL(string: urlString)
    }

    func create(
        name: String,
        description: String? = nil,
        scheduledStartTime: Date? = nil,
        enableCountdown: Bool = false,
        dvrEnabled: Bool = false,
        dvrWindowSeconds: Int? = nil,
        recordVod: Bool = false,
        trailerVideoId: String? = nil,
        rtmpOutputs: [BunnyRtmpOutput] = []
    ) async throws -> BunnyLiveStream {
        let request = BunnyLiveStreamCreateRequest(
            title: name,
            description: description?.isEmpty == false ? description : nil,
            scheduledStartTime: scheduledStartTime,
            dvrEnabled: dvrEnabled ? true : nil,
            dvrWindowSeconds: dvrEnabled ? dvrWindowSeconds : nil,
            recordVod: recordVod ? true : nil,
            enableCountdown: enableCountdown ? true : nil,
            preStreamTrailerVideoId: trailerVideoId?.isEmpty == false ? trailerVideoId : nil,
            rtmpOutputs: rtmpOutputs.isEmpty ? nil : rtmpOutputs
        )
        return try await liveStreams.createLiveStream(libraryId: libraryId, request: request)
    }

    func update(
        stream: BunnyLiveStream,
        name: String,
        description: String? = nil,
        scheduledStartTime: Date? = nil,
        enableCountdown: Bool = false,
        dvrEnabled: Bool = false,
        dvrWindowSeconds: Int? = nil,
        recordVod: Bool = false,
        trailerVideoId: String? = nil,
        isPublic: Bool? = nil,
        rtmpOutputs: [BunnyRtmpOutput] = []
    ) async throws -> BunnyLiveStream {
        guard let guid = stream.id, !guid.isEmpty else {
            throw BunnyLiveStreamError(kind: .invalidRequest)
        }
        let request = BunnyLiveStreamUpdateRequest(
            title: name,
            description: description ?? "",
            scheduledStartTime: scheduledStartTime,
            isPublic: isPublic,
            dvrEnabled: dvrEnabled,
            dvrWindowSeconds: dvrEnabled ? dvrWindowSeconds : nil,
            recordVod: recordVod,
            enableCountdown: enableCountdown,
            preStreamTrailerVideoId: trailerVideoId?.isEmpty == false ? trailerVideoId : nil,
            // Only send rtmpOutputs when set — the API rejects an empty array (400). A populated
            // array matches the documented schema but currently returns 500 (Bunny preview feature
            // not yet enabled server-side), so the create/edit UI surfaces that as a clear error.
            rtmpOutputs: rtmpOutputs.isEmpty ? nil : rtmpOutputs
        )
        return try await liveStreams.updateLiveStream(
            libraryId: libraryId,
            streamId: guid,
            request: request
        )
    }

    // MARK: - Thumbnails

    enum ThumbnailError: LocalizedError {
        case unauthorized, notFound, invalidImage, tooLarge, failed(Int?)
        var errorDescription: String? {
            switch self {
            case .unauthorized:     return "Unauthorized — check your Access Key."
            case .notFound:         return "Live stream not found."
            case .invalidImage:     return "Couldn't read the selected image."
            case .tooLarge:         return "The image is too large. Please pick a smaller one."
            case .failed(let code): return code.map { "Failed to set thumbnail (HTTP \($0))." } ?? "Failed to set thumbnail."
            }
        }
    }

    /// Sets the offline thumbnail from a remote URL — Bunny fetches the image.
    func setThumbnail(streamId: String, url: String) async throws {
        do {
            try await liveStreams.setThumbnail(libraryId: libraryId, streamId: streamId, thumbnailUrl: url)
        } catch let error as BunnyLiveStreamError {
            throw ThumbnailError(error)
        }
    }

    /// Uploads JPEG image bytes (e.g. a photo picked on the device) as the offline thumbnail.
    /// The bytes must be JPEG — Bunny requires an image Content-Type and rejects HEIC/octet-stream.
    func setThumbnail(streamId: String, jpegData: Data) async throws {
        do {
            try await liveStreams.uploadThumbnail(
                libraryId: libraryId,
                streamId: streamId,
                imageData: jpegData,
                format: .jpeg
            )
        } catch let error as BunnyLiveStreamError {
            throw ThumbnailError(error)
        }
    }

    /// Removes the offline thumbnail from the live stream.
    func deleteThumbnail(streamId: String) async throws {
        do {
            try await liveStreams.deleteThumbnail(libraryId: libraryId, streamId: streamId)
        } catch let error as BunnyLiveStreamError {
            throw ThumbnailError(error)
        }
    }

    /// Lists the thumbnails Bunny automatically generates while the stream is/was live
    /// (most recent first).
    func liveThumbnails(streamId: String, limit: Int = 24) async throws -> [BunnyLiveStreamThumbnail] {
        do {
            return try await liveStreams
                .listThumbnails(libraryId: libraryId, streamId: streamId, limit: limit)
                .filter { $0.url?.isEmpty == false }
        } catch let error as BunnyLiveStreamError {
            throw ThumbnailError(error)
        }
    }

    /// Best thumbnail for a list row: the stream's own offline thumbnail, else the pre-stream
    /// trailer's thumbnail as a fallback.
    func liveThumbnailURL(for stream: BunnyLiveStream) async -> URL? {
        if let url = stream.offlineThumbnailUrl { return url }
        if let trailerId = stream.preStreamTrailerVideoId, !trailerId.isEmpty {
            return await videoThumbnailURL(videoId: trailerId)
        }
        return nil
    }

    // MARK: - VOD helpers (not covered by the live stream repository)

    func createTrailerEntry(name: String) async throws -> (id: String, title: String) {
        let output = try await api.client.createVideo(
            path: .init(libraryId: Int64(libraryId)),
            body: .json(.CreateVideoModel(.init(title: name)))
        )
        guard case .ok(let ok) = output,
              case .json(let model) = ok.body,
              let guid = model.guid else {
            throw TrailerUploadError.createFailed
        }
        return (id: guid, title: name)
    }

    enum TrailerUploadError: LocalizedError {
        case createFailed
        var errorDescription: String? { "Failed to create video entry in library." }
    }

    func videosForTrailerPicker() async throws -> [(id: String, title: String)] {
        let output = try await api.client.listVideos(path: .init(libraryId: Int64(libraryId)))
        guard case .ok(let ok) = output, case .json(let list) = ok.body else { return [] }
        return (list.items ?? []).compactMap { video in
            guard let id = video.guid, !id.isEmpty else { return nil }
            return (id: id, title: video.title ?? id)
        }
    }

    // MARK: - Ingest status

    /// Live ingest status (primary/backup) shown as badges in the stream list.
    struct IngestLiveStatus: Equatable {
        let primaryLive: Bool
        let backupLive: Bool
    }

    /// Resolves the live ingest status for a RUNNING stream. Prefers the stream's own
    /// `primaryLive`/`backupLive` when the API populates them, otherwise falls back to the
    /// lightweight `/status` endpoint. Returns nil for non-running streams (no live ingest) or failure.
    func liveIngestStatus(for stream: BunnyLiveStream) async -> IngestLiveStatus? {
        guard stream.status == .running else { return nil }
        if let primary = stream.primaryLive, let backup = stream.backupLive {
            return IngestLiveStatus(primaryLive: primary, backupLive: backup)
        }
        guard let guid = stream.id, !guid.isEmpty,
              let status = try? await liveStreams.ingestStatus(libraryId: libraryId, streamId: guid)
        else { return nil }
        return IngestLiveStatus(
            primaryLive: status.primaryLive ?? false,
            backupLive: status.backupLive ?? false
        )
    }

    // MARK: - List mutations

    func delete(stream: BunnyLiveStream) async {
        guard let guid = stream.id, !guid.isEmpty else { return }
        // Optimistically remove from the list, restore on failure.
        let previous = streams
        streams.removeAll { $0.id == guid }
        do {
            try await liveStreams.deleteLiveStream(libraryId: libraryId, streamId: guid)
        } catch let error as BunnyLiveStreamError where error.kind == .notFound {
            // Already gone — keep it removed.
        } catch {
            streams = previous
            actionError = error.localizedDescription
        }
    }

    /// - Parameter showLoadingState: when false, keeps the current list on screen instead of
    ///   swapping to the full-screen spinner. Used for pull-to-refresh and silent re-loads —
    ///   flipping to `.loading` tears the List out of the hierarchy and cancels the in-flight
    ///   refresh request.
    func load(showLoadingState: Bool = true) async {
        guard libraryId != 0 else {
            loadingState = .failed("Library ID not configured. Set it in BunnyStream Configuration.")
            return
        }
        if showLoadingState {
            loadingState = .loading
        }
        do {
            streams = try await liveStreams.listLiveStreams(libraryId: libraryId).items
            loadingState = .loaded
        } catch let error as BunnyLiveStreamError where error.kind == .notFound {
            // Bunny answers 404 when the library has no streams yet — that's an empty list,
            // not a failure.
            streams = []
            loadingState = .loaded
        } catch {
            loadingState = .failed(error.localizedDescription)
        }
    }
}

private extension LiveStreamListViewModel.ThumbnailError {
    /// Restates a repository failure in the wording the thumbnail UI uses.
    init(_ error: BunnyLiveStreamError) {
        switch error.kind {
        case .unauthorized:
            self = .unauthorized
        case .notFound:
            self = .notFound
        case .invalidRequest:
            // Bunny answers 400 for oversized images ("Invalid thumbnail file size").
            self = .tooLarge
        case .unprocessable, .server, .transport, .invalidResponse, .unexpected:
            self = .failed(error.statusCode)
        }
    }
}
