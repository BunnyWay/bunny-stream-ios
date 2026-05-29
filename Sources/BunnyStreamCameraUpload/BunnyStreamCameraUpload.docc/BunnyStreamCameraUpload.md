# ``BunnyStreamCameraUpload``

Record videos from the device camera and upload them directly to Bunny Stream.

## Overview

BunnyStreamCameraUpload provides a SwiftUI interface for recording and uploading videos straight from the device camera. It wraps camera controls, recording management, and upload integration into a single drop-in view.

### Features

- Direct camera recording
- Video upload integration
- Camera controls
- Recording management
- SwiftUI integration
- Background upload support

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 13.0+

### Required permissions

```xml
<!-- For camera and microphone access -->
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video recording</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video recording</string>

<!-- For background upload support -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

### Usage example

Present `BunnyStreamCameraUploadView` via SwiftUI's full-screen cover:

```swift
import BunnyStreamCameraUpload

struct VideoStreamDemoView: View {
  @State private var isStreamingPresented = false

  var body: some View {
    Group { }
      .fullScreenCover(isPresented: $isStreamingPresented) {
        BunnyStreamCameraUploadView(
          accessKey: "<access_key>",
          libraryId: <library_id>
        )
      }
  }
}
```
