import XCTest
import AVFoundation
@testable import BunnyStreamPlayer

/// An HTTP 403 from the CDN — geo-blocking, referrer protection or token auth — must be recognised
/// however AVFoundation reports it, so the player shows "Video is not available" instead of a
/// generic failure.
final class PlaybackForbiddenDetectorTests: XCTestCase {

    private func coreMediaError(_ code: Int) -> NSError {
        NSError(domain: "CoreMediaErrorDomain", code: code)
    }

    // MARK: - Error chain

    func test_isForbidden_trueForCoreMedia403() {
        XCTAssertTrue(PlaybackForbiddenDetector.isForbidden(coreMediaError(-12660)))
    }

    // AVFoundation usually surfaces the CoreMedia error wrapped in a generic AVFoundation one.
    func test_isForbidden_trueWhenWrappedInAVFoundationError() {
        let error = NSError(domain: AVFoundationErrorDomain, code: -11800,
                            userInfo: [NSUnderlyingErrorKey: coreMediaError(-12660)])
        XCTAssertTrue(PlaybackForbiddenDetector.isForbidden(error))
    }

    func test_isForbidden_falseForCoreMedia404() {
        XCTAssertFalse(PlaybackForbiddenDetector.isForbidden(coreMediaError(-12938)))
    }

    func test_isForbidden_falseForNetworkError() {
        XCTAssertFalse(PlaybackForbiddenDetector.isForbidden(URLError(.notConnectedToInternet)))
    }

    // MARK: - Error log

    func test_logEntry_trueForHTTPStatus403() {
        XCTAssertTrue(PlaybackForbiddenDetector.isForbidden(statusCode: 403, domain: "NSURLErrorDomain", comment: nil))
    }

    func test_logEntry_trueForCoreMediaCode() {
        XCTAssertTrue(PlaybackForbiddenDetector.isForbidden(statusCode: -12660, domain: "CoreMediaErrorDomain", comment: nil))
    }

    func test_logEntry_trueForHTTP403Comment() {
        XCTAssertTrue(PlaybackForbiddenDetector.isForbidden(statusCode: -1, domain: "", comment: "HTTP 403: Forbidden"))
    }

    func test_logEntry_falseFor404() {
        XCTAssertFalse(PlaybackForbiddenDetector.isForbidden(statusCode: -12938, domain: "CoreMediaErrorDomain",
                                                              comment: "HTTP 404: File Not Found"))
    }
}
