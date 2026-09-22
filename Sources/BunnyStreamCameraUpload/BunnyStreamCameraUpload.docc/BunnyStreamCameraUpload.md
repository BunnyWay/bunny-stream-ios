# ``BunnyStreamCameraUpload``

Record videos from the device camera and upload them to Bunny Stream, or broadcast live to a Bunny live stream.

## Overview

BunnyStreamCameraUpload provides a SwiftUI interface for recording and uploading videos straight from the device camera. It wraps camera controls, recording management, and upload integration into a single drop-in view.

The same view broadcasts live when given a live stream: it publishes to that stream's RTMP ingest and starts and stops the stream server-side.

### Features

- Direct camera recording
- Video upload integration
- Live RTMP broadcasting with primary/backup ingest failover
- Encoder quality presets
- Camera controls
- Recording management
- SwiftUI integration
- Background upload support

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+
- A physical device — the simulator has no camera or microphone

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

## Recording and uploading a video

Present ``BunnyStreamCameraUploadView`` via SwiftUI's full-screen cover:

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

## Broadcasting to a live stream

Pass a `BunnyLiveStream` — obtained from `BunnyStreamAPI.liveStreams` — and the view publishes to its RTMP ingest instead of recording a file.

```swift
import BunnyStreamCameraUpload
import BunnyStreamAPI

struct BroadcastView: View {
  let liveStream: BunnyLiveStream

  var body: some View {
    BunnyStreamCameraUploadView(
      liveStream: liveStream,
      accessKey: "<access_key>",
      libraryId: <library_id>,
      quality: .fullHd1080
    )
  }
}
```

### Encoder presets

``BroadcastQuality`` carries the resolution, frame rate and bitrates. Audio is 128 kbps on every preset.

| Preset | Resolution | Frame rate | Video bitrate |
|---|---|---|---|
| ``BroadcastQuality/sd480`` | 480p | 30 fps | ~1.2 Mbps |
| ``BroadcastQuality/hd720`` | 720p | 30 fps | ~2.5 Mbps |
| ``BroadcastQuality/fullHd1080`` | 1080p | 30 fps | ~4.5 Mbps |
| ``BroadcastQuality/fullHd1080p60`` | 1080p | 60 fps | ~6 Mbps |

``BroadcastQuality/default`` is `fullHd1080`. Build a custom one with `BroadcastQuality(resolution:frameRate:videoBitrate:audioBitrate:)`.

### Driving the broadcast from your own UI

Pass a ``BunnyBroadcastController`` to start and stop the broadcast from outside the view and observe what the encoder is doing. The view works without one, using its built-in controls.

```swift
@StateObject private var controller = BunnyBroadcastController()

var body: some View {
  VStack {
    BunnyStreamCameraUploadView(
      liveStream: liveStream,
      accessKey: accessKey,
      libraryId: libraryId,
      controller: controller
    )

    Text(controller.elapsedTime ?? "00:00")

    Button("Go live") { controller.startBroadcast() }
    Button("Stop")    { controller.stopBroadcast() }
    Button("Flip")    { controller.rotateCamera() }
    Button("Mute")    { controller.toggleMute() }
  }
  .onAppear {
    controller.onEvent = { event in print(event) }
  }
}
```

`state`, `elapsedTime`, `isMuted`, `cameraPosition`, `primaryIngestLive` and `backupIngestLive` are all published, so SwiftUI follows them directly. The broadcaster publishes to the primary ingest and fails over to the backup on connection loss; the two `…IngestLive` flags report which one the server currently sees.

## Topics

### Recording and uploading

- ``BunnyStreamCameraUploadView``

### Live broadcasting

- ``BunnyBroadcastController``
- ``BunnyBroadcastState``
- ``BunnyBroadcastEvent``
- ``BunnyCameraPosition``
- ``BroadcastQuality``
