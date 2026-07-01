import Foundation
import BunnyStreamAPI

enum LiveStreamDisplayState {
    case playable(url: URL, isVodRecording: Bool)
    case countdown(until: Date, thumbnailUrl: URL?, title: String?)
    case trailer(vodId: String, scheduledStart: Date?, statusMessage: String?, title: String?)
    case offline(message: String, thumbnailUrl: URL?)
    case error(message: String, thumbnailUrl: URL?)
}

// MARK: - Readable aliases for the generated integer enum

public extension Components.Schemas.LiveStreamStatus {
    static let created: Self = ._1
    static let scheduled: Self = ._2
    static let running: Self = ._4
    static let ended: Self = ._5
    static let vodProcessing: Self = ._6
    static let error: Self = ._7
}

// MARK: - State resolver

func resolveDisplayState(
    from model: Components.Schemas.LiveStreamModel,
    now: Date = .now
) -> LiveStreamDisplayState {
    let status = model.statusValue

    // isPlayable: Running, OR (Ended/VodProcessing AND recordVod)
    let isRunning = status == .running
    let isRecordingPlayable = (status == .ended || status == .vodProcessing) && model.recordVod == true

    if isRunning || isRecordingPlayable {
        let hlsString = model.playbackUrlHls ?? model.playbackUrl
        guard let urlString = hlsString, let url = URL(string: urlString) else {
            return .error(message: Lingua.LiveStream.streamError, thumbnailUrl: nil)
        }
        return .playable(url: url, isVodRecording: !isRunning)
    }

    // pre-stream trailer: preStreamTrailerVideoId set, stream not yet started
    let preStreamStatuses: [Components.Schemas.LiveStreamStatus] = [.created, .scheduled]
    if let vodId = model.preStreamTrailerVideoId,
       !vodId.isEmpty,
       model.startedAt == nil,
       let status, preStreamStatuses.contains(status) {
        let scheduledStart = model.scheduledStartTime.flatMap {
            Date(bunnyString: $0)
        }
        
        return .trailer(
            vodId: vodId,
            scheduledStart: scheduledStart,
            statusMessage: Lingua.LiveStream.streamNotActive,
            title: model.title
        )
    }

    // countdown: Scheduled + enableCountdown + scheduledStartTime in the future
    if status == .scheduled,
       model.enableCountdown == true,
       let startString = model.scheduledStartTime,
       let start = Date(bunnyString: startString),
       start > now {
        return .countdown(until: start, thumbnailUrl: model.thumbnailUrl.flatMap(URL.init(string:)), title: model.title)
    }

    let thumbnailUrl = model.thumbnailUrl.flatMap(URL.init(string:))

    // error state
    if status == .error {
        return .error(message: Lingua.LiveStream.streamError, thumbnailUrl: thumbnailUrl)
    }

    // offline with context-aware message
    let message: String
    if status == .ended || status == .vodProcessing {
        message = Lingua.LiveStream.streamEnded
    } else {
        message = Lingua.LiveStream.streamNotActive
    }
    return .offline(message: message, thumbnailUrl: thumbnailUrl)
}

// MARK: - Helpers

private extension Components.Schemas.LiveStreamModel {
    var statusValue: Components.Schemas.LiveStreamStatus? {
        guard case .LiveStreamStatus(let s) = status else { return nil }
        return s
    }
}

extension Date {
    // Bunny returns dates without milliseconds or with varied precision, e.g. "2026-06-03T09:21:41"
    init?(bunnyString: String) {
        for formatter in Date.bunnyDateFormatters {
            if let date = formatter.date(from: bunnyString) {
                self = date
                return
            }
        }
        return nil
    }

    private static let bunnyDateFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss",
        ]
        
        return formats.map { format in
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(abbreviation: "UTC")
            f.dateFormat = format
            return f
        }
    }()
}
