import XCTest
import BunnyStreamAPI
@testable import BunnyStreamPlayer

final class LiveStreamDisplayStateTests: XCTestCase {

    // MARK: - Playable

    func test_playable_whenRunning() {
        let model = makeModel(status: .running, playbackUrlHls: "https://example.com/live.m3u8")
        guard case .playable(let url, let isVod) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .playable")
        }
        XCTAssertEqual(url.absoluteString, "https://example.com/live.m3u8")
        XCTAssertFalse(isVod)
    }

    func test_playable_whenEndedWithRecordVod() {
        let model = makeModel(status: .ended, recordVod: true, playbackUrlHls: "https://example.com/live.m3u8")
        guard case .playable(_, let isVod) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .playable")
        }
        XCTAssertTrue(isVod)
    }

    func test_playable_whenVodProcessingWithRecordVod() {
        let model = makeModel(status: .vodProcessing, recordVod: true, playbackUrlHls: "https://example.com/live.m3u8")
        guard case .playable = resolveDisplayState(from: model) else {
            return XCTFail("Expected .playable")
        }
    }

    func test_error_whenRunningButMissingUrl() {
        let model = makeModel(status: .running, playbackUrlHls: nil)
        guard case .error = resolveDisplayState(from: model) else {
            return XCTFail("Expected .error when playbackUrlHls is nil")
        }
    }

    // MARK: - Offline

    func test_offline_notActive_whenCreated() {
        let model = makeModel(status: .created)
        guard case .offline(let message, _) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func test_offline_ended_whenEndedWithoutRecordVod() {
        let model = makeModel(status: .ended, recordVod: false)
        guard case .offline = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
    }

    func test_offline_whenVodProcessingWithoutRecordVod() {
        let model = makeModel(status: .vodProcessing, recordVod: false)
        guard case .offline = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
    }

    // MARK: - Error

    func test_error_whenStatusError() {
        let model = makeModel(status: .error)
        guard case .error = resolveDisplayState(from: model) else {
            return XCTFail("Expected .error")
        }
    }

    // MARK: - Countdown

    func test_countdown_whenScheduledWithFutureDate() {
        let futureDate = Date().addingTimeInterval(3600)
        let model = makeModel(
            status: .scheduled,
            enableCountdown: true,
            scheduledStartTime: iso8601(futureDate)
        )
        guard case .countdown(let date, _) = resolveDisplayState(from: model, now: Date()) else {
            return XCTFail("Expected .countdown")
        }
        XCTAssertGreaterThan(date, Date())
    }

    func test_noCountdown_whenScheduledWithPastDate() {
        let pastDate = Date().addingTimeInterval(-3600)
        let model = makeModel(
            status: .scheduled,
            enableCountdown: true,
            scheduledStartTime: iso8601(pastDate)
        )
        guard case .offline = resolveDisplayState(from: model, now: Date()) else {
            return XCTFail("Expected .offline for past scheduled date")
        }
    }

    func test_noCountdown_whenCountdownDisabled() {
        let futureDate = Date().addingTimeInterval(3600)
        let model = makeModel(
            status: .scheduled,
            enableCountdown: false,
            scheduledStartTime: iso8601(futureDate)
        )
        guard case .offline = resolveDisplayState(from: model, now: Date()) else {
            return XCTFail("Expected .offline when countdown disabled")
        }
    }

    // MARK: - Trailer

    func test_trailer_whenPreStreamTrailerSetAndNotStarted() {
        let model = makeModel(
            status: .scheduled,
            preStreamTrailerVideoId: "abc-123",
            startedAt: nil
        )
        guard case .trailer(let vodId, _) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .trailer")
        }
        XCTAssertEqual(vodId, "abc-123")
    }

    func test_noTrailer_whenStreamAlreadyStarted() {
        let model = makeModel(
            status: .scheduled,
            preStreamTrailerVideoId: "abc-123",
            startedAt: "2026-06-04T10:00:00"
        )
        if case .trailer = resolveDisplayState(from: model) {
            XCTFail("Should not show trailer after stream started")
        }
    }

    func test_noTrailer_whenRunning() {
        let model = makeModel(
            status: .running,
            preStreamTrailerVideoId: "abc-123",
            playbackUrlHls: "https://example.com/live.m3u8"
        )
        guard case .playable = resolveDisplayState(from: model) else {
            return XCTFail("Expected .playable, not .trailer")
        }
    }

    // MARK: - Thumbnail passthrough

    func test_thumbnailPassedToOffline() {
        let model = makeModel(status: .created, thumbnailUrl: "https://cdn.example.com/thumb.jpg")
        guard case .offline(_, let url) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
        XCTAssertEqual(url?.absoluteString, "https://cdn.example.com/thumb.jpg")
    }

    func test_thumbnailPassedToCountdown() {
        let futureDate = Date().addingTimeInterval(3600)
        let model = makeModel(
            status: .scheduled,
            enableCountdown: true,
            scheduledStartTime: iso8601(futureDate),
            thumbnailUrl: "https://cdn.example.com/thumb.jpg"
        )
        guard case .countdown(_, let url) = resolveDisplayState(from: model, now: Date()) else {
            return XCTFail("Expected .countdown")
        }
        XCTAssertEqual(url?.absoluteString, "https://cdn.example.com/thumb.jpg")
    }

    func test_nilThumbnailWhenNotSet() {
        let model = makeModel(status: .created, thumbnailUrl: nil)
        guard case .offline(_, let url) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
        XCTAssertNil(url)
    }
}

// MARK: - Date parsing tests

final class BunnyDateParserTests: XCTestCase {

    func test_parsesFullISO8601WithMicroseconds() {
        XCTAssertNotNil(Date(bunnyString: "2026-06-04T18:42:24.671615Z"))
    }

    func test_parsesISO8601WithMilliseconds() {
        XCTAssertNotNil(Date(bunnyString: "2026-06-04T18:42:24.671Z"))
    }

    func test_parsesISO8601WithoutMilliseconds() {
        XCTAssertNotNil(Date(bunnyString: "2026-06-04T18:42:24"))
    }

    func test_parsesISO8601WithZSuffix() {
        XCTAssertNotNil(Date(bunnyString: "2026-06-04T18:42:24Z"))
    }

    func test_returnsNilForInvalidString() {
        XCTAssertNil(Date(bunnyString: "not-a-date"))
    }

    func test_returnsNilForEmptyString() {
        XCTAssertNil(Date(bunnyString: ""))
    }

    func test_parsedDateIsReasonable() {
        let date = Date(bunnyString: "2026-06-04T18:42:24Z")
        XCTAssertNotNil(date)
        // Year should be 2026
        let year = Calendar.current.component(.year, from: date!)
        XCTAssertEqual(year, 2026)
    }
}

// MARK: - Helpers

private func makeModel(
    status: Components.Schemas.LiveStreamStatus? = nil,
    recordVod: Bool? = nil,
    enableCountdown: Bool? = nil,
    scheduledStartTime: String? = nil,
    preStreamTrailerVideoId: String? = nil,
    startedAt: String? = nil,
    playbackUrlHls: String? = nil,
    thumbnailUrl: String? = nil
) -> Components.Schemas.LiveStreamModel {
    let statusPayload = status.map {
        Components.Schemas.LiveStreamModel.StatusPayload.LiveStreamStatus($0)
    }
    return Components.Schemas.LiveStreamModel(
        id: nil,
        guid: "test-guid",
        videoLibraryId: 123,
        name: nil,
        title: "Test Stream",
        streamKey: nil,
        rtmpUrl: nil,
        playbackUrl: nil,
        playbackUrlHls: playbackUrlHls,
        ingestEndpoint: nil,
        status: statusPayload,
        hasArchive: nil,
        recordVod: recordVod,
        enableCountdown: enableCountdown,
        scheduledStartTime: scheduledStartTime,
        preStreamTrailerVideoId: preStreamTrailerVideoId,
        startedAt: startedAt,
        thumbnailUrl: thumbnailUrl,
        additionalProperties: .init()
    )
}

private func iso8601(_ date: Date) -> String {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f.string(from: date)
}
