import BunnyStreamAPI
import BunnyStreamPlayer
import BunnyStreamUploader
import Foundation
import OpenAPIRuntime

@MainActor
class LiveStreamListViewModel: ObservableObject {
    enum LoadingState {
        case loading, loaded, failed(String)
    }

    @Published var streams: [Components.Schemas.LiveStreamModel] = []
    @Published var loadingState: LoadingState = .loading
    @Published var actionError: String?

    private let api: BunnyStreamAPI
    private let configLoader = VideoPlayerConfigLoader()
    let libraryId: Int
    let accessKey: String

    init(api: BunnyStreamAPI, libraryId: Int, accessKey: String) {
        self.api = api
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
        rtmpOutputs: [Components.Schemas.RtmpOutput] = []
    ) async throws -> Components.Schemas.LiveStreamModel {
        var model = Components.Schemas.CreateLiveStreamModel(title: name)
        if let description, !description.isEmpty {
            model.description = description
        }
        if !rtmpOutputs.isEmpty {
            model.rtmpOutputs = rtmpOutputs
        }
        if let date = scheduledStartTime {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            model.scheduledStartTime = formatter.string(from: date)
        }
        if enableCountdown {
            model.enableCountdown = true
        }
        if dvrEnabled {
            model.dvrEnabled = true
            model.dvrWindowSeconds = dvrWindowSeconds.map { Int32($0) }
        }
        if recordVod {
            model.recordVod = true
        }
        if let id = trailerVideoId, !id.isEmpty {
            model.preStreamTrailerVideoId = id
        }
        let output = try await api.client.liveStreamCreate(
            path: .init(libraryId: Int64(libraryId)),
            body: .json(model)
        )
        switch output {
        case .created(let created):
            guard case .json(let model) = created.body else { throw CreateError.invalidResponse }
            return model
        case .unauthorized:
            throw CreateError.unauthorized
        case .undocumented(statusCode: 400, let payload):
            var detail = "400"
            if let body = payload.body,
               let data = try? await Data(collecting: body, upTo: 2000),
               let text = String(data: data, encoding: .utf8) {
                detail = text
            }
            throw CreateError.rawError(detail)
        case .undocumented(statusCode: let code, _):
            throw CreateError.httpError(code)
        default:
            throw CreateError.invalidResponse
        }
    }

    func update(
        stream: Components.Schemas.LiveStreamModel,
        name: String,
        description: String? = nil,
        scheduledStartTime: Date? = nil,
        enableCountdown: Bool = false,
        dvrEnabled: Bool = false,
        dvrWindowSeconds: Int? = nil,
        recordVod: Bool = false,
        trailerVideoId: String? = nil,
        isPublic: Bool? = nil,
        rtmpOutputs: [Components.Schemas.RtmpOutput] = []
    ) async throws -> Components.Schemas.LiveStreamModel {
        guard let guid = stream.guid, !guid.isEmpty else { throw CreateError.invalidRequest }
        var model = Components.Schemas.UpdateLiveStreamModel()
        model.title = name
        model.description = description ?? ""
        // `scheduledStartTime` is a Date in the model; the SDK's date transcoder serializes it.
        model.scheduledStartTime = scheduledStartTime
        model.enableCountdown = enableCountdown
        model.dvrEnabled = dvrEnabled
        model.dvrWindowSeconds = dvrEnabled ? dvrWindowSeconds.map { Int32($0) } : nil
        model.recordVod = recordVod
        model.preStreamTrailerVideoId = (trailerVideoId?.isEmpty == false) ? trailerVideoId : nil
        if let isPublic { model._public = isPublic }
        // Only send rtmpOutputs when set — the API rejects an empty array (400). A populated array
        // matches the documented schema but currently returns 500 (Bunny preview feature not yet
        // enabled server-side), so the create/edit UI surfaces that as a clear error.
        if !rtmpOutputs.isEmpty {
            model.rtmpOutputs = rtmpOutputs
        }

        let output = try await api.client.liveStreamUpdate(
            path: .init(libraryId: Int64(libraryId), streamId: guid),
            body: .json(model)
        )
        switch output {
        case .ok(let ok):
            guard case .json(let updated) = ok.body else { throw CreateError.invalidResponse }
            return updated
        case .unauthorized:
            throw CreateError.unauthorized
        case .badRequest:
            throw CreateError.invalidRequest
        case .notFound:
            throw CreateError.httpError(404)
        case .internalServerError:
            throw CreateError.httpError(500)
        case .undocumented(statusCode: let code, _):
            throw CreateError.httpError(code)
        }
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
        let output = try await api.client.liveStreamSetThumbnail(
            path: .init(libraryId: Int64(libraryId), streamId: streamId),
            query: .init(thumbnailUrl: url)
        )
        try handleSetThumbnail(output)
    }

    /// Uploads JPEG image bytes (e.g. a photo picked on the device) as the offline thumbnail.
    /// The bytes must be JPEG — Bunny requires an image Content-Type and rejects HEIC/octet-stream.
    func setThumbnail(streamId: String, jpegData: Data) async throws {
        let output = try await api.client.liveStreamSetThumbnail(
            path: .init(libraryId: Int64(libraryId), streamId: streamId),
            body: .jpeg(HTTPBody([UInt8](jpegData)))
        )
        try handleSetThumbnail(output)
    }

    private func handleSetThumbnail(_ output: Operations.LiveStreamSetThumbnail.Output) throws {
        switch output {
        case .ok:
            return
        case .unauthorized:
            throw ThumbnailError.unauthorized
        case .notFound:
            throw ThumbnailError.notFound
        case .badRequest:
            // Bunny returns 400 for oversized images ("Invalid thumbnail file size").
            throw ThumbnailError.tooLarge
        case .unprocessableContent:
            throw ThumbnailError.failed(422)
        case .internalServerError:
            throw ThumbnailError.failed(500)
        case .undocumented(statusCode: let code, _):
            throw ThumbnailError.failed(code)
        }
    }

    /// Removes the offline thumbnail from the live stream.
    func deleteThumbnail(streamId: String) async throws {
        let output = try await api.client.liveStreamDeleteThumbnail(
            path: .init(libraryId: Int64(libraryId), streamId: streamId)
        )
        switch output {
        case .noContent:
            return
        case .unauthorized:
            throw ThumbnailError.unauthorized
        case .notFound:
            throw ThumbnailError.notFound
        case .undocumented(statusCode: let code, _):
            throw ThumbnailError.failed(code)
        default:
            throw ThumbnailError.failed(nil)
        }
    }

    /// Builds the full offline-thumbnail URL from the stream's `thumbnailFileName` and playback
    /// host: `https://{host}/{guid}/{thumbnailFileName}`. Returns nil when no thumbnail is set.
    func offlineThumbnailURL(for stream: Components.Schemas.LiveStreamModel) -> URL? {
        guard let fileName = stream.thumbnailFileName, !fileName.isEmpty,
              let guid = stream.guid, !guid.isEmpty,
              let hls = stream.playbackUrlHls, let host = URL(string: hls)?.host
        else { return nil }
        return URL(string: "https://\(host)/\(guid)/\(fileName)")
    }

    /// Best thumbnail for a list row: the stream's own offline thumbnail, else the pre-stream
    /// trailer's thumbnail as a fallback.
    func liveThumbnailURL(for stream: Components.Schemas.LiveStreamModel) async -> URL? {
        if let url = offlineThumbnailURL(for: stream) { return url }
        if let trailerId = stream.preStreamTrailerVideoId, !trailerId.isEmpty {
            return await videoThumbnailURL(videoId: trailerId)
        }
        return nil
    }

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

    enum CreateError: LocalizedError {
        case unauthorized, invalidRequest, invalidResponse, httpError(Int), rawError(String)
        var errorDescription: String? {
            switch self {
            case .unauthorized:        return "Unauthorized — check your Access Key."
            case .invalidRequest:      return "Invalid request. Check stream name."
            case .invalidResponse:     return "Unexpected response from server."
            case .httpError(let code): return "HTTP \(code) — live stream creation failed."
            case .rawError(let body):  return body
            }
        }
    }

    func delete(stream: Components.Schemas.LiveStreamModel) async {
        guard let guid = stream.guid, !guid.isEmpty else { return }
        // Optimistically remove from the list, restore on failure.
        let previous = streams
        streams.removeAll { $0.guid == guid }
        do {
            let output = try await api.client.liveStreamDelete(
                path: .init(libraryId: Int64(libraryId), streamId: guid)
            )
            switch output {
            case .ok:
                break
            case .notFound:
                // Already gone — keep it removed.
                break
            case .unauthorized:
                streams = previous
                actionError = "Unauthorized — check your Access Key."
            default:
                streams = previous
                actionError = "Couldn't delete the live stream."
            }
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
            let output = try await api.client.liveStreamList(
                path: .init(libraryId: Int64(libraryId))
            )
            switch output {
            case .ok(let ok):
                if case .json(let model) = ok.body {
                    streams = model.items ?? []
                    loadingState = .loaded
                } else {
                    loadingState = .failed("OK but unexpected body format.")
                }
            case .unauthorized:
                loadingState = .failed("Unauthorized — check your Access Key.")
            case .internalServerError:
                loadingState = .failed("Server error. Try again.")
            case .undocumented(statusCode: 404, _):
                // Bunny returns 404 when no streams exist yet — treat as empty list
                streams = []
                loadingState = .loaded
            case .undocumented(statusCode: let code, _):
                loadingState = .failed("HTTP \(code) — check API URL or credentials.")
            default:
                loadingState = .failed("Unexpected response type.")
            }
        } catch {
            loadingState = .failed(error.localizedDescription)
        }
    }
}
