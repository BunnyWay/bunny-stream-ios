import XCTest
@testable import BunnyStreamPlayer

/// The FairPlay content ID is the base64 payload of the `skd://` key URI. It used to be read from
/// `url.host`, which stops at the first `/` — a character standard base64 produces for roughly a
/// quarter of all key IDs — so those videos requested a key for a truncated ID and froze at 0:00.
final class FairPlayStreamHandlerContentIdentifierTests: XCTestCase {

    private func contentIdentifier(_ uri: String) -> Data? {
        FairPlayStreamHandler.contentIdentifier(fromKeyURL: URL(string: uri)!)
    }

    func test_decodesPlainBase64() {
        let id = Data("abcdefghijklmnop".utf8)
        XCTAssertEqual(contentIdentifier("skd://\(id.base64EncodedString())"), id)
    }

    func test_keepsSlashInsteadOfTruncatingAtIt() {
        // Base64 of these bytes contains `/`; `url.host` would stop right before it.
        let id = Data([0x61, 0x62, 0x63, 0xFF, 0x65, 0x66, 0x67, 0x68, 0x69])
        let encoded = id.base64EncodedString()
        XCTAssertTrue(encoded.contains("/"))
        XCTAssertEqual(contentIdentifier("skd://\(encoded)"), id)
    }

    func test_decodesPlus() {
        let id = Data([0x61, 0x62, 0x63, 0xFB, 0xE5, 0x66, 0x67, 0x68, 0x69])
        let encoded = id.base64EncodedString()
        XCTAssertTrue(encoded.contains("+"))
        XCTAssertEqual(contentIdentifier("skd://\(encoded)"), id)
    }

    func test_decodesWithoutPadding() {
        let id = Data("abcdefghijklmnop".utf8)
        let unpadded = id.base64EncodedString().replacingOccurrences(of: "=", with: "")
        XCTAssertEqual(contentIdentifier("skd://\(unpadded)"), id)
    }

    func test_decodesURLSafeAlphabet() {
        let id = Data([0x61, 0x62, 0x63, 0xFF, 0x65, 0xFB, 0xE5, 0x68, 0x69])
        let urlSafe = id.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        XCTAssertEqual(contentIdentifier("skd://\(urlSafe)"), id)
    }

    func test_ignoresQuery() {
        let id = Data("abcdefghijklmnop".utf8)
        XCTAssertEqual(contentIdentifier("skd://\(id.base64EncodedString())?v=1"), id)
    }

    func test_rejectsNonSkdAndEmptyURIs() {
        XCTAssertNil(contentIdentifier("https://example.com/key"))
        XCTAssertNil(contentIdentifier("skd://"))
    }
}
