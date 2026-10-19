import AVFoundation
import SwiftUI

class ResolutionsViewModel: ObservableObject {
  private let player: MediaPlayer
  @Published var resolution: Video.Resolution = .auto
  @Published var showResolutions = false
  let availableResolutions: [Video.Resolution]
  /// Caps derived from the stream's variants; `nil` until loaded, or if they can't be matched.
  private var peakBitRateCaps: [Video.Resolution: Double]?
  private var capsLoadTask: Task<Void, Never>?

  init(player: MediaPlayer, video: Video) {
    self.player = player
    self.availableResolutions = video.resolutions
    loadPeakBitRateCapsIfNeeded()
  }

  deinit {
    capsLoadTask?.cancel()
  }

  func resolutionAction(_ resolution: Video.Resolution) {
    self.resolution = resolution
    applyCap()
    loadPeakBitRateCapsIfNeeded()
  }
}

private extension ResolutionsViewModel {
  func applyCap() {
    player.setPlayerBitrate(peakBitRateCaps?[resolution] ?? resolution.bitrate)
  }

  /// Reads the variants once the player has an item; re-applies the current selection when they
  /// arrive, in case it was picked before loading finished.
  func loadPeakBitRateCapsIfNeeded() {
    guard peakBitRateCaps == nil, capsLoadTask == nil, availableResolutions.count > 1,
          let asset = player.currentItem?.asset as? AVURLAsset else { return }
    capsLoadTask = Task { @MainActor [weak self] in
      let peaks = await Self.variantPeakBitRates(of: asset)
      guard let self, !Task.isCancelled else { return }
      self.capsLoadTask = nil
      guard let caps = Video.Resolution.peakBitRateCaps(for: self.availableResolutions, variantPeakBitRates: peaks) else {
        return
      }
      self.peakBitRateCaps = caps
      if self.resolution != .auto { self.applyCap() }
    }
  }

  static func variantPeakBitRates(of asset: AVURLAsset) async -> [Double] {
    let variants: [AVAssetVariant]
    if #available(iOS 16.0, macOS 13.0, *) {
      variants = (try? await asset.load(.variants)) ?? []
    } else {
      await withCheckedContinuation { continuation in
        asset.loadValuesAsynchronously(forKeys: ["variants"]) { continuation.resume() }
      }
      variants = asset.variants
    }
    // Audio-only variants aren't quality levels.
    return variants.filter { $0.videoAttributes != nil }.compactMap(\.peakBitRate)
  }
}
