import OpenAPIRuntime
import OpenAPIURLSession
import Foundation
import HTTPTypes

/// A middleware component that handles authentication for Bunny Stream API requests.
///
/// This middleware automatically injects the required AccessKey header into all outgoing
/// API requests. It implements the `ClientMiddleware` protocol to intercept and modify
/// requests before they are sent to the server.
///
/// - Note: This middleware is automatically configured when you initialize the `BunnyStreamAPI`.
struct AuthenticationMiddleware: ClientMiddleware {
  /// The API access key used for request authentication.
  let accessKey: String

  /// Intercepts and modifies outgoing HTTP requests to include authentication headers.
  ///
  /// - Parameters:
  ///   - request: The original HTTP request to be modified.
  ///   - body: The body of the HTTP request, if any.
  ///   - baseURL: The base URL for the API request.
  ///   - operationID: The identifier for the API operation being performed.
  ///   - next: A closure that continues the middleware chain with the modified request.
  ///
  /// - Returns: A tuple containing the HTTP response and its body.
  /// - Throws: Any errors that occur during request processing or from subsequent middleware.
  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var request = request
    if let key = HTTPField.Name.accessKey {
      request.headerFields[key] = accessKey
    }
    if let key = HTTPField.Name(SDKInfo.userAgentHeaderField) {
      request.headerFields[key] = SDKInfo.userAgent
    }

    return try await next(request, body, baseURL)
  }
}

/// Extension providing custom HTTP header field names.
extension HTTPField.Name {
  /// The header field name for the Bunny Stream API access key.
  ///
  /// This header is automatically added to requests by the `AuthenticationMiddleware`.
  static var accessKey: Self? { HTTPField.Name("AccessKey") }
}
