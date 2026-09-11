import Foundation

/// How the SDK transmits CMCD (Common Media Client Data) telemetry on media requests.
public enum CMCDTransmissionMode {
  /// Send CMCD as `CMCD-*` HTTP request headers. Default. Keeps CDN cache keys clean.
  case header
  /// Send CMCD as a single percent-encoded `CMCD` query parameter.
  /// - Warning: Query data becomes part of the CDN cache key and can reduce cache hit ratio.
  case query
  /// Send CMCD both as HTTP headers and as a `CMCD` query parameter.
  /// - Warning: Inherits the cache-key caveat of ``query``.
  case both

  var sendsHeaders: Bool { self == .header || self == .both }
  var sendsQuery: Bool { self == .query || self == .both }
}

/// Process-wide CMCD configuration. Set this once (e.g. at app launch) before playback starts.
///
/// ```swift
/// CMCDConfiguration.transmissionMode = .both
/// ```
public enum CMCDConfiguration {
  /// The transmission mode used for CMCD on streaming requests. Defaults to ``CMCDTransmissionMode/header``.
  ///
  /// - Note: Applies to the live / non-DRM streaming path that goes through the SDK's resource
  ///   loader. FairPlay-protected VOD always sends the static `CMCD-Session` header only.
  public static var transmissionMode: CMCDTransmissionMode = .header
}
