import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// A client SDK for interacting with the Bunny Stream API.
///
/// The `BunnyStreamAPI` class provides a convenient interface for accessing Bunny Stream's
/// content delivery and streaming services. It handles authentication, request management,
/// and provides access to all available API endpoints.
///
/// Example usage:
/// ```swift
/// let api = BunnyStreamAPI(accessKey: "your-access-key")
/// // Use the api.client to make API calls
/// ```
///
/// - Important: Make sure to keep your access key secure and never expose it in client-side code.
public class BunnyStreamAPI {
  /// The authentication key used for accessing the Bunny Stream API.
  ///
  /// This key is required for all API operations and should be obtained from your
  /// Bunny Stream dashboard.
  private let accessKey: String

  /// The transport layer responsible for handling network communications.
  ///
  /// This property manages the underlying network stack used for API requests.
  /// By default, it uses `URLSessionTransport`, but can be customized for specific needs.
  private let transport: ClientTransport

  /// The main API client interface for accessing Bunny Stream services.
  ///
  /// This is the generated client, so its types change whenever the OpenAPI document is
  /// regenerated. For live streams prefer ``liveStreams``, which speaks in domain types.
  public let client: Client

  /// Live stream operations, expressed in domain types rather than generated ones.
  ///
  /// ```swift
  /// let stream = try await BunnyStreamAPI(accessKey: key)
  ///   .liveStreams
  ///   .getLiveStream(libraryId: 123, streamId: "stream-guid")
  /// ```
  public var liveStreams: DefaultLiveStreamRepository {
    DefaultLiveStreamRepository(client: client)
  }

  /// Creates a new instance of the Bunny Stream SDK.
  ///
  /// - Parameters:
  ///   - accessKey: The API access key for authentication. This can be found in your Bunny Stream dashboard.
  ///   - transport: An optional custom transport layer for network communications. Defaults to `URLSessionTransport`.
  ///
  /// - Note: The SDK automatically configures date handling and authentication middleware.
  public init(accessKey: String, transport: ClientTransport = URLSessionTransport()) {
    self.accessKey = accessKey
    self.transport = transport

    self.client = Client(
      serverURL: try! Servers.Server1.url(),
      configuration: Configuration(dateTranscoder: CustomISO8601DateTranscoder()),
      transport: transport,
      middlewares: [AuthenticationMiddleware(accessKey: accessKey)]
    )
  }
}
