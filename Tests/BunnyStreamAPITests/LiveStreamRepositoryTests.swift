import XCTest
import HTTPTypes
import OpenAPIRuntime

@testable import BunnyStreamAPI

/// Answers every request with a canned status and body, so the repository is exercised through
/// the real generated client and its decoding.
private struct StubTransport: ClientTransport {
  let status: HTTPResponse.Status
  let json: String?
  private(set) var recordedPath: URLBox = URLBox()

  final class URLBox: @unchecked Sendable {
    var value: URL?
  }

  init(status: HTTPResponse.Status, json: String? = nil) {
    self.status = status
    self.json = json
  }

  func send(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String
  ) async throws -> (HTTPResponse, HTTPBody?) {
    recordedPath.value = URL(string: request.path ?? "", relativeTo: baseURL)
    guard let json else {
      return (HTTPResponse(status: status), nil)
    }
    var response = HTTPResponse(status: status)
    response.headerFields[.contentType] = "application/json"
    return (response, HTTPBody(json))
  }
}

private func makeRepository(
  status: HTTPResponse.Status,
  json: String? = nil
) -> (DefaultLiveStreamRepository, StubTransport) {
  let transport = StubTransport(status: status, json: json)
  let api = BunnyStreamAPI(accessKey: "test-key", transport: transport)
  return (DefaultLiveStreamRepository(bunnyStreamAPI: api), transport)
}

/// 2026-07-01T08:20:00 UTC — the timestamp used across the fixtures below.
private let referenceDate = DateComponents(
  calendar: Calendar(identifier: .gregorian),
  timeZone: TimeZone(identifier: "UTC"),
  year: 2026, month: 7, day: 1, hour: 8, minute: 20
).date!

final class LiveStreamRepositoryTests: XCTestCase {

  // MARK: - Domain mapping

  func testGetLiveStreamMapsToDomainModel() async throws {
    let json = """
    {
      "guid": "stream-guid",
      "videoLibraryId": 123,
      "title": "Morning show",
      "streamKey": "secret-key",
      "playbackUrlHls": "https://cdn.example.com/live.m3u8",
      "ingestEndpoints": {
        "rtmp": {
          "primaryIngestUrl": "rtmp://global.rtmp.example.net/live",
          "backupIngestUrl": "rtmp://global-backup.rtmp.example.net/live"
        }
      },
      "status": 4,
      "dvrEnabled": true,
      "dvrWindowSeconds": 300,
      "recordVod": true,
      "public": true,
      "scheduledStartTime": "2026-07-01T08:20:00",
      "rtmpOutputs": [{ "endpoint": "rtmp://out.example.com/app", "streamKey": "out-key" }]
    }
    """
    let (repository, _) = makeRepository(status: .ok, json: json)

    let stream = try await repository.getLiveStream(libraryId: 123, streamId: "stream-guid")

    XCTAssertEqual(stream.id, "stream-guid")
    XCTAssertEqual(stream.libraryId, 123)
    XCTAssertEqual(stream.title, "Morning show")
    XCTAssertEqual(stream.streamKey, "secret-key")
    XCTAssertEqual(stream.playbackUrl, "https://cdn.example.com/live.m3u8")
    XCTAssertEqual(stream.primaryIngestUrl, "rtmp://global.rtmp.example.net/live")
    XCTAssertEqual(stream.backupIngestUrl, "rtmp://global-backup.rtmp.example.net/live")
    XCTAssertEqual(stream.status, .running)
    XCTAssertTrue(stream.dvrEnabled)
    XCTAssertEqual(stream.dvrWindowSeconds, 300)
    XCTAssertTrue(stream.recordVod)
    XCTAssertTrue(stream.isPublic)
    XCTAssertEqual(stream.rtmpOutputs, [BunnyRtmpOutput(endpoint: "rtmp://out.example.com/app", streamKey: "out-key")])
    // Bunny returns this one without a zone marker; it has to be read as UTC.
    XCTAssertEqual(stream.scheduledStartTime, referenceDate)
  }

  /// The regression this guards: status 0 and 3 were absent from the spec, so a response
  /// carrying either failed to decode *entirely* against the frozen generated enum.
  func testStatusZeroAndPreviewDecode() async throws {
    for (raw, expected) in [(0, BunnyLiveStreamStatus.unknown), (3, .preview)] {
      let (repository, _) = makeRepository(status: .ok, json: #"{"guid":"g","status":\#(raw)}"#)
      let stream = try await repository.getLiveStream(libraryId: 1, streamId: "g")
      XCTAssertEqual(stream.status, expected, "status \(raw) should decode")
    }
  }

  func testDvrWindowIsZeroWhenDvrDisabled() async throws {
    let json = #"{"guid":"g","dvrEnabled":false,"dvrWindowSeconds":300}"#
    let (repository, _) = makeRepository(status: .ok, json: json)

    let stream = try await repository.getLiveStream(libraryId: 1, streamId: "g")

    XCTAssertFalse(stream.dvrEnabled)
    XCTAssertEqual(stream.dvrWindowSeconds, 0, "a stale window must not imply DVR is available")
  }

  func testListMapsPagination() async throws {
    let json = """
    { "totalItems": 7, "currentPage": 2, "itemsPerPage": 3,
      "items": [{ "guid": "a", "status": 1 }, { "guid": "b", "status": 5 }] }
    """
    let (repository, _) = makeRepository(status: .ok, json: json)

    let list = try await repository.listLiveStreams(libraryId: 1, page: 2, itemsPerPage: 3)

    XCTAssertEqual(list.totalItems, 7)
    XCTAssertEqual(list.currentPage, 2)
    XCTAssertEqual(list.itemsPerPage, 3)
    XCTAssertEqual(list.items.map(\.id), ["a", "b"])
    XCTAssertEqual(list.items.map(\.status), [.created, .ended])
  }

  func testIngestStatusMapping() async throws {
    let json = """
    { "readyToStart": true, "primaryLive": false, "backupLive": true,
      "lastPingAgo": 1200, "duration": 45, "statusTimeUtc": "2026-07-01T08:20:00Z" }
    """
    let (repository, _) = makeRepository(status: .ok, json: json)

    let status = try await repository.ingestStatus(libraryId: 1, streamId: "g")

    XCTAssertTrue(status.readyToStart)
    XCTAssertEqual(status.primaryLive, false)
    XCTAssertEqual(status.backupLive, true)
    XCTAssertTrue(status.isLive, "backup alone counts as live")
    XCTAssertEqual(status.lastPingAgo, 1200)
    XCTAssertEqual(status.duration, 45)
  }

  /// Absent liveness must stay absent: the broadcaster shows "unknown" rather than "offline",
  /// and proactive failover must not read a missing value as a dead ingest.
  func testIngestStatusKeepsUnreportedLivenessNil() async throws {
    let (repository, _) = makeRepository(status: .ok, json: #"{"readyToStart":false}"#)

    let status = try await repository.ingestStatus(libraryId: 1, streamId: "g")

    XCTAssertNil(status.primaryLive)
    XCTAssertNil(status.backupLive)
    XCTAssertFalse(status.isLive)
  }

  func testPlayDataSplitsControlList() async throws {
    let json = """
    { "videoPlaylistUrl": "https://cdn.example.com/live.m3u8",
      "controls": "play,volume, fullscreen ,", "enableDRM": true, "playerKeyColor": "#ff0000" }
    """
    let (repository, _) = makeRepository(status: .ok, json: json)

    let playData = try await repository.fetchPlayData(libraryId: 1, streamId: "g")

    XCTAssertEqual(playData.controls, ["play", "volume", "fullscreen"])
    XCTAssertTrue(playData.isDRMEnabled)
    XCTAssertEqual(playData.playerKeyColor, "#ff0000")
  }

  func testThumbnailListMapping() async throws {
    let json = #"[{"url":"https://cdn.example.com/1.jpg","timestamp":"2026-07-01T08:20:00Z"}]"#
    let (repository, _) = makeRepository(status: .ok, json: json)

    let thumbnails = try await repository.listThumbnails(libraryId: 1, streamId: "g", limit: 1)

    XCTAssertEqual(thumbnails.count, 1)
    XCTAssertEqual(thumbnails.first?.url, "https://cdn.example.com/1.jpg")
    XCTAssertEqual(thumbnails.first?.timestamp, referenceDate)
  }

  // MARK: - Errors

  func testUnauthorizedCarriesStatusCodeAndIsPermanent() async throws {
    let (repository, _) = makeRepository(status: .unauthorized)

    do {
      _ = try await repository.getLiveStream(libraryId: 1, streamId: "g")
      XCTFail("Expected a failure")
    } catch let error as BunnyLiveStreamError {
      XCTAssertEqual(error.kind, .unauthorized)
      XCTAssertEqual(error.statusCode, 401)
      XCTAssertTrue(error.isPermanent)
    }
  }

  func testNotFoundIsPermanent() async throws {
    let (repository, _) = makeRepository(status: .notFound)

    do {
      _ = try await repository.getLiveStream(libraryId: 1, streamId: "g")
      XCTFail("Expected a failure")
    } catch let error as BunnyLiveStreamError {
      XCTAssertEqual(error.kind, .notFound)
      XCTAssertTrue(error.isPermanent)
    }
  }

  /// The distinction the whole error type exists for: a poll loop keeps going on 5xx.
  func testServerErrorIsTransient() async throws {
    let (repository, _) = makeRepository(status: .internalServerError)

    do {
      _ = try await repository.getLiveStream(libraryId: 1, streamId: "g")
      XCTFail("Expected a failure")
    } catch let error as BunnyLiveStreamError {
      XCTAssertEqual(error.kind, .server)
      XCTAssertEqual(error.statusCode, 500)
      XCTAssertFalse(error.isPermanent, "5xx is worth retrying")
    }
  }

  func testUndocumentedStatusKeepsCodeAndBody() async throws {
    let (repository, _) = makeRepository(status: .init(code: 418), json: #"{"detail":"teapot"}"#)

    do {
      _ = try await repository.getLiveStream(libraryId: 1, streamId: "g")
      XCTFail("Expected a failure")
    } catch let error as BunnyLiveStreamError {
      XCTAssertEqual(error.kind, .unexpected)
      XCTAssertEqual(error.statusCode, 418)
      XCTAssertEqual(error.message, #"{"detail":"teapot"}"#)
    }
  }

  func testGoneMapsToNotFoundAndIsPermanent() async throws {
    let (repository, _) = makeRepository(status: .gone)

    do {
      _ = try await repository.getLiveStream(libraryId: 1, streamId: "g")
      XCTFail("Expected a failure")
    } catch let error as BunnyLiveStreamError {
      XCTAssertEqual(error.kind, .notFound, "410 is as final as 404")
      XCTAssertEqual(error.statusCode, 410)
      XCTAssertTrue(error.isPermanent)
    }
  }

  func testForbiddenMapsToUnauthorized() async throws {
    let (repository, _) = makeRepository(status: .forbidden)

    do {
      _ = try await repository.getLiveStream(libraryId: 1, streamId: "g")
      XCTFail("Expected a failure")
    } catch let error as BunnyLiveStreamError {
      XCTAssertEqual(error.kind, .unauthorized)
      XCTAssertTrue(error.isPermanent)
    }
  }

  /// Endpoints answering with `StatusModel` can report failure inside a 200.
  func testStopSurfacesFailureReportedInsideOk() async throws {
    let json = #"{"success":false,"message":"Stream already ended","statusCode":400}"#
    let (repository, _) = makeRepository(status: .ok, json: json)

    do {
      try await repository.stopLiveStream(libraryId: 1, streamId: "g")
      XCTFail("Expected a failure")
    } catch let error as BunnyLiveStreamError {
      XCTAssertEqual(error.kind, .invalidRequest)
      XCTAssertEqual(error.message, "Stream already ended")
    }
  }

  func testStopSucceedsOnSuccessfulStatus() async throws {
    let (repository, _) = makeRepository(status: .ok, json: #"{"success":true}"#)

    try await repository.stopLiveStream(libraryId: 1, streamId: "g")
  }

  func testDeleteThumbnailAcceptsNoContent() async throws {
    let (repository, _) = makeRepository(status: .noContent)

    try await repository.deleteThumbnail(libraryId: 1, streamId: "g")
  }
}
