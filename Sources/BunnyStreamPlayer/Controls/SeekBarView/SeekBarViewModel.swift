import SwiftUI

class SeekBarViewModel: ObservableObject {
  @Published var video: Video
  @Published var heatmap: Heatmap
  @Published var elapsedTime: Double = .zero
  @Published var thumbnailSize: CGSize = .zero
  @Published var seekableRange: ClosedRange<Double>? = nil
  let player: MediaPlayer
  
  init(player: MediaPlayer, video: Video, heatmap: Heatmap) {
    self.player = player
    self.video = video
    self.heatmap = heatmap
  }
  
  func seek(to percentage: Double) {
    let seekTime: Double
    if let range = seekableRange {
      seekTime = range.lowerBound + (range.upperBound - range.lowerBound) * percentage
    } else {
      seekTime = duration * percentage
    }
    player.jump(to: seekTime)
  }

  var duration: Double {
    if let range = seekableRange {
      return ceil(range.upperBound - range.lowerBound)
    }
    return ceil(player.duration)
  }
  
  var thumbnailYOffset: CGFloat {
    if scaledThumbnailSize.width > scaledThumbnailSize.height {
      return -scaledThumbnailSize.height * 1.5
    } else {
      return -scaledThumbnailSize.width * 1.8
    }
  }
  
  var scaledThumbnailSize: CGSize {
    guard thumbnailSize.width > 0, thumbnailSize.height > 0 else {
      return .zero
    }
    let widthScale = SeekBarView.UI.thumbnailSize / thumbnailSize.width
    let heightScale = SeekBarView.UI.thumbnailSize / thumbnailSize.height
    let scale = min(widthScale, heightScale)
    
    return CGSize(width: scale * thumbnailSize.width, height: scale * thumbnailSize.height)
  }
}
