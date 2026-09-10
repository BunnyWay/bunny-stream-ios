# ``BunnyStreamUploader``

Reliable video uploads via TUS or URLSession, with progress tracking and background support.

## Overview

BunnyStreamUploader provides two distinct upload paths. The TUS-based uploader is built for reliability in challenging network conditions, with pause/resume, background uploads, automatic retries, and chunked transfer. The URLSession-based uploader is a lighter alternative for cases where TUS' advanced features aren't required. Both surfaces share progress tracking and detailed upload status.

### Features

- TUS protocol implementation for reliable uploads
- Pause and resume functionality
- Background upload support
- Upload progress tracking
- Automatic retry mechanism
- Chunked upload support
- Detailed upload status information
- Network condition handling

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 13.0+

### Required permissions

```xml
<!-- For video upload and background processing -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

### TUS-based uploader

```swift
import BunnyStreamUploader

let videoUploader = TUSVideoUploader.make(accessKey: "your_access_key")

let videoInfo = VideoInfo(
    content: .data(video.data),
    title: video.name,
    fileType: video.type,
    videoId: videoId,
    libraryId: libraryId
)

Task {
    do {
        try await videoUploader.uploadVideos(with: [videoInfo]) { progress in
            print("Upload progress: \(progress.fractionCompleted)")
        }
        print("Upload completed successfully!")
    } catch {
        print("Upload error: \(error)")
    }
}
```

### URLSession-based uploader

```swift
import BunnyStreamUploader

let uploader = URLSessionVideoUploader.make(accessKey: "your-bunny-cdn-key")

Task {
    do {
        try await uploader.uploadVideos(with: [myVideoInfo])
        print("Upload completed successfully using URLSession!")
    } catch {
        print("Upload error using URLSession: \(error)")
    }
}
```
