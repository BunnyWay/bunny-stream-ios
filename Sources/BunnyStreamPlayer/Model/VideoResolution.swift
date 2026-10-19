import Foundation

extension Video {
  enum Resolution: String, Identifiable, Equatable {
    var id: Self {
      self
    }
    
    case auto = "0"
    case res240p = "240p"
    case res360p = "360p"
    case res480p = "480p"
    case res720p = "720p"
    case res1080p = "1080p"
    case res1440p = "1440p"
    case res2160p = "2160p"
    
    var label: String {
      switch self {
      case .auto:
        return Lingua.Settings.qualityAuto
      default:
        return self.rawValue
      }
    }
    
    var bitrate: Double {
      switch self {
      case .auto:
        return 0
      case .res240p:
        return 600000
      case .res360p:
        return 800000
      case .res480p:
        return 1400000
      case .res720p:
        return 2800000
      case .res1080p:
        return 5000000
      case .res1440p:
        return 8000000
      case .res2160p:
        return 25000000
      }
    }
  }
}

extension Video.Resolution {
  /// Builds the `preferredPeakBitRate` cap for each menu entry from the stream's real variants.
  ///
  /// A cap only works if it is at least the variant's peak `BANDWIDTH`, which Bunny measures per
  /// video — the same 1080p rendition can peak at 6 Mbps in one video and 8 Mbps in another — so
  /// fixed per-resolution values pick a lower variant than the one selected. Variants are matched
  /// to resolutions by rank (both sorted ascending) rather than by size: a portrait or non-16:9
  /// video's "240p" rendition can be 198×352. Each cap sits halfway to the next variant up, so it
  /// admits the selected one with margin while still excluding the next; the top entry is uncapped.
  ///
  /// - Returns: `nil` when the variant count doesn't match the resolutions, so the caller can fall
  ///   back to `bitrate`.
  static func peakBitRateCaps(
    for resolutions: [Video.Resolution],
    variantPeakBitRates: [Double]
  ) -> [Video.Resolution: Double]? {
    let ranked = resolutions.filter { $0 != .auto }.sorted { $0.bitrate < $1.bitrate }
    let peaks = variantPeakBitRates.sorted()
    guard !ranked.isEmpty, ranked.count == peaks.count else { return nil }

    var caps: [Video.Resolution: Double] = [.auto: 0]
    for (index, resolution) in ranked.enumerated() {
      caps[resolution] = index + 1 < peaks.count ? ((peaks[index] + peaks[index + 1]) / 2).rounded() : 0
    }
    return caps
  }
}
