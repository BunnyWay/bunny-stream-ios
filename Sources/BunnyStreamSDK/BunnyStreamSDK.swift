import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// `BunnyStreamSDK` provides the main entry point for interacting with the Bunny Stream API.
public class BunnyStreamSDK {
  /// The access key used for authentication with the Bunny Stream API.
  let accessKey: String
  
  /// The transport layer used for network communication.
  let transport: ClientTransport
  
  /// The API client for interacting with the Bunny Stream services.
  public let Api: Client
  
  /// Initializes a new instance of the BunnyStreamSDK.
  ///
  /// - Parameters:
  ///   - accessKey: A string representing the access key required for API authentication.
  ///   - transport: An optional parameter for a custom transport layer.
  ///                If not provided, `URLSessionTransport` is used by default.
  public init(accessKey: String, transport: ClientTransport = URLSessionTransport()) {
    self.accessKey = accessKey
    self.transport = transport
    
    self.Api = Client(
      serverURL: try! Servers.Server1.url(),
      configuration: Configuration(dateTranscoder: CustomISO8601DateTranscoder()),
      transport: transport,
      middlewares: [AuthenticationMiddleware(accessKey: accessKey)]
    )
  }
}
