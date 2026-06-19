import BunnyStreamAPI
import BunnyStreamUploader
import Foundation

@MainActor
class LiveStreamListViewModel: ObservableObject {
    enum LoadingState {
        case loading, loaded, failed(String)
    }

    @Published var streams: [Components.Schemas.LiveStreamModel] = []
    @Published var loadingState: LoadingState = .loading

    private let api: BunnyStreamAPI
    let libraryId: Int
    let accessKey: String

    init(api: BunnyStreamAPI, libraryId: Int, accessKey: String) {
        self.api = api
        self.libraryId = libraryId
        self.accessKey = accessKey
    }

    func create(
        name: String,
        scheduledStartTime: Date? = nil,
        enableCountdown: Bool = false,
        dvrEnabled: Bool = false,
        dvrWindowSeconds: Int? = nil,
        recordVod: Bool = false,
        trailerVideoId: String? = nil
    ) async throws -> Components.Schemas.LiveStreamModel {
        var model = Components.Schemas.CreateLiveStreamModel(title: name)
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
