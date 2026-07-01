import BunnyStreamAPI
import BunnyStreamPlayer
import BunnyStreamUploader
import Foundation

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
        thumbnailUrl: String? = nil
    ) async throws -> Components.Schemas.LiveStreamModel {
        var model = Components.Schemas.CreateLiveStreamModel(title: name)
        if let description, !description.isEmpty {
            model.description = description
        }
        if let thumbnailUrl, !thumbnailUrl.isEmpty {
            model.thumbnailUrl = thumbnailUrl
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
        isPublic: Bool? = nil
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

    func load() async {
        guard libraryId != 0 else {
            loadingState = .failed("Library ID not configured. Set it in BunnyStream Configuration.")
            return
        }
        loadingState = .loading
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
