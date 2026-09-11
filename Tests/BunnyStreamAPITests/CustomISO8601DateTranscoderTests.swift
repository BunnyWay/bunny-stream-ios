import XCTest
@testable import BunnyStreamAPI

class CustomISO8601DateTranscoderTests: XCTestCase {
  var dateTranscoder: CustomISO8601DateTranscoder!
  
  override func setUp() {
    super.setUp()
    dateTranscoder = CustomISO8601DateTranscoder()
  }
  
  override func tearDown() {
    dateTranscoder = nil
    super.tearDown()
  }
  
  func testEncodingDate() {
    // Given — encoding emits an explicit UTC marker so the server can't read the
    // timestamp as local time.
    let testDate = Date(timeIntervalSince1970: 1_580_828_001)
    let expectedString = "2020-02-04T14:53:21.000Z"

    // When
    let encodedString = try? dateTranscoder.encode(testDate)

    // Then
    XCTAssertEqual(encodedString, expectedString)
  }

  func testDecodingDate() {
    // Given
    let dateString = "2020-02-04T14:53:21.000"
    let expectedDate = Date(timeIntervalSince1970: 1_580_828_001)

    // When
    let decodedDate = try? dateTranscoder.decode(dateString)

    // Then
    XCTAssertEqual(decodedDate, expectedDate)
  }

  func testEncodedDateRoundTrips() throws {
    // Given
    let testDate = Date(timeIntervalSince1970: 1_580_828_001)

    // When
    let decodedDate = try dateTranscoder.decode(dateTranscoder.encode(testDate))

    // Then
    XCTAssertEqual(decodedDate, testDate)
  }

  func testDecodingDateWithoutFractionalSeconds() throws {
    // Bunny returns scheduled times in this shape, e.g. "2026-07-01T08:20:00".
    // Given
    let dateString = "2020-02-04T14:53:21"
    let expectedDate = Date(timeIntervalSince1970: 1_580_828_001)

    // When
    let decodedDate = try dateTranscoder.decode(dateString)

    // Then
    XCTAssertEqual(decodedDate, expectedDate)
  }

  func testDecodingInvalidDateString() {
    // Given
    let invalidDateString = "2020-02-20 10:00:01"
    
    // When
    var decodingError: Error?
    do {
      _ = try dateTranscoder.decode(invalidDateString)
    } catch let error {
      decodingError = error
    }
    
    // Then
    XCTAssertNotNil(decodingError)
    if let decodingError = decodingError as? DecodingError {
      switch decodingError {
      case .dataCorrupted(let context):
        XCTAssertEqual(context.debugDescription,
                       "Expected date string to be in one of the formats: yyyy-MM-dd'T'HH:mm:ss.SSS'Z', yyyy-MM-dd'T'HH:mm:ss.SSS, yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z' or yyyy-MM-dd'T'HH:mm:ss")
      default:
        XCTFail("Unexpected decoding error type.")
      }
    } else {
      XCTFail("Error is not of type DecodingError.")
    }
  }
}

