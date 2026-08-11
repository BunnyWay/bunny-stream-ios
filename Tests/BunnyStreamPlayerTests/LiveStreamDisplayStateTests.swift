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
        XCTAssertEqual(message, .notActive)
    }

    func test_offline_notActive_whenPreview() {
        // Preview means an encoder is connected but the stream hasn't been taken live —
        // viewers can't watch yet, so it renders as not-active rather than playable.
        let model = makeModel(status: .preview)
        guard case .offline = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
    }

    func test_offline_notActive_whenUnknown() {
        let model = makeModel(status: .unknown)
        guard case .offline = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
    }

    func test_offline_ended_whenEndedWithoutRecordVod() {
        let model = makeModel(status: .ended, recordVod: false)
        guard case .offline(let message, _) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .offline")
        }
        XCTAssertEqual(message, .ended, "an ended stream says so, rather than 'not active'")
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
            scheduledStartTime: futureDate
        )
        guard case .countdown(let date, _, _) = resolveDisplayState(from: model, now: Date()) else {
            return XCTFail("Expected .countdown")
        }
        XCTAssertGreaterThan(date, Date())
    }

    func test_noCountdown_whenScheduledWithPastDate() {
        let pastDate = Date().addingTimeInterval(-3600)
        let model = makeModel(
            status: .scheduled,
            enableCountdown: true,
            scheduledStartTime: pastDate
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
            scheduledStartTime: futureDate
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
        guard case .trailer(let vodId, _, _, _) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .trailer")
        }
        XCTAssertEqual(vodId, "abc-123")
    }

    func test_trailer_whenPreviewAndNotStarted() {
        // Mirrors Android, which counts PREVIEW as a pre-start state for the trailer.
        let model = makeModel(
            status: .preview,
            preStreamTrailerVideoId: "abc-123",
            startedAt: nil
        )
        guard case .trailer(let vodId, _, _, _) = resolveDisplayState(from: model) else {
            return XCTFail("Expected .trailer")
        }
        XCTAssertEqual(vodId, "abc-123")
    }

    func test_noTrailer_whenStreamAlreadyStarted() {
        let model = makeModel(
            status: .scheduled,
            preStreamTrailerVideoId: "abc-123",
            startedAt: Date()
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
            scheduledStartTime: futureDate,
            thumbnailUrl: "https://cdn.example.com/thumb.jpg"
        )
        guard case .countdown(_, let url, _) = resolveDisplayState(from: model, now: Date()) else {
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

// MARK: - Helpers

/// Only the fields the resolver reads are passed; the rest of ``BunnyLiveStream`` is defaulted.
private func makeModel(
    status: BunnyLiveStreamStatus = .unknown,
    recordVod: Bool = false,
    enableCountdown: Bool = false,
    scheduledStartTime: Date? = nil,
    preStreamTrailerVideoId: String? = nil,
    startedAt: Date? = nil,
    playbackUrlHls: String? = nil,
    thumbnailUrl: String? = nil
) -> BunnyLiveStream {
    BunnyLiveStream(
        id: "test-guid",
        libraryId: 123,
        title: "Test Stream",
        playbackUrl: playbackUrlHls,
        status: status,
        recordVod: recordVod,
        scheduledStartTime: scheduledStartTime,
        enableCountdown: enableCountdown,
        preStreamTrailerVideoId: preStreamTrailerVideoId,
        startedAt: startedAt,
        thumbnailUrl: thumbnailUrl
    )
}
