import Foundation

enum VideoPlayerError: Error {
  case unauthorized
  case notFound
  /// HTTP 403 from the API or CDN (geo-blocking, referrer protection, token auth), or a CDN host
  /// that DNS answered with a loopback sinkhole — Bunny's "Blocked countries" setting.
  /// Deliberately not split by cause — viewers only ever see a generic "not available".
  case notAvailable
  /// The device could not reach the CDN at all. Says nothing about the video, so unlike
  /// ``notAvailable`` this stays retryable.
  case noInternetConnection
  case internalServerError
  case unknownError
  case audioError
  case drmNotSupported
}
