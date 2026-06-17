import BunnyStreamAPI
import Foundation

/// A protocol that defines the interface for creating upload requests.
///
/// Types conforming to this protocol are responsible for constructing properly
/// formatted URLRequests for video uploads, including the necessary authentication
/// and content-type headers.
protocol RequestBuilder {
  /// Creates a URLRequest for uploading a video.
  ///
  /// - Parameters:
  ///   - info: The video information used to construct the request URL and headers.
  ///   - accessKey: The API access key for authentication.
  /// - Returns: A configured URLRequest if the URL can be constructed, nil otherwise.
  func createRequest(for info: VideoInfo, with accessKey: String) -> URLRequest?
}

/// A request builder implementation for BunnyCDN's video upload API.
///
/// This builder creates requests that conform to BunnyCDN's API requirements:
/// - Uses HTTPS
/// - Includes the library ID and video ID in the URL path
/// - Sets the appropriate content type and authentication headers
/// - Uses PUT method for uploads
struct URLSessionRequestBuilder: RequestBuilder {
  /// Creates a URLRequest configured for BunnyCDN video uploads.
  ///
  /// This method constructs a request with:
  /// - URL: `https://video.bunnycdn.com/library/{libraryId}/videos/{videoId}`
  /// - Method: PUT
  /// - Headers:
  ///   - AccessKey: For authentication
  ///   - Content-Type: application/octet-stream
  ///
  /// - Parameters:
  ///   - info: The video information containing the library and video IDs.
  ///   - accessKey: The BunnyCDN API access key.
  /// - Returns: A configured URLRequest if the URL is valid, nil otherwise.
  func createRequest(for info: VideoInfo, with accessKey: String) -> URLRequest? {
    let urlString = "https://video.bunnycdn.com/library/\(info.libraryId)/videos/\(info.videoId)"
    guard let url = URL(string: urlString) else { return nil }

    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = [
      "AccessKey": accessKey,
      "Content-Type": "application/octet-stream",
      SDKInfo.userAgentHeaderField: SDKInfo.userAgent
    ]
    request.httpMethod = "PUT"
    return request
  }
}
