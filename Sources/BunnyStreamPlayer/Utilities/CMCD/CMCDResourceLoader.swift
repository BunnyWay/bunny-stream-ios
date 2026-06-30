import AVFoundation
import BunnyStreamAPI
import Foundation

final class CMCDResourceLoader: NSObject {
    // Custom scheme must be all lowercase letters only — AVFoundation rejects schemes with "+" or other special chars.
    private static let customScheme = "bunnycmcd"
    private static let originalScheme = "https"

    private let session: CMCDSession
    private let urlSession: URLSession
    private var activeTasks: [AVAssetResourceLoadingRequest: URLSessionTask] = [:]
    private let lock = NSLock()

    init(session: CMCDSession) {
        self.session = session
        self.urlSession = URLSession(configuration: .default)
    }

    // MARK: - URL rewriting

    static func rewrite(_ url: URL) -> URL {
        guard url.scheme == originalScheme else { return url }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        components.scheme = customScheme
        return components.url ?? url
    }

    private static func restore(_ url: URL) -> URL {
        guard url.scheme == customScheme else { return url }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        components.scheme = originalScheme
        return components.url ?? url
    }
}

// MARK: - AVAssetResourceLoaderDelegate

extension CMCDResourceLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard let url = loadingRequest.request.url,
              url.scheme == Self.customScheme else {
            return false
        }
        let realURL = Self.restore(url)
        startLoad(loadingRequest, realURL: realURL)
        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        didCancel loadingRequest: AVAssetResourceLoadingRequest
    ) {
        lock.lock()
        let task = activeTasks.removeValue(forKey: loadingRequest)
        lock.unlock()
        task?.cancel()
    }
}

// MARK: - Loading

private extension CMCDResourceLoader {
    func startLoad(_ loadingRequest: AVAssetResourceLoadingRequest, realURL: URL) {
        let mode = CMCDConfiguration.transmissionMode
        let objectType = CMCDHeaderBuilder.objectType(for: realURL)

        // In query mode, CMCD travels as a percent-encoded `CMCD` query parameter on the URL.
        let requestURL = mode.sendsQuery
            ? CMCDHeaderBuilder.appendingCMCDQuery(
                to: realURL,
                value: CMCDHeaderBuilder.queryValue(for: session, objectType: objectType)
              )
            : realURL

        var urlRequest = URLRequest(url: requestURL)

        // Copy original headers from AVPlayer's request
        loadingRequest.request.allHTTPHeaderFields?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        urlRequest.setValue(SDKInfo.userAgent, forHTTPHeaderField: SDKInfo.userAgentHeaderField)

        // Only send a Range header for genuine partial requests (offset > 0).
        // Avoid "bytes=0-" for full-segment fetches — live CMAF segments are atomic
        // chunks that should be fetched in one request without a Range header.
        if let dataRequest = loadingRequest.dataRequest, dataRequest.requestedOffset > 0 {
            let start = dataRequest.requestedOffset
            if dataRequest.requestsAllDataToEndOfResource {
                urlRequest.setValue("bytes=\(start)-", forHTTPHeaderField: "Range")
            } else {
                let end = start + Int64(dataRequest.requestedLength) - 1
                urlRequest.setValue("bytes=\(start)-\(end)", forHTTPHeaderField: "Range")
            }
        }

        // Add CMCD headers
        if mode.sendsHeaders {
            CMCDHeaderBuilder.headers(for: session, objectType: objectType).forEach {
                urlRequest.setValue($1, forHTTPHeaderField: $0)
            }
        }

        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self else { return }
            self.lock.lock()
            self.activeTasks.removeValue(forKey: loadingRequest)
            self.lock.unlock()

            if loadingRequest.isCancelled { return }

            if let error {
                loadingRequest.finishLoading(with: error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data else {
                loadingRequest.finishLoading(with: URLError(.badServerResponse))
                return
            }

            // Rewrite M3U8 manifest URLs before filling content info so contentLength is accurate
            let isManifest = realURL.pathExtension.lowercased() == "m3u8"
                || (httpResponse.mimeType ?? "").contains("mpegurl")
            let responseData: Data
            if isManifest, let text = String(data: data, encoding: .utf8) {
                responseData = self.rewriteManifest(text, baseURL: realURL).data(using: .utf8) ?? data
            } else {
                responseData = data
                // First non-manifest response marks end of startup
                self.session.markStartupComplete()
            }

            // Fill content information using the (potentially rewritten) responseData size
            if let contentInfo = loadingRequest.contentInformationRequest {
                contentInfo.contentLength = Int64(responseData.count)
                // Live CMAF segments are atomic chunks — no byte-range sub-requests needed.
                contentInfo.isByteRangeAccessSupported = false
                contentInfo.contentType = Self.contentType(from: httpResponse, url: realURL)
            }

            loadingRequest.dataRequest?.respond(with: responseData)
            loadingRequest.finishLoading()
        }

        lock.lock()
        activeTasks[loadingRequest] = task
        lock.unlock()
        task.resume()
    }

    // MARK: - Manifest rewriting

    func rewriteManifest(_ text: String, baseURL: URL) -> String {
        let lines = text.components(separatedBy: "\n")
        return lines.map { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Tag lines with URI="..." attribute
            if trimmed.hasPrefix("#") {
                return rewriteTagLine(line, baseURL: baseURL)
            }

            // Segment URI line (non-empty, non-comment)
            if !trimmed.isEmpty {
                return rewriteURI(trimmed, baseURL: baseURL)
            }

            return line
        }.joined(separator: "\n")
    }

    func rewriteTagLine(_ line: String, baseURL: URL) -> String {
        guard let range = line.range(of: #"URI="([^"]+)""#, options: .regularExpression) else {
            return line
        }
        let match = String(line[range])
        guard let innerRange = match.range(of: #""([^"]+)""#, options: .regularExpression) else {
            return line
        }
        let quoted = String(match[innerRange]) // includes quotes
        let uri = String(quoted.dropFirst().dropLast())
        let rewritten = rewriteURI(uri, baseURL: baseURL)
        return line.replacingCharacters(in: range, with: "URI=\"\(rewritten)\"")
    }

    func rewriteURI(_ uri: String, baseURL: URL) -> String {
        let resolved: URL
        if let absolute = URL(string: uri), absolute.scheme != nil {
            resolved = absolute
        } else {
            resolved = URL(string: uri, relativeTo: baseURL)?.absoluteURL ?? baseURL
        }
        return Self.rewrite(resolved).absoluteString
    }

    // MARK: - Content type

    static func contentType(from response: HTTPURLResponse, url: URL) -> String {
        if let mime = response.mimeType {
            switch mime {
            case _ where mime.contains("mpegurl"): return "public.m3u-playlist"
            case _ where mime.contains("video"): return "public.mpeg-4"
            case _ where mime.contains("audio"): return "public.aac-audio"
            default: break
            }
        }
        switch url.pathExtension.lowercased() {
        case "m3u8": return "public.m3u-playlist"
        case "ts": return "public.mpeg-2-transport-stream"
        case "mp4", "m4s", "m4v": return "public.mpeg-4"
        case "aac", "m4a": return "public.aac-audio"
        default: return "public.data"
        }
    }
}
