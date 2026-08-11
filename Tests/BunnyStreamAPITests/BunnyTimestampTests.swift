import XCTest

@testable import BunnyStreamAPI

/// Bunny varies the precision of the timestamps it returns between responses, so every shape
/// has to parse. Moved here from the player tests when date handling became the domain layer's job.
final class BunnyTimestampTests: XCTestCase {

  func testParsesISO8601WithMicroseconds() {
    XCTAssertNotNil(Date(bunnyTimestamp: "2026-06-04T18:42:24.671615Z"))
  }

  func testParsesISO8601WithMilliseconds() {
    XCTAssertNotNil(Date(bunnyTimestamp: "2026-06-04T18:42:24.671Z"))
  }

  func testParsesISO8601WithoutMilliseconds() {
    XCTAssertNotNil(Date(bunnyTimestamp: "2026-06-04T18:42:24"))
  }

  func testParsesISO8601WithZSuffix() {
    XCTAssertNotNil(Date(bunnyTimestamp: "2026-06-04T18:42:24Z"))
  }

  func testReturnsNilForInvalidString() {
    XCTAssertNil(Date(bunnyTimestamp: "not-a-date"))
  }

  func testReturnsNilForEmptyString() {
    XCTAssertNil(Date(bunnyTimestamp: ""))
  }

  /// A timestamp with no zone marker is documented as UTC; reading it as local time would
  /// shift scheduled starts and countdowns by the device's offset.
  func testNaiveTimestampIsReadAsUTC() throws {
    let naive = try XCTUnwrap(Date(bunnyTimestamp: "2026-06-04T18:42:24"))
    let explicit = try XCTUnwrap(Date(bunnyTimestamp: "2026-06-04T18:42:24Z"))

    XCTAssertEqual(naive, explicit)
  }

  func testParsedDateHasExpectedComponents() throws {
    let date = try XCTUnwrap(Date(bunnyTimestamp: "2026-06-04T18:42:24Z"))

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "UTC"))
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

    XCTAssertEqual(components.year, 2026)
    XCTAssertEqual(components.month, 6)
    XCTAssertEqual(components.day, 4)
    XCTAssertEqual(components.hour, 18)
    XCTAssertEqual(components.minute, 42)
  }
}
