import Foundation

struct StreamConfig {
  var uri: String = "rtmp://49.13.154.169/ingest"
  /// Backup RTMP ingest URL. Used for failover when the primary ingest keeps failing.
  /// `nil`/empty means no backup is available and reconnects stay on `uri`.
  var backupUri: String?
  let accessKey: String
  let libraryId: Int
  var videoId: String?
  /// Encoder configuration (resolution, frame rate, bitrates) used when publishing.
  var quality: BroadcastQuality
  private var directStreamKey: String?

  var streamKey: String? {
      if let directStreamKey {
          return directStreamKey
      }
      
      guard let videoId else {
          return nil
      }
      
    return "?vid=\(videoId)&accessKey=\(accessKey)&lib=\(libraryId)"
  }

  /// For camera-upload flow: creates a VOD video on publish start.
  init(accessKey: String, libraryId: Int, quality: BroadcastQuality = .default) {
    self.accessKey = accessKey
    self.libraryId = libraryId
    self.quality = quality
  }

  /// For live-stream broadcast flow: uses rtmpUrl + streamKey from the API directly.
  init(rtmpUrl: String, streamKey: String, backupRtmpUrl: String? = nil, accessKey: String = "", libraryId: Int = 0, streamId: String? = nil, quality: BroadcastQuality = .default) {
    self.uri = rtmpUrl
    self.backupUri = backupRtmpUrl
    self.accessKey = accessKey
    self.libraryId = libraryId
    self.streamId = streamId
    self.directStreamKey = streamKey
    self.quality = quality
  }

  /// The live stream ID used for activate/complete API calls.
  /// Extracted from playbackUrlHls: https://vz-X.b-cdn.net/live/{STREAM_ID}/live.m3u8
  var streamId: String?
}
