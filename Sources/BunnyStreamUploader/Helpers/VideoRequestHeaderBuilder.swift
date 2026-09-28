import BunnyStreamAPI
import Foundation

/// A helper structure that constructs HTTP headers for video upload requests.
///
/// This builder creates the necessary HTTP headers for authenticating and describing
/// video upload requests to the server, including authorization, metadata, and
/// organizational information.
struct VideoRequestHeaderBuilder {
  /// Builds a dictionary of HTTP headers required for a video upload request.
  ///
  /// This method constructs headers containing:
  /// - Authorization information (signature and expiration)
  /// - Video metadata (filename and filetype in base64 encoding)
  /// - Organizational information (library ID and optional collection ID)
  ///
  /// - Parameters:
  ///   - info: The `VideoInfo` containing metadata about the video to be uploaded.
  ///   - signature: The authorization signature for the request.
  /// - Returns: A dictionary of header names to values (Headers type).
  func buildHeaders(for info: VideoInfo, signature: String) -> Headers {
    let filenameBase64 = info.title.data(using: .utf8)?.base64EncodedString() ?? ""
    let filetypeBase64 = info.fileType.data(using: .utf8)?.base64EncodedString() ?? ""
    
    var headers: Headers = [
      "AuthorizationSignature": signature,
      "AuthorizationExpire": info.expirationTimeString,
      "VideoId": info.videoId,
      "LibraryId": "\(info.libraryId)",
      SDKInfo.userAgentHeaderField: SDKInfo.userAgent,
      "Upload-Metadata": "filename \(filenameBase64),filetype \(filetypeBase64)"
    ]
    
    if let collectionId = info.collectionId {
      headers["collection"] = collectionId
    }
    
    return headers
  }
}
