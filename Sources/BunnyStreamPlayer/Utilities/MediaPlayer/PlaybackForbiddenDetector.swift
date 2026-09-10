import AVFoundation

/// Recognises an HTTP 403 behind a failed `AVPlayerItem`.
///
/// AVFoundation fetches manifests and segments itself and never exposes the HTTP response (headers
/// included), so the status can only be read back from the traces it leaves: the item's error
/// chain, where CoreMedia reports a 403 as `CoreMediaErrorDomain` `-12660`, and its error log.
/// Geo-blocking, referrer protection and token auth all answer with the same 403 and all map to
/// one generic "not available".
enum PlaybackForbiddenDetector {
  static let coreMediaErrorDomain = "CoreMediaErrorDomain"
  /// CoreMedia's error code for an HTTP 403 response.
  static let coreMediaForbiddenCode = -12660

  /// Whether `error`, or any error it wraps, is CoreMedia's HTTP 403.
  static func isForbidden(_ error: Error) -> Bool {
    var current: NSError? = error as NSError
    while let nsError = current {
      if nsError.domain == coreMediaErrorDomain, nsError.code == coreMediaForbiddenCode {
        return true
      }
      current = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
    }
    return false
  }

  /// Whether an error-log entry records an HTTP 403.
  static func isForbidden(_ event: AVPlayerItemErrorLogEvent) -> Bool {
    isForbidden(statusCode: event.errorStatusCode, domain: event.errorDomain, comment: event.errorComment)
  }

  /// The error-log check on plain values — `AVPlayerItemErrorLogEvent` can't be constructed in tests.
  static func isForbidden(statusCode: Int, domain: String, comment: String?) -> Bool {
    statusCode == 403
      || (domain == coreMediaErrorDomain && statusCode == coreMediaForbiddenCode)
      || comment?.contains("HTTP 403") == true
  }
}
