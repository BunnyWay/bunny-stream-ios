import Foundation

struct StreamConfig {
  var uri: String = "rtmp://49.13.154.169/ingest"
  let accessKey: String
  let libraryId: Int
  var videoId: String?
  
  var streamKey: String? {
    guard let videoId = videoId else { return nil }
    return "?vid=\(videoId)&accessKey=\(accessKey)&lib=\(libraryId)"
  }
  
  init(accessKey: String, libraryId: Int) {
    self.accessKey = accessKey
    self.libraryId = libraryId
  }
}
