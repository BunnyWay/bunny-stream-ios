import Foundation

enum CMCDObjectType: String {
    case manifest = "m"
    case video = "v"
    case audio = "a"
    case initSegment = "i"
    case other = "o"
}

struct CMCDHeaderBuilder {
    static func headers(for session: CMCDSession, objectType: CMCDObjectType) -> [String: String] {
        var headers: [String: String] = [:]
        headers["CMCD-Session"] = sessionHeader(session)
        headers["CMCD-Request"] = requestHeader(session)
        if session.isBufferStarved { headers["CMCD-Status"] = "bs" }
        headers["CMCD-Object"] = "ot=\(objectType.rawValue)"
        return headers
    }

    /// Static CMCD-Session header only — for assets where per-request injection isn't possible (e.g. VOD + FairPlay).
    static func staticSessionHeaders(for session: CMCDSession) -> [String: String] {
        ["CMCD-Session": sessionHeader(session)]
    }

    private static func sessionHeader(_ session: CMCDSession) -> String {
        [
            "sid=\"\(session.sessionId)\"",
            "cid=\"\(session.contentId)\"",
            "sf=h",
            "st=\(session.streamType.rawValue)",
            "v=2"
        ].joined(separator: ",")
    }

    private static func requestHeader(_ session: CMCDSession) -> String {
        var parts = ["bl=\(session.bufferLengthMs)"]
        if session.isStartup { parts.append("su") }
        return parts.joined(separator: ",")
    }

    static func objectType(for url: URL) -> CMCDObjectType {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "m3u8": return .manifest
        case "ts", "m4s": return .video
        case "aac", "m4a": return .audio
        case "mp4":
            // init segments are typically named init.mp4 or contain "init" in the path
            return url.lastPathComponent.lowercased().contains("init") ? .initSegment : .video
        default: return .other
        }
    }
}
