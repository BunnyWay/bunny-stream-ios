import Foundation
import OpenAPIRuntime

/// High-level access to the Manage Live Streams API.
///
/// Wraps the generated client and speaks only in domain types, so regenerating the client can't
/// change this surface. Every method throws ``BunnyLiveStreamError``, which carries the HTTP
/// status code — poll loops can branch on `isPermanent` instead of needing a separate polling
/// variant of each call.
public protocol LiveStreamRepository: Sendable {
  /// Lists live streams in a library. Pass `nil` for any parameter to accept the server default.
  func listLiveStreams(
    libraryId: Int,
    page: Int?,
    itemsPerPage: Int?,
    search: String?,
    orderBy: String?
  ) async throws -> BunnyLiveStreamList

  /// Fetches a single live stream by its GUID.
  func getLiveStream(libraryId: Int, streamId: String) async throws -> BunnyLiveStream

  /// Creates a live stream. Returns the created stream, so the assigned id and stream key are
  /// available without a follow-up fetch.
  func createLiveStream(
    libraryId: Int,
    request: BunnyLiveStreamCreateRequest
  ) async throws -> BunnyLiveStream

  /// Updates a live stream and returns the updated version.
  func updateLiveStream(
    libraryId: Int,
    streamId: String,
    request: BunnyLiveStreamUpdateRequest
  ) async throws -> BunnyLiveStream

  /// Permanently deletes a live stream. Any recorded VOD stays in the library.
  func deleteLiveStream(libraryId: Int, streamId: String) async throws

  /// Takes the stream live. Call once the encoder is connected and the stream is in
  /// ``BunnyLiveStreamStatus/preview``; it moves to ``BunnyLiveStreamStatus/running``.
  func startLiveStream(libraryId: Int, streamId: String) async throws

  /// Stops the stream. The ingest server cuts the publish, and with `recordVod` enabled the
  /// stream is converted to a VOD. Cannot be undone.
  func stopLiveStream(libraryId: Int, streamId: String) async throws

  /// Issues a new stream key, invalidating the old one. Rejected once a stream has ended.
  func regenerateStreamKey(libraryId: Int, streamId: String) async throws -> BunnyLiveStream

  /// Fetches playback data. `token`/`expires` are forwarded for token-authenticated libraries.
  func fetchPlayData(
    libraryId: Int,
    streamId: String,
    token: String?,
    expires: Int64?
  ) async throws -> BunnyLiveStreamPlayData

  /// Fetches the lightweight ingest status — the endpoint suited to frequent polling.
  func ingestStatus(libraryId: Int, streamId: String) async throws -> BunnyLiveStreamIngestStatus

  /// Sets the offline thumbnail from a remote image URL.
  func setThumbnail(libraryId: Int, streamId: String, thumbnailUrl: String) async throws

  /// Uploads a local image as the offline thumbnail.
  func uploadThumbnail(
    libraryId: Int,
    streamId: String,
    imageData: Data,
    format: BunnyImageFormat
  ) async throws

  /// Lists recently captured thumbnails, most recent first.
  /// - Parameters:
  ///   - limit: How many to return. The server defaults to 5.
  ///   - from: Lower bound (inclusive) on capture time.
  ///   - to: Upper bound (inclusive) on capture time.
  func listThumbnails(
    libraryId: Int,
    streamId: String,
    limit: Int?,
    from: Date?,
    to: Date?
  ) async throws -> [BunnyLiveStreamThumbnail]

  /// Removes the custom offline thumbnail.
  /// - Parameter restoreLibraryDefault: Fall back to the library's default live thumbnail, when
  ///   one is configured, instead of leaving the stream with no thumbnail.
  func deleteThumbnail(
    libraryId: Int,
    streamId: String,
    restoreLibraryDefault: Bool
  ) async throws
}

// MARK: - Implementation

/// The ``LiveStreamRepository`` backed by the generated Bunny Stream client.
///
/// Optional parameters carry defaults here, so most calls stay short. A protocol requirement
/// can't declare defaults, so code working through ``LiveStreamRepository`` has to pass them.
public struct DefaultLiveStreamRepository: LiveStreamRepository {
  private let client: any APIProtocol

  public init(bunnyStreamAPI: BunnyStreamAPI) {
    self.client = bunnyStreamAPI.client
  }

  /// Injects a client directly. Useful for tests with a stub `APIProtocol`.
  public init(client: any APIProtocol) {
    self.client = client
  }

  public func listLiveStreams(
    libraryId: Int,
    page: Int? = nil,
    itemsPerPage: Int? = nil,
    search: String? = nil,
    orderBy: String? = nil
  ) async throws -> BunnyLiveStreamList {
    try await perform {
      let output = try await client.liveStreamList(
        path: .init(libraryId: Int64(libraryId)),
        query: .init(
          page: page.map(Int32.init),
          itemsPerPage: itemsPerPage.map(Int32.init),
          search: search,
          orderBy: orderBy
        )
      )
      switch output {
      case .ok(let response):
        guard case .json(let model) = response.body else { throw invalidResponse }
        return BunnyLiveStreamList(from: model)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func getLiveStream(libraryId: Int, streamId: String) async throws -> BunnyLiveStream {
    try await perform {
      let output = try await client.liveStreamGet(
        path: .init(libraryId: Int64(libraryId), streamId: streamId)
      )
      switch output {
      case .ok(let response):
        guard case .json(let model) = response.body else { throw invalidResponse }
        return BunnyLiveStream(from: model)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func createLiveStream(
    libraryId: Int,
    request: BunnyLiveStreamCreateRequest
  ) async throws -> BunnyLiveStream {
    try await perform {
      let output = try await client.liveStreamCreate(
        path: .init(libraryId: Int64(libraryId)),
        body: .json(request.apiModel)
      )
      switch output {
      case .created(let response):
        guard case .json(let model) = response.body else { throw invalidResponse }
        return BunnyLiveStream(from: model)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func updateLiveStream(
    libraryId: Int,
    streamId: String,
    request: BunnyLiveStreamUpdateRequest
  ) async throws -> BunnyLiveStream {
    try await perform {
      let output = try await client.liveStreamUpdate(
        path: .init(libraryId: Int64(libraryId), streamId: streamId),
        body: .json(request.apiModel)
      )
      switch output {
      case .ok(let response):
        guard case .json(let model) = response.body else { throw invalidResponse }
        return BunnyLiveStream(from: model)
      case .badRequest:
        throw BunnyLiveStreamError(kind: .invalidRequest, statusCode: 400)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func deleteLiveStream(libraryId: Int, streamId: String) async throws {
    try await perform {
      let output = try await client.liveStreamDelete(
        path: .init(libraryId: Int64(libraryId), streamId: streamId)
      )
      switch output {
      case .ok:
        return
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func startLiveStream(libraryId: Int, streamId: String) async throws {
    try await perform {
      let output = try await client.liveStreamActivate(
        path: .init(libraryId: Int64(libraryId), streamId: streamId)
      )
      switch output {
      case .ok(let response):
        guard case .json(let status) = response.body else { throw invalidResponse }
        try Self.throwIfUnsuccessful(status)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func stopLiveStream(libraryId: Int, streamId: String) async throws {
    try await perform {
      let output = try await client.liveStreamComplete(
        path: .init(libraryId: Int64(libraryId), streamId: streamId)
      )
      switch output {
      case .ok(let response):
        guard case .json(let status) = response.body else { throw invalidResponse }
        try Self.throwIfUnsuccessful(status)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func regenerateStreamKey(libraryId: Int, streamId: String) async throws -> BunnyLiveStream {
    try await perform {
      let output = try await client.liveStreamRegenerateStreamKey(
        path: .init(libraryId: Int64(libraryId), streamId: streamId)
      )
      switch output {
      case .ok(let response):
        guard case .json(let model) = response.body else { throw invalidResponse }
        return BunnyLiveStream(from: model)
      case .badRequest:
        throw BunnyLiveStreamError(kind: .invalidRequest, statusCode: 400)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func fetchPlayData(
    libraryId: Int,
    streamId: String,
    token: String? = nil,
    expires: Int64? = nil
  ) async throws -> BunnyLiveStreamPlayData {
    try await perform {
      let output = try await client.liveStreamGetStreamPlayData(
        path: .init(libraryId: Int64(libraryId), streamId: streamId),
        query: .init(token: token, expires: expires)
      )
      switch output {
      case .ok(let response):
        guard case .json(let model) = response.body else { throw invalidResponse }
        return BunnyLiveStreamPlayData(from: model)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func ingestStatus(
    libraryId: Int,
    streamId: String
  ) async throws -> BunnyLiveStreamIngestStatus {
    try await perform {
      let output = try await client.liveStreamGetStreamStatus(
        path: .init(libraryId: Int64(libraryId), streamId: streamId)
      )
      switch output {
      case .ok(let response):
        guard case .json(let model) = response.body else { throw invalidResponse }
        return BunnyLiveStreamIngestStatus(from: model)
      case .badRequest:
        throw BunnyLiveStreamError(kind: .invalidRequest, statusCode: 400)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func setThumbnail(libraryId: Int, streamId: String, thumbnailUrl: String) async throws {
    try await perform {
      let output = try await client.liveStreamSetThumbnail(
        path: .init(libraryId: Int64(libraryId), streamId: streamId),
        query: .init(thumbnailUrl: thumbnailUrl)
      )
      try await Self.handleSetThumbnail(output)
    }
  }

  public func uploadThumbnail(
    libraryId: Int,
    streamId: String,
    imageData: Data,
    format: BunnyImageFormat
  ) async throws {
    try await perform {
      let body = HTTPBody(imageData)
      let requestBody: Operations.LiveStreamSetThumbnail.Input.Body
      switch format {
      case .jpeg: requestBody = .jpeg(body)
      case .png: requestBody = .png(body)
      case .webp: requestBody = .imageWebp(body)
      case .gif: requestBody = .imageGif(body)
      }
      let output = try await client.liveStreamSetThumbnail(
        path: .init(libraryId: Int64(libraryId), streamId: streamId),
        body: requestBody
      )
      try await Self.handleSetThumbnail(output)
    }
  }

  public func listThumbnails(
    libraryId: Int,
    streamId: String,
    limit: Int? = nil,
    from: Date? = nil,
    to: Date? = nil
  ) async throws -> [BunnyLiveStreamThumbnail] {
    try await perform {
      let output = try await client.liveStreamGetThumbnails(
        path: .init(libraryId: Int64(libraryId), streamId: streamId),
        query: .init(
          limit: limit.map(Int32.init),
          from: from.map(Self.timestampFormatter.string(from:)),
          to: to.map(Self.timestampFormatter.string(from:))
        )
      )
      switch output {
      case .ok(let response):
        guard case .json(let models) = response.body else { throw invalidResponse }
        return models.map(BunnyLiveStreamThumbnail.init(from:))
      case .badRequest:
        throw BunnyLiveStreamError(kind: .invalidRequest, statusCode: 400)
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }

  public func deleteThumbnail(
    libraryId: Int,
    streamId: String,
    restoreLibraryDefault: Bool = false
  ) async throws {
    try await perform {
      let output = try await client.liveStreamDeleteThumbnail(
        path: .init(libraryId: Int64(libraryId), streamId: streamId),
        query: .init(restoreLibraryDefault: restoreLibraryDefault)
      )
      switch output {
      case .noContent:
        return
      case .unauthorized:
        throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
      case .notFound:
        throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
      case .internalServerError:
        throw BunnyLiveStreamError(kind: .server, statusCode: 500)
      case .undocumented(let statusCode, let payload):
        throw await undocumented(statusCode, payload)
      }
    }
  }
}

// MARK: - Shared handling

private extension DefaultLiveStreamRepository {
  var invalidResponse: BunnyLiveStreamError {
    BunnyLiveStreamError(kind: .invalidResponse)
  }

  /// Runs an operation, converting anything the generated client throws — transport failures,
  /// decoding failures — into ``BunnyLiveStreamError``. Errors already of that type pass through.
  func perform<T>(_ operation: () async throws -> T) async throws -> T {
    do {
      return try await operation()
    } catch let error as BunnyLiveStreamError {
      throw error
    } catch is CancellationError {
      throw BunnyLiveStreamError(kind: .transport, message: "The request was cancelled.")
    } catch let error as ClientError {
      // The generated client wraps the underlying failure; a URLError means it never reached
      // the server, anything else means the response couldn't be parsed.
      if error.underlyingError is URLError {
        throw BunnyLiveStreamError(
          kind: .transport,
          message: error.underlyingError.localizedDescription
        )
      }
      throw BunnyLiveStreamError(
        kind: .invalidResponse,
        message: error.underlyingError.localizedDescription
      )
    } catch let error as URLError {
      throw BunnyLiveStreamError(kind: .transport, message: error.localizedDescription)
    } catch {
      throw BunnyLiveStreamError(kind: .unexpected, message: error.localizedDescription)
    }
  }

  /// Reads an undocumented response, keeping its status code and whatever body text came with it.
  func undocumented(
    _ statusCode: Int,
    _ payload: UndocumentedPayload
  ) async -> BunnyLiveStreamError {
    var message: String?
    if let body = payload.body,
       let data = try? await Data(collecting: body, upTo: 4096),
       let text = String(data: data, encoding: .utf8),
       !text.isEmpty {
      message = text
    }
    return .forStatusCode(statusCode, message: message)
  }

  /// The Set Thumbnail endpoint answers the URL and the upload form identically.
  static func handleSetThumbnail(_ output: Operations.LiveStreamSetThumbnail.Output) async throws {
    switch output {
    case .ok(let response):
      guard case .json(let status) = response.body else {
        throw BunnyLiveStreamError(kind: .invalidResponse)
      }
      try throwIfUnsuccessful(status)
    case .badRequest:
      throw BunnyLiveStreamError(kind: .invalidRequest, statusCode: 400)
    case .unauthorized:
      throw BunnyLiveStreamError(kind: .unauthorized, statusCode: 401)
    case .notFound:
      throw BunnyLiveStreamError(kind: .notFound, statusCode: 404)
    case .unprocessableContent:
      throw BunnyLiveStreamError(
        kind: .unprocessable,
        statusCode: 422,
        message: "Unable to fetch the thumbnail from the origin."
      )
    case .internalServerError:
      throw BunnyLiveStreamError(kind: .server, statusCode: 500)
    case .undocumented(let statusCode, _):
      throw BunnyLiveStreamError.forStatusCode(statusCode)
    }
  }

  /// Endpoints that answer with `StatusModel` can report failure inside a 200.
  static func throwIfUnsuccessful(_ status: Components.Schemas.StatusModel) throws {
    guard status.success == false else { return }
    throw BunnyLiveStreamError(
      kind: status.statusCode.map { Int($0) }.map { code in
        BunnyLiveStreamError.forStatusCode(code).kind
      } ?? .unexpected,
      statusCode: status.statusCode.map { Int($0) },
      message: status.message
    )
  }

  static let timestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
  }()
}
