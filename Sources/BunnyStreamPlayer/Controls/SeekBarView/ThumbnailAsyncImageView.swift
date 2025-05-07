import SwiftUI
import Kingfisher

struct ThumbnailAsyncImageView: View {
  var video: Video
  var second: Double
  @State var image: Image?
  @Binding var thumbnailSize: CGSize
  
  @ViewBuilder
  var body: some View {
    if video.seekThumbnail.frameDurationPerThumbnail > 0 {
      content
    }
  }
}

private extension ThumbnailAsyncImageView {
  @MainActor
  var content: some View {
    GeometryReader { geo in
      let frameDuration = video.seekThumbnail.frameDurationPerThumbnail
      let frameIndex = min(Int(floor(second / Double(frameDuration))), Int(video.length / Double(frameDuration)) - 1)
      let urlIndex = frameIndex / video.seekThumbnail.thumbnailsPerImage
      let safeJpgIndex = urlIndex.clamped(to: 0...video.seekThumbnail.thumbnailUrls.count - 1)
      
      let url = video.seekThumbnail.thumbnailUrls[safeJpgIndex]
      let positionWithinImage = frameIndex % video.seekThumbnail.thumbnailsPerImage
      let row = positionWithinImage / video.seekThumbnail.maxColumns
      let column = positionWithinImage % video.seekThumbnail.maxColumns
      
      KFImage.url(url)
        .placeholder {
          ProgressView()
        }
        .onSuccess { result in
          let imageSize = result.image.size
          let thumbnailWidth = imageSize.width / CGFloat(video.seekThumbnail.maxColumns)
          let thumbnailHeight = imageSize.height / CGFloat(video.seekThumbnail.maxRows)
          self.thumbnailSize = .init(width: thumbnailWidth, height: thumbnailHeight)
          self.image = Image(platformImage: result.image)
        }
        .opacity(.zero)
      
      if let image = image {
        let scale = max(geo.size.width / thumbnailSize.width, geo.size.height / thumbnailSize.height)
        image
          .resizable()
          .scaledToFill()
          .frame(width: thumbnailSize.width * CGFloat(video.seekThumbnail.maxColumns) * scale,
                 height: thumbnailSize.height * CGFloat(video.seekThumbnail.maxRows) * scale)
          .clipped()
          .offset(x: -CGFloat(column) * thumbnailSize.width * scale,
                  y: -CGFloat(row) * thumbnailSize.height * scale)
          .clipShape(Rectangle().size(width: geo.size.width, height: geo.size.height))
      }
    }
  }
}
