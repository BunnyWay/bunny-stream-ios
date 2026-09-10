import XCTest
@testable import BunnyStreamPlayer

/// A rejected live manifest/segment request must fail the loading request with its HTTP status —
/// never pass the server's error page to AVPlayer as media.
final class CMCDResourceLoaderHTTPFailureTests: XCTestCase {

    private func response(_ statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.b-cdn.net/live/playlist.m3u8")!,
                        statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    func test_httpFailure_nilForSuccess() {
        XCTAssertNil(CMCDResourceLoader.httpFailure(for: response(200)))
    }

    // Byte-range responses are successes too.
    func test_httpFailure_nilForPartialContent() {
        XCTAssertNil(CMCDResourceLoader.httpFailure(for: response(206)))
    }

    func test_httpFailure_carriesForbiddenStatus() {
        let failure = CMCDResourceLoader.httpFailure(for: response(403))
        XCTAssertEqual(failure?.domain, CMCDResourceLoader.httpErrorDomain)
        XCTAssertEqual(failure?.code, 403)
    }

    func test_httpFailure_carriesNotFoundStatus() {
        XCTAssertEqual(CMCDResourceLoader.httpFailure(for: response(404))?.code, 404)
    }
}
