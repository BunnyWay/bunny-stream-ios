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
  init(rtmpUrl: String, streamKey: String) {
    self.uri = rtmpUrl
    self.accessKey = ""
    self.libraryId = 0
    self.directStreamKey = streamKey
  }
}
