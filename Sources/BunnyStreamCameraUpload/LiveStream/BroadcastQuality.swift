import AVFoundation
import CoreGraphics

/// Encoder configuration for the live broadcast: output resolution, frame rate and bitrates.
///
/// The broadcaster streams in portrait orientation, so `Resolution` sizes use the short side as
/// the width (e.g. 1080p is `1080 × 1920`). HaishinKit rotates the encoded frame to match the
/// device orientation at capture time.
///
/// Use one of the presets (`.sd480`, `.hd720`, `.fullHd1080`, `.fullHd1080p60`) or build a custom
/// value. Pass it to `BunnyStreamCameraUploadView`:
/// ```swift
/// BunnyStreamCameraUploadView(
///   accessKey: "<access_key>",
///   libraryId: <library_id>,
///   quality: .fullHd1080
/// )
/// ```
public struct BroadcastQuality: Equatable, Sendable {
  /// Output resolution of the encoded video.
  public enum Resolution: Equatable, Sendable {
    case sd480
    case hd720
    case fullHd1080
    /// A custom portrait output size, in pixels (`width` = short side, `height` = long side).
    case custom(width: Int, height: Int)

    /// Portrait-oriented encoder output size (short side = width).
    var videoSize: CGSize {
      switch self {
      case .sd480: return CGSize(width: 480, height: 854)
      case .hd720: return CGSize(width: 720, height: 1280)
      case .fullHd1080: return CGSize(width: 1080, height: 1920)
      case let .custom(width, height): return CGSize(width: width, height: height)
      }
    }

    /// Capture session preset large enough to feed the encoder without upscaling.
    var sessionPreset: AVCaptureSession.Preset {
      switch self {
      case .sd480, .hd720: return .hd1280x720
      case .fullHd1080: return .hd1920x1080
      case let .custom(width, height):
        let longSide = max(width, height)
        if longSide > 1280 { return .hd1920x1080 }
        if longSide > 640 { return .hd1280x720 }
        return .vga640x480
      }
    }
  }

  /// Output resolution of the encoded video.
  public var resolution: Resolution
  /// Target capture and encode frame rate, in frames per second.
  public var frameRate: Double
  /// Target video bitrate, in bits per second.
  public var videoBitrate: Int
  /// Target audio bitrate, in bits per second.
  public var audioBitrate: Int

  /// Creates a broadcast quality configuration.
  /// - Parameters:
  ///   - resolution: Output resolution of the encoded video.
  ///   - frameRate: Target frame rate in fps.
  ///   - videoBitrate: Target video bitrate in bits per second.
  ///   - audioBitrate: Target audio bitrate in bits per second. Defaults to 128 kbps.
  public init(
    resolution: Resolution,
    frameRate: Double,
    videoBitrate: Int,
    audioBitrate: Int = 128_000
  ) {
    self.resolution = resolution
    self.frameRate = frameRate
    self.videoBitrate = videoBitrate
    self.audioBitrate = audioBitrate
  }
}

public extension BroadcastQuality {
  /// 480p, 30 fps, ~1.2 Mbps. Lowest bandwidth preset.
  static let sd480 = BroadcastQuality(
    resolution: .sd480, frameRate: 30, videoBitrate: 1_200_000, audioBitrate: 128_000
  )

  /// 720p, 30 fps, ~2.5 Mbps.
  static let hd720 = BroadcastQuality(
    resolution: .hd720, frameRate: 30, videoBitrate: 2_500_000, audioBitrate: 128_000
  )

  /// 1080p, 30 fps, ~4.5 Mbps.
  static let fullHd1080 = BroadcastQuality(
    resolution: .fullHd1080, frameRate: 30, videoBitrate: 4_500_000, audioBitrate: 128_000
  )

  /// 1080p, 60 fps, ~6 Mbps. Smoothest motion; requires a capable device and uplink.
  static let fullHd1080p60 = BroadcastQuality(
    resolution: .fullHd1080, frameRate: 60, videoBitrate: 6_000_000, audioBitrate: 128_000
  )

  /// Quality used by the broadcaster when the integrator doesn't specify one.
  static let `default` = fullHd1080
}
