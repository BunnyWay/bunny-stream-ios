# Bunny Stream iOS

<p align="center">
  <img src="Resources/Images/bunnynet.svg" width="70%" alt="BunnyNet" />
</p>
<p align="center">
    <a href="https://www.swift.org" alt="Swift">
        <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" />
    </a>
    <a href="./LICENSE" alt="License">
        <img src="https://img.shields.io/badge/Licence-MIT-green.svg" />
    </a>
    <a href="https://github.com/BunnyWay/bunny-stream-ios/actions/workflows/BuildAndTest.yml" alt="Tests Status">
        <img src="https://github.com/BunnyWay/bunny-stream-ios/actions/workflows/BuildAndTest.yml/badge.svg" />
    </a>
</p>

## What is Bunny Stream?

Bunny Stream is a comprehensive Swift Package Manager (SPM) package designed to seamlessly integrate Bunny's powerful video streaming capabilities into your iOS applications. The package provides a robust set of tools for video management, playback, uploading, and camera-based video uploads, all through an intuitive Swift API.

### Key Features

- **Complete API Integration**: Full support for Bunny REST Stream API
- **Efficient Video Upload**: TUS protocol implementation for reliable, resumable uploads
- **Advanced Video Player**: Custom-built player with full Bunny CDN integration
- **Camera Upload Support**: Built-in capabilities for recording and uploading videos directly from device camera
- **Type-Safe API**: Fully typed Swift API for compile-time safety
- **Background Processing**: Support for background uploads and downloads
- **Comprehensive Error Handling**: Detailed error information and recovery options

## Packages

The Bunny Stream package is organized into several specialized packages, each focusing on specific functionality:

| Package | Description |
|---------|-------------|
| **[BunnyStreamAPI](Documentation/Reference/BunnyStreamAPI)** | The core package that provides a comprehensive Swift interface to Bunny's REST Stream API. It handles all API communication, request authentication, and response parsing, allowing you to easily manage your video content, retrieve analytics, and control CDN settings. Features include video management, collection organization, and thumbnail generation. |
| **[BunnyStreamUploader](Documentation/Reference/BunnyStreamUploader)** | A sophisticated video upload solution built on the TUS (Tus Upload Server) protocol. This package ensures reliable file uploads even in challenging network conditions, with support for pause/resume functionality, upload progress tracking, and background upload capabilities. It handles chunked uploads, automatic retries, and provides detailed upload status information. |
| **[BunnyStreamPlayer](Documentation/Reference/BunnyStreamPlayer)** | A feature-rich video player specifically optimized for Bunny's CDN. It provides smooth playback with adaptive bitrate streaming, customizable controls, support for multiple video formats, and integration with Bunny's analytics. The player includes features like airplay support and customizable UI elements. |
| **[BunnyStreamCameraUpload](Documentation/Reference/BunnyStreamCameraUpload)** | A comprehensive camera integration solution that enables recording and direct upload of videos from the device camera. It provides easy-to-use APIs for managing video recording, camera controls, and seamless upload integration. |

## System Requirements

### Supported Platforms

- iOS 15.0 or later
- macOS 13.0
- Xcode 13.0 or later

## Installation

Bunny Stream can be integrated into your project using Swift Package Manager (SPM). Here's how to add it to your project:

### Swift Package Manager

1. In Xcode, select File > Swift Packages > Add Package Dependency
2. Enter the package repository URL:
   
   ```
   https://github.com/BunnyWay/bunny-stream-ios.git
   ```
3. Select the version you want to use:
   
   ```swift
   dependencies: [
    .package(url: "https://github.com/BunnyWay/bunny-stream-ios.git", .upToNextMajor(from: "1.0.0"))
   ]
   ```

### Required Permissions

Add the following entries to your Info.plist file:

```xml
<!-- For video upload and download -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- For camera upload -->
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

### Initialization

After installation, you'll need to configure the package with your Bunny credentials:

```swift
import BunnyStreamAPI

// Initialize with your access key
let BunnyStreamAPI = BunnyStreamAPI(accessKey: "your_access_key")
```

## Getting Started

### 1. BunnyStreamAPI - Video Management

```swift
import BunnyStreamAPI

// Initialization
let bunnyStreamAPI = BunnyStreamAPI(accessKey: "your_access_key")

// Example: Get video details
let videoInfo = try await bunnyStreamAPI.client.getVideo(
    path: .init(
        libraryId: 12345,
        videoId: "abcd-e9bb-4b96-wxyz-c17bc6a5292b"
    )
)
```

### 2. BunnyStreamUploader - File Upload

```swift
import BunnyStreamUploader

// Create uploader instance
let videoUploader = TUSVideoUploader.make(accessKey: "your_access_key")

// Prepare video info
VideoInfo(content: .data(video.data),
                     title: video.name,
                     fileType: video.type,
                     videoId: videoId,
                     libraryId: libraryId)

// Start upload with progress tracking
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

#### Pause, Resume, and Remove Uploads

For these actions, you'll be using methods from the `VideoUploaderActions` protocol.

This ensures that when the background upload completes, or if there's an error, the `completionHandler` will be called. This will allow the app to update its UI or notify the user, among other possible actions.

In summary, the `TUSVideoUploader` provides an all-in-one solution for robust video uploading, supporting features like pausing, resuming, canceling, and background uploads.

```swift
do {
    try videoUploader.pauseUpload(for: specificUploadInfo)
    try videoUploader.resumeUpload(for: specificUploadInfo)
    try videoUploader.removeUpload(for: specificUploadInfo)
} catch {
    print("Error performing action: \(error)")
}
```

#### Background Mode

When the app goes into the background, especially during an upload, iOS might suspend it after a while. However, with background URL sessions, uploads can continue even when the app is in the background.

In your AppDelegate , when the `handleEventsForBackgroundURLSession` method is triggered, you can hand over the background session handling to the `videoUploader`.

```swift
func application(_ application: UIApplication,
                 handleEventsForBackgroundURLSession identifier: String,
                 completionHandler: @escaping () -> Void) {
    videoUploader.registerBackgroundHandler(completionHandler, forSession: identifier)
}
```

### 3. BunnyStreamPlayer - Video Playback

```swift
import BunnyStreamPlayer

BunnyStreamPlayer(
  accessKey: accessKey,
  videoId: videoId,
  libraryId: libraryId,
  cdn: cdnHostname
)
```

**Customizing Player:**

You can customize the BunnyStreamPlayer by passing custom icons. Other costumizations like primary color, font, handling control visibilty, captions, heatmap can be controlled from the Bunny dashboard.

```swift
extension BunnyStreamPlayer {
  static func make(videoId: String) -> BunnyStreamPlayer {
    let playerIcons = PlayerIcons(play: Image(systemName: "play.fill"))

    return BunnyStreamPlayer(
      accessKey: accessKey,
      videoId: videoId,
      libraryId: libraryId,
      cdn: cdnHostname,
      playerIcons: playerIcons
    )
  }
}

// Example view
struct VideoPlayerDemoView: View {
    var body: some View {
       BunnyStreamPlayer.make(videoId: videoInfo.id)
       .navigationBarTitle(Text("Video Player"), displayMode: .inline)
    }
}
```

### 4. BunnyStreamCameraUpload

```swift
import BunnyStreamCameraUpload

struct VideoStreamDemoView: View {
  @State private var isStreamingPresented = false

  var body: some View {
    Group { }
      .fullScreenCover(isPresented: $isStreamingPresented,
                       content: {
        BunnyStreamCameraUploadView(
          accessKey: "<access_key>",
          libraryId: <library_id>
        )
      })
  }
}
```

## Error Handling

The package provides detailed error information through custom error types:

```swift
do {
    let output = try await bunnyStreamAPI.client.deleteVideo(
        path: .init(
          libraryId: 123,
          videoId: "videoId"
        )
    )
} catch let error as BunnyStreamError {
    switch error {
    case .unauthorized:
        print("Invalid access key")
    case .notFound:
        print("Video not found")
    case .networkError(let underlying):
        print("Network error: \(underlying)")
    case .apiError(let status, let message):
        print("API error (\(status)): \(message)")
    }
}
```

## License

Bunny Stream iOS is licensed under the [MIT License](LICENSE). See the LICENSE file for more details.
