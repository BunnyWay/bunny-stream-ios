import Foundation

struct StreamConfig {
  var uri: String = "rtmp://49.13.154.169/ingest"
  let accessKey: String
  let libraryId: Int
  var videoId: String?
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
  init(accessKey: String, libraryId: Int) {
    self.accessKey = accessKey
    self.libraryId = libraryId
  }

  /// For live-stream broadcast flow: uses rtmpUrl + streamKey from the API directly.
  init(rtmpUrl: String, streamKey: String, accessKey: String = "", libraryId: Int = 0, streamId: String? = nil) {
    self.uri = rtmpUrl
    self.accessKey = accessKey
    self.libraryId = libraryId
    self.streamId = streamId
    self.directStreamKey = streamKey
  }

  /// The live stream ID used for activate/complete API calls.
  /// Extracted from playbackUrlHls: https://vz-X.b-cdn.net/live/{STREAM_ID}/live.m3u8
  var streamId: String?
}
