import XCTest
import BunnyStreamAPI
@testable import BunnyStreamPlayer

/// The license POST carries the raw SPC. It must declare a binary content type: URLSession's
/// default for a body without one is `application/x-www-form-urlencoded`, which makes the license
/// server parse the SPC as form fields and fail with HTTP 500 before issuing anything.
final class FairPlayStreamHandlerLicenseRequestTests: XCTestCase {

    private let spc = Data([0x00, 0x01, 0x5B, 0xFF, 0x3D, 0x26])

    private func makeRequest(token: String? = nil, expires: Int64? = nil) -> URLRequest {
        FairPlayStreamHandler(videoId: "7bf837ec-ee04-4475-9099-3845ba944a6c", libraryId: 578375,
                              token: token, expires: expires)
            .makeLicenseRequest(spcData: spc)
    }

    func test_licenseRequest_declaresBinaryContentType() {
        XCTAssertEqual(makeRequest().value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
    }

    func test_licenseRequest_postsRawSPC() {
        let request = makeRequest()
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.httpBody, spc)
    }

    func test_licenseRequest_targetsLicenseEndpointWithVideoId() {
        let url = makeRequest().url
        XCTAssertEqual(url?.host, URL(string: Constants.fairPlayBaseUrlString)?.host)
        XCTAssertEqual(url?.path, "/FairPlay/578375/license")
        XCTAssertEqual(url?.query, "videoId=7bf837ec-ee04-4475-9099-3845ba944a6c")
    }

    func test_licenseRequest_carriesEmbedTokenAndExpiryWhenProvided() {
        let query = makeRequest(token: "abc", expires: 1788870184).url?.query
        XCTAssertEqual(query, "videoId=7bf837ec-ee04-4475-9099-3845ba944a6c&token=abc&expires=1788870184")
    }

    func test_licenseRequest_carriesTokenWithoutExpiry() {
        let query = makeRequest(token: "abc").url?.query
        XCTAssertEqual(query, "videoId=7bf837ec-ee04-4475-9099-3845ba944a6c&token=abc")
    }

    func test_licenseRequest_sendsEmbedRefererAndSDKUserAgent() {
        let request = makeRequest()
        XCTAssertEqual(request.value(forHTTPHeaderField: "Referer"), "https://iframe.mediadelivery.net/")
        XCTAssertEqual(request.value(forHTTPHeaderField: SDKInfo.userAgentHeaderField), SDKInfo.userAgent)
    }
}
