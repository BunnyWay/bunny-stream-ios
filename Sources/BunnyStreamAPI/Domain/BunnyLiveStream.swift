import Foundation

/// The lifecycle state of a live stream.
///
/// The generated client models this as an integer enum whose cases are named `_0`…`_7`;
/// this is the readable equivalent. Unrecognised values decode to ``unknown`` rather than
/// failing, so a new server-side state can't break an existing app.
public enum BunnyLiveStreamStatus: Int, Equatable, Sendable, CaseIterable {
  case unknown = 0
  case created = 1
  case scheduled = 2
  /// An encoder is connected and pushing, but the stream hasn't been taken live yet.
  case preview = 3
  case running = 4
  case ended = 5
  case vodProcessing = 6
  case error = 7

  public init(rawValue: Int) {
    switch rawValue {
    case 1: self = .created
    case 2: self = .scheduled
    case 3: self = .preview
    case 4: self = .running
    case 5: self = .ended
    case 6: self = .vodProcessing
    case 7: self = .error
    default: self = .unknown
    }
  }
}

/// Readable names for the generated integer enum, whose cases are `_0`…`_7`.
///
/// - Note: Transitional. Code holding a generated response can read its status without
///   memorising the numbers; anything going through ``LiveStreamRepository`` gets
///   ``BunnyLiveStreamStatus`` instead and doesn't need these.
public extension Components.Schemas.LiveStreamStatus {
  static let unknown: Self = ._0
  static let created: Self = ._1
  static let scheduled: Self = ._2
  /// An encoder is connected and pushing, but the stream has not been taken live yet.
  static let preview: Self = ._3
  static let running: Self = ._4
  static let ended: Self = ._5
  static let vodProcessing: Self = ._6
  static let error: Self = ._7
}

/// An RTMP output the incoming stream is forwarded to.
public struct BunnyRtmpOutput: Equatable, Sendable {
  public let endpoint: String?
  public let streamKey: String?

  public init(endpoint: String?, streamKey: String?) {
    self.endpoint = endpoint
    self.streamKey = streamKey
  }
}

/// A live stream, expressed in the SDK's own vocabulary rather than the generated OpenAPI types.
///
/// Public SDK entry points take and return this type so that regenerating the API client can't
/// change their signatures.
public struct BunnyLiveStream: Equatable, Sendable {
  /// The GUID of the live stream.
  public let id: String?
  /// The ID of the library that contains the stream.
  public let libraryId: Int64?
  /// The title of the live stream.
  public let title: String?
  public let description: String?
  /// The key an encoder authenticates the RTMP publish with.
  public let streamKey: String?
  /// The HLS playback URL.
  public let playbackUrl: String?
  /// The primary RTMP ingest URL to publish to.
  public let primaryIngestUrl: String?
  /// The backup RTMP ingest URL, used when the primary endpoint stops accepting the publish.
  public let backupIngestUrl: String?
  public let status: BunnyLiveStreamStatus
  public let recordVod: Bool
  public let dvrEnabled: Bool
  /// How far back viewers can rewind, in seconds. Zero when DVR is off.
  public let dvrWindowSeconds: Int
  public let isPublic: Bool
  public let collectionId: String?
  public let scheduledStartTime: Date?
  public let scheduledEndTime: Date?
  public let enableCountdown: Bool
  /// The GUID of a VOD video looped as a trailer before the stream starts.
  public let preStreamTrailerVideoId: String?
  /// When the stream actually started.
  public let startedAt: Date?
  /// The thumbnail shown while the stream is offline.
  public let thumbnailUrl: String?
  /// The offline thumbnail's path within the CDN zone. Combine with the playback host and
  /// ``id`` to build the full URL — see ``offlineThumbnailUrl``.
  public let thumbnailFileName: String?
  /// Whether the primary ingest is currently receiving data. Only some endpoints populate this —
  /// ``LiveStreamRepository/ingestStatus(libraryId:streamId:)`` is the reliable source.
  public let primaryLive: Bool?
  /// Whether the backup ingest is currently receiving data.
  public let backupLive: Bool?
  public let ingestRegion: String?
  public let rtmpOutputs: [BunnyRtmpOutput]

  public init(
    id: String?,
    libraryId: Int64? = nil,
    title: String? = nil,
    description: String? = nil,
    streamKey: String? = nil,
    playbackUrl: String? = nil,
    primaryIngestUrl: String? = nil,
    backupIngestUrl: String? = nil,
    status: BunnyLiveStreamStatus = .unknown,
    recordVod: Bool = false,
    dvrEnabled: Bool = false,
    dvrWindowSeconds: Int = 0,
    isPublic: Bool = false,
    collectionId: String? = nil,
    scheduledStartTime: Date? = nil,
    scheduledEndTime: Date? = nil,
    enableCountdown: Bool = false,
    preStreamTrailerVideoId: String? = nil,
    startedAt: Date? = nil,
    thumbnailUrl: String? = nil,
    thumbnailFileName: String? = nil,
    primaryLive: Bool? = nil,
    backupLive: Bool? = nil,
    ingestRegion: String? = nil,
    rtmpOutputs: [BunnyRtmpOutput] = []
  ) {
    self.id = id
    self.libraryId = libraryId
    self.title = title
    self.description = description
    self.streamKey = streamKey
    self.playbackUrl = playbackUrl
    self.primaryIngestUrl = primaryIngestUrl
    self.backupIngestUrl = backupIngestUrl
    self.status = status
    self.recordVod = recordVod
    self.dvrEnabled = dvrEnabled
    self.dvrWindowSeconds = dvrWindowSeconds
    self.isPublic = isPublic
    self.collectionId = collectionId
    self.scheduledStartTime = scheduledStartTime
    self.scheduledEndTime = scheduledEndTime
    self.enableCountdown = enableCountdown
    self.preStreamTrailerVideoId = preStreamTrailerVideoId
    self.startedAt = startedAt
    self.thumbnailUrl = thumbnailUrl
    self.thumbnailFileName = thumbnailFileName
    self.primaryLive = primaryLive
    self.backupLive = backupLive
    self.ingestRegion = ingestRegion
    self.rtmpOutputs = rtmpOutputs
  }

  /// The full URL of the offline thumbnail, or `nil` when the stream has none.
  ///
  /// Bunny returns the thumbnail as a path relative to the CDN zone, so it has to be combined
  /// with the playback host and the stream's GUID.
  public var offlineThumbnailUrl: URL? {
    guard let thumbnailFileName, !thumbnailFileName.isEmpty,
          let id, !id.isEmpty,
          let playbackUrl, let host = URL(string: playbackUrl)?.host
    else { return nil }
    return URL(string: "https://\(host)/\(id)/\(thumbnailFileName)")
  }

  /// Bridges a live stream returned by the generated API client into the domain model.
  ///
  /// - Note: Prefer ``LiveStreamRepository``, which hands back domain models directly. This
  ///   initializer exists for code still holding a generated response.
  public init(from model: Components.Schemas.LiveStreamModel) {
    let status: BunnyLiveStreamStatus = {
      guard case .LiveStreamStatus(let value)? = model.status else { return .unknown }
      return BunnyLiveStreamStatus(rawValue: value.rawValue)
    }()

    self.init(
      id: model.guid ?? model.id,
      libraryId: model.videoLibraryId,
      title: model.title ?? model.name,
      description: model.description,
      streamKey: model.streamKey,
      playbackUrl: model.playbackUrlHls ?? model.playbackUrl,
      primaryIngestUrl: model.ingestEndpoints?.rtmp?.primaryIngestUrl,
      backupIngestUrl: model.ingestEndpoints?.rtmp?.backupIngestUrl,
      status: status,
      recordVod: model.recordVod ?? false,
      dvrEnabled: model.dvrEnabled ?? false,
      dvrWindowSeconds: model.dvrEnabled == true ? Int(model.dvrWindowSeconds ?? 0) : 0,
      isPublic: model._public ?? false,
      collectionId: model.collectionId,
      scheduledStartTime: model.scheduledStartTime.flatMap(Date.init(bunnyTimestamp:)),
      scheduledEndTime: model.scheduledEndTime.flatMap(Date.init(bunnyTimestamp:)),
      enableCountdown: model.enableCountdown ?? false,
      preStreamTrailerVideoId: model.preStreamTrailerVideoId,
      startedAt: model.startedAt.flatMap(Date.init(bunnyTimestamp:)),
      thumbnailUrl: model.thumbnailUrl,
      thumbnailFileName: model.thumbnailFileName,
      primaryLive: model.primaryLive,
      backupLive: model.backupLive,
      ingestRegion: model.ingestRegion,
      rtmpOutputs: (model.rtmpOutputs ?? []).map {
        BunnyRtmpOutput(endpoint: $0.endpoint, streamKey: $0.streamKey)
      }
    )
  }
}
