import Foundation
import SwiftUI
import BunnyStreamAPI

public struct VideoPlayerConfigLoader {
  public init() {}
  
  func load(libraryId: Int, videoId: String, accessKey: String? = nil, token: String? = nil, expires: Int64? = nil) async throws -> VideoConfigResponse {
    guard var components = URLComponents(string: "https://video.bunnycdn.com/library/\(libraryId)/videos/\(videoId)/play") else {
      throw VideoPlayerError.unknownError
    }

    var queryItems: [URLQueryItem] = []
    if let token {
      queryItems.append(URLQueryItem(name: "token", value: token))
    }
    if let expires {
      queryItems.append(URLQueryItem(name: "expires", value: String(expires)))
    }
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }

    guard let url = components.url else {
      throw VideoPlayerError.unknownError
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(BunnyCDN.referer, forHTTPHeaderField: "Referer")
    request.addValue(SDKInfo.userAgent, forHTTPHeaderField: SDKInfo.userAgentHeaderField)
    // Authenticate with the library AccessKey when available so non-public / token-secured videos
    // resolve — this endpoint returns 404 for protected videos otherwise. Mirrors the Android SDK,
    // which sends AccessKey on every API call. Public videos still play with no key.
    if let accessKey, !accessKey.isEmpty {
      request.addValue(accessKey, forHTTPHeaderField: "AccessKey")
    }

    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw VideoPlayerError.unknownError
      }

      if !(200...299).contains(httpResponse.statusCode) {
        // Surface the exact endpoint + status for integrators debugging playback (a 404 here
        // means the videoId/libraryId pair doesn't resolve — wrong ID, wrong library, or a
        // non-public video fetched without auth).
        print("[BunnyStreamPlayer] play-data HTTP \(httpResponse.statusCode) — \(url.absoluteString)")
      }
      switch httpResponse.statusCode {
      case 200...299:
        let config = try JSONDecoder().decode(VideoConfigResponse.self, from: data)
        return config
      case 401:
        throw VideoPlayerError.unauthorized
      case 403:
        // Deliberately not split by cause (geo-blocking, referrer, token auth) — see `notAvailable`.
        throw VideoPlayerError.notAvailable
      case 404:
        throw VideoPlayerError.notFound
      case 500:
        throw VideoPlayerError.internalServerError
      default:
        throw VideoPlayerError.unknownError
      }
    } catch let error as VideoPlayerError {
      throw error
    } catch {
      throw VideoPlayerError.unknownError
    }
  }
  
  public func loadVideoThumbnail(libraryId: Int, videoId: String, accessKey: String? = nil, token: String? = nil, expires: Int64? = nil) async throws -> String {
    try await load(libraryId: libraryId, videoId: videoId, accessKey: accessKey, token: token, expires: expires).thumbnailUrl
  }
}
