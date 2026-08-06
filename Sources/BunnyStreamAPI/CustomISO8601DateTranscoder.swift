import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// A custom date transcoder that handles ISO 8601 formatted dates for the Bunny Stream API.
///
/// This transcoder supports these ISO 8601 date formats:
/// - UTC format: `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'`
/// - Naive format: `yyyy-MM-dd'T'HH:mm:ss.SSS`
/// - Extended format: `yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'`
/// - Second-precision format: `yyyy-MM-dd'T'HH:mm:ss`
///
/// The transcoder attempts to parse dates using every format and uses UTC timezone
/// with the en_US_POSIX locale for consistency. Encoding always emits the UTC format,
/// so the wire value carries an explicit timezone rather than relying on the server
/// to assume UTC for a naive timestamp.
struct CustomISO8601DateTranscoder: DateTranscoder {
  /// Array of date formatters configured for different ISO 8601 formats.
  /// The first entry is also the one used for encoding.
  private let formatters: [DateFormatter] = {
    let commonAttributes: (DateFormatter) -> Void = { formatter in
      formatter.timeZone = TimeZone(abbreviation: "UTC")
      formatter.locale = Locale(identifier: "en_US_POSIX")
    }

    let utcFormatter = DateFormatter()
    utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    commonAttributes(utcFormatter)

    let standardFormatter = DateFormatter()
    standardFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    commonAttributes(standardFormatter)

    let extendedFormatter = DateFormatter()
    extendedFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
    commonAttributes(extendedFormatter)

    // Bunny returns scheduled times without fractional seconds, e.g. "2026-07-01T08:20:00".
    let secondsFormatter = DateFormatter()
    secondsFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    commonAttributes(secondsFormatter)

    return [utcFormatter, standardFormatter, extendedFormatter, secondsFormatter]
  }()

  /// Converts a Date object to an ISO 8601 formatted string.
  ///
  /// This method uses the UTC format (`yyyy-MM-dd'T'HH:mm:ss.SSS'Z'`) for encoding dates.
  ///
  /// - Parameter date: The Date object to encode.
  /// - Returns: A string representation of the date in ISO 8601 format.
  /// - Throws: An error if the date cannot be encoded.
  func encode(_ date: Date) throws -> String {
    formatters.first!.string(from: date)
  }

  /// Converts an ISO 8601 formatted string to a Date object.
  ///
  /// This method attempts to parse the date string using every supported format.
  /// It tries each formatter in sequence until one succeeds.
  ///
  /// - Parameter dateString: The ISO 8601 formatted date string to decode.
  /// - Returns: A Date object representing the parsed date.
  /// - Throws: A `DecodingError` if the date string doesn't match either of the supported formats.
  func decode(_ dateString: String) throws -> Date {
    for formatter in formatters {
      if let date = formatter.date(from: dateString) {
        return date
      }
    }

    throw DecodingError.dataCorrupted(
      .init(
        codingPath: [],
        debugDescription: "Expected date string to be in one of the formats: yyyy-MM-dd'T'HH:mm:ss.SSS'Z', yyyy-MM-dd'T'HH:mm:ss.SSS, yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z' or yyyy-MM-dd'T'HH:mm:ss"
      )
    )
  }
}
