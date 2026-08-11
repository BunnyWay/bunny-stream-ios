import Foundation

/// The single error type every ``LiveStreamRepository`` method throws.
///
/// It keeps the HTTP status code, which callers need in order to tell a permanent failure
/// (stop retrying) from a transient one (keep polling) — see ``isPermanent``.
public struct BunnyLiveStreamError: Error, Equatable, Sendable {
  public enum Kind: Equatable, Sendable {
    /// The access key was missing, wrong, or lacks permission (401/403).
    case unauthorized
    /// The library or live stream doesn't exist, or is gone (404/410).
    case notFound
    /// The server rejected the request as invalid (400).
    case invalidRequest
    /// The server understood the request but couldn't act on it (422).
    case unprocessable
    /// The server failed (5xx).
    case server
    /// The request never produced an HTTP response — no connectivity, cancelled, TLS failure.
    case transport
    /// A response arrived but didn't match the schema.
    case invalidResponse
    /// Any other status code.
    case unexpected
  }

  public let kind: Kind
  /// The HTTP status code, when the failure came from a response.
  public let statusCode: Int?
  /// A server-supplied message, when one was available.
  public let message: String?

  public init(kind: Kind, statusCode: Int? = nil, message: String? = nil) {
    self.kind = kind
    self.statusCode = statusCode
    self.message = message
  }

  /// Whether retrying is pointless.
  ///
  /// Mirrors the web player's polling rules: 401/403/404/410 and malformed requests are
  /// permanent, while 5xx and transport failures are worth another attempt.
  public var isPermanent: Bool {
    switch kind {
    case .unauthorized, .notFound, .invalidRequest, .unprocessable:
      return true
    case .server, .transport, .invalidResponse, .unexpected:
      return false
    }
  }

  /// Builds the error for an HTTP status code the operation didn't document.
  static func forStatusCode(_ code: Int, message: String? = nil) -> BunnyLiveStreamError {
    let kind: Kind
    switch code {
    case 400: kind = .invalidRequest
    case 401, 403: kind = .unauthorized
    case 404, 410: kind = .notFound
    case 422: kind = .unprocessable
    case 500...599: kind = .server
    default: kind = .unexpected
    }
    return BunnyLiveStreamError(kind: kind, statusCode: code, message: message)
  }
}

extension BunnyLiveStreamError: LocalizedError {
  public var errorDescription: String? {
    if let message, !message.isEmpty {
      return message
    }
    let base: String
    switch kind {
    case .unauthorized: base = "The request authorization failed."
    case .notFound: base = "The requested live stream was not found."
    case .invalidRequest: base = "The request was invalid."
    case .unprocessable: base = "The server could not process the request."
    case .server: base = "The server failed to handle the request."
    case .transport: base = "The request could not be sent."
    case .invalidResponse: base = "The response could not be read."
    case .unexpected: base = "The request failed."
    }
    guard let statusCode else { return base }
    return "\(base) (HTTP \(statusCode))"
  }
}
