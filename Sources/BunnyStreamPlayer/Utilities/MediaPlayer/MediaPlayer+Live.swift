import AVFoundation

extension MediaPlayer {
  static func makeLive(url: URL, seekableWindowSeconds: Double, contentId: String) -> MediaPlayer {
    let streamType: CMCDSession.StreamType = seekableWindowSeconds > 0 ? .event : .live
    let player = MediaPlayer(liveURL: url, contentId: contentId, streamType: streamType)
    player.kind = seekableWindowSeconds > 0 ? .event : .live
    // Reset playbackInterval now that kind is set so duration returns .infinity for .live
    player.playbackInterval = (0, player.duration)
    return player
  }

  var isAtLiveEdge: Bool {
      guard let range = currentItem?.seekableTimeRanges.last?.timeRangeValue else {
          return true
      }
      
    return abs(currentTimeSeconds - range.end.seconds) < 3.0
  }

  func snapToLiveEdge(toleranceSeconds: Double = 2.0) {
      guard let range = currentItem?.seekableTimeRanges.last?.timeRangeValue else {
          return
      }
      
    seek(
      to: range.end,
      toleranceBefore: CMTimeMakeWithSeconds(toleranceSeconds, preferredTimescale: 1),
      toleranceAfter: .zero
    )
  }
}
