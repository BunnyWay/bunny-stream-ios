import Foundation
import SwiftUI

public struct VideoPlayerConfigLoader {
  public init() {}
  
  func load(libraryId: Int, videoId: String, token: String? = nil, expires: Int64? = nil) async throws -> VideoConfigResponse {
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
    request.addValue("https://iframe.mediadelivery.net/", forHTTPHeaderField: "Referer")
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw VideoPlayerError.unknownError
      }
      
      switch httpResponse.statusCode {
      case 200...299:
        let config = try JSONDecoder().decode(VideoConfigResponse.self, from: data)
        return config
      case 401:
        throw VideoPlayerError.unauthorized
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
  
  public func loadVideoThumbnail(libraryId: Int, videoId: String, token: String? = nil, expires: Int64? = nil) async throws -> String {
    try await load(libraryId: libraryId, videoId: videoId, token: token, expires: expires).thumbnailUrl
  }
}


extension VideoPlayerConfigLoader {
  enum VideoPlayerError: Error {
    case unauthorized
    case notFound
    case internalServerError
    case unknownError
  }
}
