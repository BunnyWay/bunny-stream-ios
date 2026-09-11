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

    /// Builds the single combined CMCD value used in query mode: all keys merged into one
    /// comma-separated, alphabetically-sorted list (per CTA-5004), before percent-encoding.
    static func queryValue(for session: CMCDSession, objectType: CMCDObjectType) -> String {
        var pairs: [String] = []
        pairs.append("bl=\(session.bufferLengthMs)")
        if session.isBufferStarved { pairs.append("bs") }
        pairs.append("cid=\"\(session.contentId)\"")
        pairs.append("ot=\(objectType.rawValue)")
        pairs.append("sf=h")
        pairs.append("sid=\"\(session.sessionId)\"")
        pairs.append("st=\(session.streamType.rawValue)")
        if session.isStartup { pairs.append("su") }
        pairs.append("v=2")
        // Keys are appended in alphabetical order: bl, bs, cid, ot, sf, sid, st, su, v.
        return pairs.joined(separator: ",")
    }

    /// Appends a percent-encoded `CMCD` query parameter to a URL, preserving any existing query.
    static func appendingCMCDQuery(to url: URL, value: String) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? value
        let cmcdParam = "CMCD=\(encoded)"
        if let existing = components.percentEncodedQuery, !existing.isEmpty {
            components.percentEncodedQuery = existing + "&" + cmcdParam
        } else {
            components.percentEncodedQuery = cmcdParam
        }
        return components.url ?? url
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
