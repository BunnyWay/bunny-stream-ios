import Combine
import SwiftUI

#if os(iOS)
import AVFoundation
class PermissionsViewModel: ObservableObject {
  @Published private var cameraAccess: AVAuthorizationStatus
  @Published private var microphoneAccess: AVAudioSession.RecordPermission
  
  private var appStateSubscriber: AnyCancellable?
  
  var arePermissionsGranted: Bool {
    cameraAccess == .authorized && microphoneAccess == .granted
  }
  
  var arePermissionsNotDetermined: Bool {
    cameraAccess == .notDetermined || microphoneAccess == .undetermined
  }
  
  init() {
    cameraAccess = AVCaptureDevice.authorizationStatus(for: .video)
    microphoneAccess = AVAudioSession.sharedInstance().recordPermission
    appStateSubscriber = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
      .sink { [weak self] _ in
        self?.updatePermissions()
      }
  }
  
  private func updatePermissions() {
    cameraAccess = AVCaptureDevice.authorizationStatus(for: .video)
    microphoneAccess = AVAudioSession.sharedInstance().recordPermission
  }
}

#elseif os(macOS)
class PermissionsViewModel: ObservableObject {
  var arePermissionsGranted: Bool { false }
  var arePermissionsNotDetermined: Bool { false }
}
#endif
