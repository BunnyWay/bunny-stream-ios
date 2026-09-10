import Foundation

/// A message the live player shows over the video, kept as a value rather than a finished string.
///
/// The dashboard can pin the player's UI to a specific language via `uiLanguage` on the live
/// `/play` response, and that setting arrives separately from — and later than — the stream poll
/// that decides *which* message to show. Resolving the wording at render time instead of at
/// decision time is what lets the two meet. Mirrors Android, which localises its live overlay
/// strings the same way.
enum LiveStreamMessage: Equatable {
  /// The stream hasn't started.
  case notActive
  /// The stream is over.
  case ended
  /// The stream can't be played.
  case error
  /// A scheduled stream is about to begin.
  case startingSoon
  /// Playback was refused with HTTP 403 (geo-blocking, referrer protection, token auth). Worded
  /// generically on purpose, exactly like VOD — the cause is never shown to viewers.
  case notAvailable

  private var entry: (table: String, key: String) {
    switch self {
    case .notActive:    return ("LiveStream", "stream_not_active")
    case .ended:        return ("LiveStream", "stream_ended")
    case .error:        return ("LiveStream", "stream_error")
    case .startingSoon: return ("LiveStream", "stream_starting_soon")
    // Shared with VOD so both players say the same thing, in every language VOD is translated to.
    case .notAvailable: return ("Player", "video_not_available")
    }
  }

  /// The wording in `languageCode`, falling back to the app's own language when the code is
  /// missing or the SDK carries no translation for it.
  func localized(languageCode: String? = nil) -> String {
    let entry = entry
    return LiveStreamLocalization.bundle(for: languageCode)
      .localizedString(forKey: entry.key, value: nil, table: entry.table)
  }
}

enum LiveStreamLocalization {
  private static let moduleBundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleFinder.self)
    #endif
  }()

  #if !SWIFT_PACKAGE
  private final class BundleFinder {}
  #endif

  /// Resolves the `.lproj` bundle for a dashboard language code.
  ///
  /// Bunny hands over codes like `de` or `pt-BR`; the region-qualified form is tried first, then
  /// the bare language. Anything unrecognised falls back to the module bundle, which resolves
  /// against the device's preferred languages as usual.
  static func bundle(for languageCode: String?) -> Bundle {
    guard let languageCode, !languageCode.isEmpty else { return moduleBundle }

    let candidates = [languageCode, String(languageCode.prefix(2))]
    for candidate in candidates {
      if let path = moduleBundle.path(forResource: candidate, ofType: "lproj"),
         let bundle = Bundle(path: path) {
        return bundle
      }
    }
    return moduleBundle
  }
}
