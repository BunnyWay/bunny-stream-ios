import SwiftUI
import Kingfisher

/// A logo/watermark overlaid on top of the video while it plays.
///
/// Bunny's live API does not return watermark metadata to the player (the watermark is burned into
/// the encoded stream when configured in the library encoder settings). This type lets an
/// integrator render an additional client-side watermark on top of any `BunnyStreamPlayer` or
/// `BunnyStreamLivePlayer`.
public struct PlayerWatermark: Equatable {
  /// The corner (or center) the watermark is pinned to.
  public enum Position: Equatable {
    case topLeading, topTrailing, bottomLeading, bottomTrailing, center

    var alignment: Alignment {
      switch self {
      case .topLeading:     return .topLeading
      case .topTrailing:    return .topTrailing
      case .bottomLeading:  return .bottomLeading
      case .bottomTrailing: return .bottomTrailing
      case .center:         return .center
      }
    }
  }

  /// Remote URL of the watermark image (PNG with transparency recommended).
  public var imageURL: URL
  /// Where the watermark sits within the player bounds.
  public var position: Position
  /// Watermark width as a fraction of the player width (`0...1`).
  public var relativeWidth: CGFloat
  /// Opacity of the watermark (`0...1`).
  public var opacity: Double
  /// Inset from the player edges, in points.
  public var margin: CGFloat

  /// - Parameters:
  ///   - imageURL: Remote URL of the watermark image.
  ///   - position: Corner (or center) to pin the watermark to. Defaults to `.topTrailing`.
  ///   - relativeWidth: Width as a fraction of the player width. Defaults to `0.18`.
  ///   - opacity: Opacity of the watermark. Defaults to `0.85`.
  ///   - margin: Inset from the player edges in points. Defaults to `12`.
  public init(
    imageURL: URL,
    position: Position = .topTrailing,
    relativeWidth: CGFloat = 0.18,
    opacity: Double = 0.85,
    margin: CGFloat = 12
  ) {
    self.imageURL = imageURL
    self.position = position
    self.relativeWidth = max(0, min(1, relativeWidth))
    self.opacity = max(0, min(1, opacity))
    self.margin = margin
  }
}

// MARK: - Environment plumbing

private struct PlayerWatermarkKey: EnvironmentKey {
  static let defaultValue: PlayerWatermark? = nil
}

extension EnvironmentValues {
  var playerWatermark: PlayerWatermark? {
    get { self[PlayerWatermarkKey.self] }
    set { self[PlayerWatermarkKey.self] = newValue }
  }
}

// MARK: - Rendering

/// Renders a `PlayerWatermark` sized relative to the available player bounds.
struct WatermarkOverlayView: View {
  let watermark: PlayerWatermark

  var body: some View {
    GeometryReader { geometry in
      KFImage.url(watermark.imageURL)
        .requestModifier(BunnyCDN.refererModifier)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: max(1, geometry.size.width * watermark.relativeWidth))
        .opacity(watermark.opacity)
        .padding(watermark.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: watermark.position.alignment)
    }
    .allowsHitTesting(false)
  }
}
