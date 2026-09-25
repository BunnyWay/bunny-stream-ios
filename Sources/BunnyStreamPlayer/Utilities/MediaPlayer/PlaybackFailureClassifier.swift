import AVFoundation
import Foundation

/// Sorts a playback failure into the three things a viewer can usefully be told apart.
///
/// The player used to recognise only an HTTP 403 and show a bare retry button for everything
/// else, which put a geo-blocked stream and a lost connection behind the same silent icon.
/// This mirrors the Android SDK's `PlaybackFailureInfo`: a block is terminal and says "Video is
/// not available", a connectivity failure says "No internet connection" and stays retryable,
/// and anything else keeps the plain retry.
enum PlaybackFailureClassifier {
  enum Kind: Equatable {
    /// The CDN refused playback (HTTP 403 — geo-blocking, referrer protection, token auth).
    /// Terminal: retrying cannot help.
    case blocked
    /// The device has no usable connection. Nothing here says anything about the video, so this
    /// stays retryable.
    case noConnection
    /// The host could not be reached. On its own this is ambiguous — Bunny's country block
    /// sinkholes the CDN host in DNS, and a refused connection is the only trace it leaves —
    /// so it is resolved with ``SinkholeDetector`` before the viewer is told anything.
    case unreachable
    /// Anything else: decoder, parser, DRM, malformed media.
    case other
  }

  /// Classifies `error`, following the chain of underlying errors.
  ///
  /// A 403 wins over everything, because a DNS-level block can surface as a connection failure
  /// too and there the video really is unavailable.
  static func classify(_ error: Error) -> Kind {
    if PlaybackForbiddenDetector.isForbidden(error) { return .blocked }

    var current: NSError? = error as NSError
    var depth = 0
    while let nsError = current, depth < maxCauseDepth {
      if isURLLikeDomain(nsError.domain) {
        if noConnectionCodes.contains(nsError.code) { return .noConnection }
        if unreachableCodes.contains(nsError.code) { return .unreachable }
      }
      current = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
      depth += 1
    }
    return .other
  }

  /// Turns a resolved host into the error the viewer is shown, or `nil` to leave the existing
  /// failure alone — the host answered normally, so the connection failure was not about DNS.
  static func error(for outcome: SinkholeDetector.Outcome) -> VideoPlayerError? {
    switch outcome {
    case .sinkhole:     return .notAvailable
    case .unresolvable: return .noInternetConnection
    case .routable:     return nil
    }
  }

  /// CoreMedia reports URL-level failures under its own domain while reusing `NSURLError`
  /// numbering, so both domains are read the same way.
  private static func isURLLikeDomain(_ domain: String) -> Bool {
    domain == NSURLErrorDomain || domain == PlaybackForbiddenDetector.coreMediaErrorDomain
  }

  /// Failures that mean the device itself is not on the network.
  private static let noConnectionCodes: Set<Int> = [
    NSURLErrorNotConnectedToInternet,
    NSURLErrorNetworkConnectionLost,
    NSURLErrorDataNotAllowed,
    NSURLErrorInternationalRoamingOff,
  ]

  /// Failures where a host was addressed but never answered — the shape a sinkholed host takes.
  private static let unreachableCodes: Set<Int> = [
    NSURLErrorCannotConnectToHost,
    NSURLErrorCannotFindHost,
    NSURLErrorDNSLookupFailed,
    NSURLErrorTimedOut,
  ]

  private static let maxCauseDepth = 10
}
