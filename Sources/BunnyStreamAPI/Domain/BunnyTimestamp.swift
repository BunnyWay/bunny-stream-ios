import Foundation

extension Date {
  /// Parses a timestamp string as returned by the Bunny API.
  ///
  /// Several live stream fields are declared as plain strings in the spec rather than
  /// `date-time`, so the generated client hands them over unparsed. Bunny varies the precision
  /// between responses — with or without a `Z`, and with 0, 3 or 7 fractional digits — so every
  /// shape is attempted. Timestamps without a zone marker are read as UTC, which is what the
  /// API documents.
  init?(bunnyTimestamp: String) {
    for formatter in Date.bunnyTimestampFormatters {
      if let date = formatter.date(from: bunnyTimestamp) {
        self = date
        return
      }
    }
    return nil
  }

  private static let bunnyTimestampFormatters: [DateFormatter] = {
    [
      "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'",
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
      "yyyy-MM-dd'T'HH:mm:ss.SSS",
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
      "yyyy-MM-dd'T'HH:mm:ss",
    ].map { format in
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(abbreviation: "UTC")
      formatter.dateFormat = format
      return formatter
    }
  }()
}
