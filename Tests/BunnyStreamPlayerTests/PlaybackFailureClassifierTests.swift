import AVFoundation
import XCTest
@testable import BunnyStreamPlayer

/// The player has to tell three things apart: a stream that is blocked for this viewer (terminal,
/// "Video is not available"), a device that is not on the network ("No internet connection",
/// still retryable), and everything else (bare retry). Getting this wrong is user-visible in
/// both directions — a permanent "not available" over a transient outage, or an endless retry
/// over a geo-block.
final class PlaybackFailureClassifierTests: XCTestCase {

    private func coreMediaError(_ code: Int) -> NSError {
        NSError(domain: "CoreMediaErrorDomain", code: code)
    }

    private func urlError(_ code: Int) -> NSError {
        NSError(domain: NSURLErrorDomain, code: code)
    }

    /// AVFoundation usually hands back its own error with the real cause underneath.
    private func wrapped(_ error: NSError) -> NSError {
        NSError(domain: AVFoundationErrorDomain, code: -11800,
                userInfo: [NSUnderlyingErrorKey: error])
    }

    // MARK: - Blocked

    func test_blocked_forCoreMedia403() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(coreMediaError(-12660)), .blocked)
    }

    func test_blocked_whenWrappedByAVFoundation() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(wrapped(coreMediaError(-12660))), .blocked)
    }

    /// A 403 outranks a connection failure: a DNS-level block surfaces as both, and there the
    /// video really is unavailable.
    func test_blocked_winsOverConnectionFailure() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost,
                            userInfo: [NSUnderlyingErrorKey: coreMediaError(-12660)])
        XCTAssertEqual(PlaybackFailureClassifier.classify(error), .blocked)
    }

    // MARK: - No connection

    func test_noConnection_forNotConnectedToInternet() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(urlError(NSURLErrorNotConnectedToInternet)),
                       .noConnection)
    }

    func test_noConnection_forConnectionLost() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(urlError(NSURLErrorNetworkConnectionLost)),
                       .noConnection)
    }

    func test_noConnection_forCellularDataDisallowed() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(urlError(NSURLErrorDataNotAllowed)),
                       .noConnection)
    }

    /// CoreMedia reuses NSURLError numbering under its own domain.
    func test_noConnection_underCoreMediaDomain() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(coreMediaError(NSURLErrorNotConnectedToInternet)),
                       .noConnection)
    }

    func test_noConnection_whenWrappedByAVFoundation() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(wrapped(urlError(NSURLErrorNotConnectedToInternet))),
                       .noConnection)
    }

    // MARK: - Unreachable (needs a DNS check)

    /// What a sinkholed host looks like: something was dialled and refused the connection.
    func test_unreachable_forCannotConnectToHost() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(urlError(NSURLErrorCannotConnectToHost)),
                       .unreachable)
    }

    func test_unreachable_forCannotFindHost() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(urlError(NSURLErrorCannotFindHost)),
                       .unreachable)
    }

    func test_unreachable_forTimeout() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(urlError(NSURLErrorTimedOut)), .unreachable)
    }

    func test_unreachable_whenWrappedByAVFoundation() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(wrapped(urlError(NSURLErrorCannotConnectToHost))),
                       .unreachable)
    }

    // MARK: - Other

    func test_other_forDecoderFailure() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(coreMediaError(-12909)), .other)
    }

    /// A 404 is not a block — it keeps its retry, because a live stream 404s while the encoder
    /// reconnects.
    func test_other_forNotFound() {
        XCTAssertEqual(PlaybackFailureClassifier.classify(coreMediaError(-12938)), .other)
    }

    /// The walk down the cause chain is depth-limited, so a pathologically deep one terminates.
    func test_other_forChainDeeperThanTheWalkLimit() {
        var error = NSError(domain: "Test", code: 0)
        for depth in 1...50 {
            error = NSError(domain: "Test", code: depth,
                            userInfo: [NSUnderlyingErrorKey: error])
        }
        XCTAssertEqual(PlaybackFailureClassifier.classify(error), .other)
    }

    /// The depth limit is a real trade-off, recorded here rather than left as a surprise: a
    /// connectivity cause buried deeper than the walk goes is missed and falls back to the bare
    /// retry. Harmless in practice — AVFoundation nests a couple of levels, nowhere near ten.
    func test_noConnectionCauseBuriedBeyondTheWalkLimitIsNotFound() {
        var error = urlError(NSURLErrorNotConnectedToInternet)
        for depth in 1...12 {
            error = NSError(domain: "Test", code: depth,
                            userInfo: [NSUnderlyingErrorKey: error])
        }
        XCTAssertEqual(PlaybackFailureClassifier.classify(error), .other)
    }

    /// A 403 is not subject to that limit — the forbidden check walks the whole chain — so the
    /// terminal verdict is never missed, whichever way AVFoundation nests it.
    func test_blockedIsFoundAtAnyDepth() {
        var error = coreMediaError(-12660)
        for depth in 1...12 {
            error = NSError(domain: "Test", code: depth,
                            userInfo: [NSUnderlyingErrorKey: error])
        }
        XCTAssertEqual(PlaybackFailureClassifier.classify(error), .blocked)
    }

    // MARK: - Mapping a resolution to what the viewer sees

    func test_sinkholeBecomesNotAvailable() {
        XCTAssertEqual(PlaybackFailureClassifier.error(for: .sinkhole), .notAvailable)
    }

    func test_unresolvableBecomesNoInternet() {
        XCTAssertEqual(PlaybackFailureClassifier.error(for: .unresolvable), .noInternetConnection)
    }

    /// The host answered normally, so the existing failure is left exactly as it was.
    func test_routableLeavesTheFailureAlone() {
        XCTAssertNil(PlaybackFailureClassifier.error(for: .routable))
    }
}
