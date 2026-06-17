import AVFoundation

extension MediaPlayer {
  static func makeLive(url: URL, seekableWindowSeconds: Double, contentId: String) -> MediaPlayer {
    let streamType: CMCDSession.StreamType = seekableWindowSeconds > 0 ? .event : .live
    let player = MediaPlayer(liveURL: url, contentId: contentId, streamType: streamType)
    player.automaticallyWaitsToMinimizeStalling = false
    player.kind = seekableWindowSeconds > 0 ? .event : .live
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
