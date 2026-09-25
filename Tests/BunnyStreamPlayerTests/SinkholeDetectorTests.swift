import XCTest
@testable import BunnyStreamPlayer

/// Bunny's "Blocked countries" geo-block is enforced in DNS: the CDN host resolves to a loopback
/// sinkhole, so the connection is refused and no HTTP 403 is ever returned. Recognising the
/// sinkhole address is the whole discriminator between a blocked stream and an ordinary outage,
/// so it is tested exhaustively — and without touching DNS.
final class SinkholeDetectorTests: XCTestCase {

    // MARK: - IPv4

    func test_sinkhole_forLoopbackIPv4() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("127.0.0.1"))
    }

    /// The whole 127.0.0.0/8 block is loopback, and sinkholes do not all pick .0.1.
    func test_sinkhole_forAnyLoopbackIPv4InTheBlock() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("127.0.0.53"))
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("127.1.2.3"))
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("127.255.255.255"))
    }

    func test_sinkhole_forUnspecifiedIPv4() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("0.0.0.0"))
    }

    func test_notSinkhole_forRoutableIPv4() {
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("93.184.216.34"))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("8.8.8.8"))
    }

    /// A private address is not a sinkhole — a corporate CDN mirror is a legitimate answer.
    func test_notSinkhole_forPrivateIPv4() {
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("192.168.1.1"))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("10.0.0.1"))
    }

    /// 128.x is one bit away from the loopback block and must not be caught by a prefix test.
    func test_notSinkhole_forAddressAdjacentToLoopbackBlock() {
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("128.0.0.1"))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("126.255.255.255"))
    }

    /// "127" appearing anywhere other than the first octet means nothing.
    func test_notSinkhole_forLoopbackDigitsInLaterOctets() {
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("10.127.0.1"))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("1.2.3.127"))
    }

    // MARK: - IPv6

    func test_sinkhole_forIPv6Loopback() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("::1"))
    }

    func test_sinkhole_forIPv6Unspecified() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("::"))
    }

    /// The same addresses written out in full — parsing must not depend on the spelling.
    func test_sinkhole_forExpandedIPv6Forms() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("0:0:0:0:0:0:0:1"))
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("0000:0000:0000:0000:0000:0000:0000:0001"))
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("0:0:0:0:0:0:0:0"))
    }

    /// A sinkholed IPv4 address can arrive inside an IPv6 record.
    func test_sinkhole_forIPv4MappedLoopback() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("::ffff:127.0.0.1"))
    }

    func test_notSinkhole_forIPv4MappedRoutableAddress() {
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("::ffff:93.184.216.34"))
    }

    func test_notSinkhole_forRoutableIPv6() {
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("2606:2800:220:1:248:1893:25c8:1946"))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("fe80::1"))
    }

    // MARK: - Formatting

    /// getnameinfo can hand back a link-local address carrying a zone index.
    func test_sinkhole_ignoresIPv6ZoneIndex() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("::1%lo0"))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("fe80::1%en0"))
    }

    func test_sinkhole_ignoresSurroundingBrackets() {
        XCTAssertTrue(SinkholeDetector.isSinkholeAddress("[::1]"))
    }

    func test_notSinkhole_forGarbage() {
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress(""))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("not-an-address"))
        XCTAssertFalse(SinkholeDetector.isSinkholeAddress("127.0.0"))
    }

    // MARK: - Resolution

    /// `localhost` is the one host guaranteed to resolve to loopback without a network.
    func test_resolve_reportsSinkholeForLocalhost() {
        XCTAssertEqual(SinkholeDetector.resolve(host: "localhost"), .sinkhole)
    }

    /// A name that cannot resolve is what a device with no connection looks like — and, crucially,
    /// not what a geo-block looks like: a block answers, it just answers with a sinkhole.
    func test_resolve_reportsUnresolvableForInvalidHost() {
        let host = "bunny-stream-ios-tests-\(UUID().uuidString).invalid"
        XCTAssertEqual(SinkholeDetector.resolve(host: host), .unresolvable)
    }
}
