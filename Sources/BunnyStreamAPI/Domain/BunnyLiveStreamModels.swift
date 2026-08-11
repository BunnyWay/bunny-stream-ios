import Foundation

/// One page of live streams.
public struct BunnyLiveStreamList: Equatable, Sendable {
  public let items: [BunnyLiveStream]
  public let totalItems: Int
  public let currentPage: Int
  public let itemsPerPage: Int

  public init(items: [BunnyLiveStream], totalItems: Int, currentPage: Int, itemsPerPage: Int) {
    self.items = items
    self.totalItems = totalItems
    self.currentPage = currentPage
    self.itemsPerPage = itemsPerPage
  }

  init(from model: Components.Schemas.PaginationListOfLiveStreamModel) {
    self.init(
      items: (model.items ?? []).map(BunnyLiveStream.init(from:)),
      totalItems: Int(model.totalItems ?? 0),
      currentPage: Int(model.currentPage ?? 0),
      itemsPerPage: Int(model.itemsPerPage ?? 0)
    )
  }
}

/// Playback data for a live stream, plus the player appearance configured in the Bunny dashboard.
public struct BunnyLiveStreamPlayData: Equatable, Sendable {
  /// The stream the playback data belongs to.
  public let liveStream: BunnyLiveStream?
  public let libraryName: String?
  /// The HLS playlist (.m3u8) URL.
  public let videoPlaylistUrl: String?
  /// Thumbnail shown while the stream is offline.
  public let thumbnailUrl: String?
  /// Animated WebP preview.
  public let previewUrl: String?
  /// Base path for DVR seek thumbnails.
  public let seekPath: String?
  public let captionsPath: String?
  public let isDRMEnabled: Bool
  /// Primary player colour (hex) configured for the library or stream.
  public let playerKeyColor: String?
  public let fontFamily: String?
  public let uiLanguage: String?
  public let showHeatmap: Bool
  public let enableCompactControls: Bool
  /// The enabled player controls, already split from the comma-separated form.
  public let controls: [String]

  public init(
    liveStream: BunnyLiveStream?,
    libraryName: String? = nil,
    videoPlaylistUrl: String? = nil,
    thumbnailUrl: String? = nil,
    previewUrl: String? = nil,
    seekPath: String? = nil,
    captionsPath: String? = nil,
    isDRMEnabled: Bool = false,
    playerKeyColor: String? = nil,
    fontFamily: String? = nil,
    uiLanguage: String? = nil,
    showHeatmap: Bool = false,
    enableCompactControls: Bool = false,
    controls: [String] = []
  ) {
    self.liveStream = liveStream
    self.libraryName = libraryName
    self.videoPlaylistUrl = videoPlaylistUrl
    self.thumbnailUrl = thumbnailUrl
    self.previewUrl = previewUrl
    self.seekPath = seekPath
    self.captionsPath = captionsPath
    self.isDRMEnabled = isDRMEnabled
    self.playerKeyColor = playerKeyColor
    self.fontFamily = fontFamily
    self.uiLanguage = uiLanguage
    self.showHeatmap = showHeatmap
    self.enableCompactControls = enableCompactControls
    self.controls = controls
  }

  init(from model: Components.Schemas.LiveStreamPlayDataModel) {
    self.init(
      liveStream: model.liveStream.map(BunnyLiveStream.init(from:)),
      libraryName: model.libraryName,
      videoPlaylistUrl: model.videoPlaylistUrl,
      thumbnailUrl: model.thumbnailUrl,
      previewUrl: model.previewUrl,
      seekPath: model.seekPath,
      captionsPath: model.captionsPath,
      isDRMEnabled: model.enableDRM ?? false,
      playerKeyColor: model.playerKeyColor,
      fontFamily: model.fontFamily,
      uiLanguage: model.uiLanguage,
      showHeatmap: model.showHeatmap ?? false,
      enableCompactControls: model.enableCompactControls ?? false,
      controls: (model.controls ?? "")
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
    )
  }
}

/// Live ingest state, from the lightweight `/status` endpoint suited to frequent polling.
///
/// The full stream model doesn't report per-ingest liveness, so this is what drives the
/// Primary/Backup badges and proactive failover.
public struct BunnyLiveStreamIngestStatus: Equatable, Sendable {
  /// Whether the stream can be taken live, based on ingest activity.
  public let readyToStart: Bool
  /// Whether the primary ingest is receiving data, or `nil` when the server didn't report it.
  ///
  /// The distinction matters: callers show "unknown" rather than "offline" until the first
  /// answer arrives, and failover must not treat a missing value as a dead ingest.
  public let primaryLive: Bool?
  /// Whether the backup ingest is receiving data, or `nil` when the server didn't report it.
  public let backupLive: Bool?
  /// Milliseconds since the last ingest ping.
  public let lastPingAgo: Int64?
  /// Stream duration in seconds.
  public let duration: Int?
  /// When the status was read.
  public let statusTime: Date?

  /// Whether either ingest is confirmed to be receiving data.
  public var isLive: Bool { primaryLive == true || backupLive == true }

  public init(
    readyToStart: Bool,
    primaryLive: Bool?,
    backupLive: Bool?,
    lastPingAgo: Int64? = nil,
    duration: Int? = nil,
    statusTime: Date? = nil
  ) {
    self.readyToStart = readyToStart
    self.primaryLive = primaryLive
    self.backupLive = backupLive
    self.lastPingAgo = lastPingAgo
    self.duration = duration
    self.statusTime = statusTime
  }

  init(from model: Components.Schemas.LiveStreamStatusModel) {
    self.init(
      readyToStart: model.readyToStart ?? false,
      primaryLive: model.primaryLive,
      backupLive: model.backupLive,
      lastPingAgo: model.lastPingAgo,
      duration: model.duration.map(Int.init),
      statusTime: model.statusTimeUtc.flatMap(Date.init(bunnyTimestamp:))
    )
  }
}

/// A captured live stream thumbnail.
public struct BunnyLiveStreamThumbnail: Equatable, Sendable {
  public let url: String?
  /// When the frame was captured.
  public let timestamp: Date?

  public init(url: String?, timestamp: Date?) {
    self.url = url
    self.timestamp = timestamp
  }

  init(from model: Components.Schemas.ThumbnailListResponseModel) {
    self.init(
      url: model.url,
      timestamp: model.timestamp.flatMap(Date.init(bunnyTimestamp:))
    )
  }
}

/// The image formats the thumbnail upload endpoint accepts.
///
/// The API rejects `application/octet-stream`, so the format has to be stated explicitly.
public enum BunnyImageFormat: Equatable, Sendable {
  case jpeg
  case png
  case webp
  case gif
}
