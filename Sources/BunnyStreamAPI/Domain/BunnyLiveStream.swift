import Foundation

/// A live stream, expressed in the SDK's own vocabulary rather than the generated OpenAPI types.
///
/// Public SDK entry points take this type so that regenerating the API client can't change
/// their signatures. Build one from an API response with ``init(from:)``.
public struct BunnyLiveStream: Equatable, Sendable {
  /// The GUID of the live stream.
  public let id: String?
  /// The title of the live stream.
  public let title: String?
  /// The key an encoder authenticates the RTMP publish with.
  public let streamKey: String?
  /// The primary RTMP ingest URL to publish to.
  public let primaryIngestUrl: String?
  /// The backup RTMP ingest URL, used when the primary endpoint stops accepting the publish.
  public let backupIngestUrl: String?

  public init(
    id: String?,
    title: String? = nil,
    streamKey: String? = nil,
    primaryIngestUrl: String? = nil,
    backupIngestUrl: String? = nil
  ) {
    self.id = id
    self.title = title
    self.streamKey = streamKey
    self.primaryIngestUrl = primaryIngestUrl
    self.backupIngestUrl = backupIngestUrl
  }

  /// Bridges a live stream returned by the generated API client into the domain model.
  ///
  /// - Note: This is transitional. Once the SDK exposes a live stream repository that returns
  ///   domain models directly, callers won't need to touch the generated types at all.
  public init(from model: Components.Schemas.LiveStreamModel) {
    self.init(
      id: model.guid,
      title: model.title,
      streamKey: model.streamKey,
      primaryIngestUrl: model.ingestEndpoints?.rtmp?.primaryIngestUrl,
      backupIngestUrl: model.ingestEndpoints?.rtmp?.backupIngestUrl
    )
  }
}
