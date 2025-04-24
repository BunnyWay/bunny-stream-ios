import Foundation

struct Caption: Hashable {
  var languageCode: String
  var label: String
  var captionsPath: String?
  
  var captionsURL: URL? {
    guard let basePath = captionsPath, var baseUrl = URL(string: basePath) else {
      return nil
    }
    // Ensures path ends with / before appending filename
    if !basePath.hasSuffix("/") {
        baseUrl.appendPathComponent("")
    }
    return baseUrl.appendingPathComponent("\(languageCode).vtt")
  }
}
