import Foundation
import BunnyStreamAPI

enum LiveStreamDisplayState: Equatable {
    case playable(url: URL, isVodRecording: Bool)
    case countdown(until: Date, thumbnailUrl: URL?, title: String?)
    case trailer(vodId: String, scheduledStart: Date?, statusMessage: LiveStreamMessage?, title: String?)
    case offline(message: LiveStreamMessage, thumbnailUrl: URL?)
    case error(message: LiveStreamMessage, thumbnailUrl: URL?)
}

// MARK: - State resolver

func resolveDisplayState(
    from stream: BunnyLiveStream,
    now: Date = .now
) -> LiveStreamDisplayState {
    let status = stream.status

    // isPlayable: Running, OR (Ended/VodProcessing AND recordVod)
    let isRunning = status == .running
    let isRecordingPlayable = (status == .ended || status == .vodProcessing) && stream.recordVod

    if isRunning || isRecordingPlayable {
        guard let urlString = stream.playbackUrl, let url = URL(string: urlString) else {
            return .error(message: .error, thumbnailUrl: nil)
        }
        return .playable(url: url, isVodRecording: !isRunning)
    }

    // pre-stream trailer: preStreamTrailerVideoId set, stream not yet started.
    // Preview counts as pre-start: the encoder is connected but viewers can't watch yet.
    let preStreamStatuses: [BunnyLiveStreamStatus] = [.created, .scheduled, .preview]
    if let vodId = stream.preStreamTrailerVideoId,
       !vodId.isEmpty,
       stream.startedAt == nil,
       preStreamStatuses.contains(status) {
        return .trailer(
            vodId: vodId,
            scheduledStart: stream.scheduledStartTime,
            statusMessage: .notActive,
            title: stream.title
        )
    }

    // countdown: Scheduled + enableCountdown + scheduledStartTime in the future
    if status == .scheduled,
       stream.enableCountdown,
       let start = stream.scheduledStartTime,
       start > now {
        return .countdown(
            until: start,
            thumbnailUrl: stream.thumbnailUrl.flatMap(URL.init(string:)),
            title: stream.title
        )
    }

    let thumbnailUrl = stream.thumbnailUrl.flatMap(URL.init(string:))

    // error state
    if status == .error {
        return .error(message: .error, thumbnailUrl: thumbnailUrl)
    }

    // offline with context-aware message
    let message: LiveStreamMessage
    if status == .ended || status == .vodProcessing {
        message = .ended
    } else {
        message = .notActive
    }
    return .offline(message: message, thumbnailUrl: thumbnailUrl)
}
