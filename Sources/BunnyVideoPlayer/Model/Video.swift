import Foundation

struct Video {
  var guid: String
  var chaptersList: ValidatedChapterList?
  var moments: [Moment]
  var thumbnailCount: Int
  var width: CGFloat
  var height: CGFloat
  var length: Double
  var cdn: String
  var captions: [Caption]
  var libraryId: Int
  let resolutions: [Resolution]
}

extension Video {
  var seekThumbnail: SeekThumbnail {
    let thumbnailsPerImage = 36
    let urls = seekThumbnailURLs(thumbnailsPerImage: thumbnailsPerImage)
    let frameDurationPerThumbnail = Int(floor(length / Double(thumbnailCount)))
    
    return SeekThumbnail(
      thumbnailUrls: urls,
      frameDurationPerThumbnail: frameDurationPerThumbnail,
      thumbnailCount: thumbnailCount,
      thumbnailsPerImage: thumbnailsPerImage
    )
  }
  
  func seekThumbnailURLs(thumbnailsPerImage: Int) -> [URL] {
    let numberOfPreviews = Int(ceil(Double(thumbnailCount) / Double(thumbnailsPerImage)))
    return (0..<numberOfPreviews).compactMap {
      URL(string: "https://\(cdn)/\(guid)/seek/_\($0).jpg")
    }
  }
}

extension Video {
  init(videoConfigResponse: VideoConfigResponse.Video, cdn: String) {
    let chapters = videoConfigResponse.chapters.map { Chapter(start: Double($0.start), end: Double($0.end), type: .regular(title: $0.title)) }
    let moments = videoConfigResponse.moments.map { Moment(label: $0.label, second: $0.timestamp)}
    let captions = videoConfigResponse.captions.map { Caption(languageCode: $0.srclang, label: $0.label) }
    
    var computedResolutions = [Video.Resolution.auto]
    let resolutionStrings = videoConfigResponse.availableResolutions.split(separator: ",")
    for resolutionLabel in resolutionStrings {
      if let resolution = Video.Resolution(rawValue: String(resolutionLabel)) {
        computedResolutions.append(resolution)
      }
    }
    computedResolutions.sort { $0.bitrate < $1.bitrate }
     
    self.init(guid: videoConfigResponse.guid,
              chaptersList: ValidatedChapterList(originalChapters: chapters, duration: videoConfigResponse.length),
              moments: moments,
              thumbnailCount: videoConfigResponse.thumbnailCount,
              width: CGFloat(videoConfigResponse.width),
              height: CGFloat(videoConfigResponse.height),
              length: videoConfigResponse.length,
              cdn: cdn,
              captions: captions,
              libraryId: videoConfigResponse.videoLibraryId,
              resolutions: computedResolutions)
  }

  mutating func adjustLength(_ length: Double?) {
    guard let length else { return }
    self.length = ceil(length)
    let originalChapters = self.chaptersList?.chapters.filter { $0.type != .gap && $0.type != .rest } ?? []
    self.chaptersList = ValidatedChapterList(originalChapters: originalChapters, duration: self.length)
  }
}
