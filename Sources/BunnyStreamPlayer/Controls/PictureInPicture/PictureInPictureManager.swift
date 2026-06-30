import AVKit
import Combine

/// Drives Picture in Picture for the player's `AVPlayerLayer`.
///
/// PiP is only available on iOS/tvOS. On other platforms this manager is an inert no-op so the
/// rest of the player code can reference it unconditionally.
///
/// - Important: For PiP to actually start at runtime the host application must enable the
///   **Audio, AirPlay, and Picture in Picture** background mode in its capabilities
///   (`UIBackgroundModes` containing `audio`). The SDK already configures the audio session
///   for `.playback`, which is the other requirement.
final class PictureInPictureManager: NSObject, ObservableObject {
  /// Whether the current device supports Picture in Picture at all.
  @Published private(set) var isSupported: Bool = false
  /// Whether PiP can currently be started (e.g. the player has loaded playable media).
  @Published private(set) var isPossible: Bool = false
  /// Whether PiP is currently active.
  @Published private(set) var isActive: Bool = false

  #if os(iOS) || os(tvOS)
  private var controller: AVPictureInPictureController?
  private var possibleObservation: NSKeyValueObservation?

  override init() {
    super.init()
    isSupported = AVPictureInPictureController.isPictureInPictureSupported()
  }

  /// Binds the manager to the given player layer. Safe to call repeatedly; it only rebuilds the
  /// underlying controller when the layer actually changes.
  func setup(with playerLayer: AVPlayerLayer) {
    guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
    guard controller?.playerLayer !== playerLayer else { return }

    let controller = AVPictureInPictureController(playerLayer: playerLayer)
    controller?.delegate = self
    self.controller = controller

    possibleObservation = controller?.observe(\.isPictureInPicturePossible, options: [.initial, .new]) { [weak self] controller, _ in
      DispatchQueue.main.async { self?.isPossible = controller.isPictureInPicturePossible }
    }
  }

  /// Starts PiP if inactive, stops it if active.
  func toggle() {
    guard let controller else { return }
    if controller.isPictureInPictureActive {
      controller.stopPictureInPicture()
    } else if controller.isPictureInPicturePossible {
      controller.startPictureInPicture()
    }
  }
  #else
  func setup(with playerLayer: AVPlayerLayer) {}
  func toggle() {}
  #endif
}

#if os(iOS) || os(tvOS)
extension PictureInPictureManager: AVPictureInPictureControllerDelegate {
  func pictureInPictureControllerDidStartPictureInPicture(_ controller: AVPictureInPictureController) {
    isActive = true
  }

  func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
    isActive = false
  }

  func pictureInPictureController(_ controller: AVPictureInPictureController,
                                  failedToStartPictureInPictureWithError error: Error) {
    isActive = false
  }
}
#endif
