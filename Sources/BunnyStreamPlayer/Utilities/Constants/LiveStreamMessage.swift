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

  private var key: String {
    switch self {
    case .notActive:    return "stream_not_active"
    case .ended:        return "stream_ended"
    case .error:        return "stream_error"
    case .startingSoon: return "stream_starting_soon"
    }
  }

  /// The wording in `languageCode`, falling back to the app's own language when the code is
  /// missing or the SDK carries no translation for it.
  func localized(languageCode: String? = nil) -> String {
    LiveStreamLocalization.bundle(for: languageCode)
      .localizedString(forKey: key, value: nil, table: "LiveStream")
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
