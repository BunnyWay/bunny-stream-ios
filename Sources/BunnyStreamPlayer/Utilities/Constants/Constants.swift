import Foundation

enum Constants {
  /// Host serving the FairPlay certificate and license endpoints — the same one the embed player
  /// uses, so referrer protection and embed token authentication apply identically.
  static var fairPlayBaseUrlString: String = "https://video.bunnycdn.com"
}
