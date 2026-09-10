import Foundation

enum VideoPlayerError: Error {
  case unauthorized
  case notFound
  /// HTTP 403 from the API or CDN (geo-blocking, referrer protection, token auth).
  /// Deliberately not split by cause — viewers only ever see a generic "not available".
  case notAvailable
  case internalServerError
  case unknownError
  case audioError
  case drmNotSupported
}
