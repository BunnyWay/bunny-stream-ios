import AVFoundation
import Foundation

final class CMCDSession {
    enum StreamType: String {
        case live = "l"
        case vod = "v"
        case event = "e"
    }

    let sessionId = UUID().uuidString
    let contentId: String
    let streamType: StreamType
    private(set) var isStartup = true
    weak var player: AVPlayer?

    init(contentId: String, streamType: StreamType) {
        self.contentId = contentId
        self.streamType = streamType
    }

    func markStartupComplete() {
        isStartup = false
    }

    var bufferLengthMs: Int {
        guard let player,
              let item = player.currentItem,
              let range = item.loadedTimeRanges.last?.timeRangeValue else { return 0 }
        let currentTime = player.currentTime().seconds
        let bufferEnd = (range.start + range.duration).seconds
        return Int(max(0, bufferEnd - currentTime) * 1000)
    }

    var isBufferStarved: Bool {
        player?.currentItem?.isPlaybackBufferEmpty == true
    }
}
