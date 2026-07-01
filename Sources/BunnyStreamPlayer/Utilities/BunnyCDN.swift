import Foundation
import Kingfisher

/// Shared configuration for requests hitting the Bunny CDN.
///
/// When a library enables **"Block direct URL file access"** in its security settings, the CDN
/// rejects requests that arrive without a `Referer` header (HTTP 403). This affects thumbnails,
/// offline/countdown posters, seek-bar preview sprites and client-side watermarks — anything the
/// player loads as a plain image request.
///
/// We attach the same embed-player `Referer` that Bunny's own web player uses, so protected
/// libraries keep serving these assets. This mirrors the header already sent on the `/play`
/// config request in ``VideoPlayerConfigLoader``.
enum BunnyCDN {
  /// Referer sent with Bunny CDN image/metadata requests.
  static let referer = "https://iframe.mediadelivery.net/"

  /// Kingfisher request modifier that attaches ``referer`` to image downloads.
  static let refererModifier = AnyModifier { request in
    var request = request
    request.setValue(referer, forHTTPHeaderField: "Referer")
    return request
  }
}
