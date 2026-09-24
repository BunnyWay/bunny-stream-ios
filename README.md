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
    <a href="https://bunnyway.github.io/bunny-stream-ios/documentation/" alt="Documentation">
        <img src="https://img.shields.io/badge/Documentation-DocC-blue.svg" />
    </a>
</p>

## What is Bunny Stream?

Bunny Stream is a comprehensive Swift Package Manager (SPM) package designed to seamlessly integrate Bunny's powerful video streaming capabilities into your iOS applications. The package provides a robust set of tools for video management, playback, uploading, live streaming, and camera-based video uploads, all through an intuitive Swift API.

> [!TIP]
> **Using React Native or Expo?** [Bunny Stream React Native](https://github.com/BunnyWay/bunny-stream-react-native) brings
> Bunny Stream to iOS and Android apps with one TypeScript API.

### Key Features

- **Complete API Integration**: Full support for Bunny REST Stream API
- **Efficient Video Upload**: TUS protocol implementation for reliable, resumable uploads
- **Advanced Video Player**: Custom-built player with full Bunny CDN integration
- **Live Streaming**: Play live streams with countdown, pre-stream trailer and DVR, broadcast to them from the device camera over RTMP, and manage them through the Manage Live Streams API — see [Live Streaming](#live-streaming)
- **Camera Upload Support**: Built-in capabilities for recording and uploading videos directly from device camera
- **Picture in Picture**: System PiP for both on-demand and live playback
- **Type-Safe API**: Fully typed Swift API for compile-time safety
- **Background Processing**: Support for background uploads and downloads
- **Localized Player UI**: Player and live-stream overlay strings ship in 31 languages
- **Comprehensive Error Handling**: Detailed error information and recovery options

## Packages

The Bunny Stream package is organized into several specialized packages, each focusing on specific functionality:

| Package | Description |
|---------|-------------|
| **[BunnyStreamAPI](https://bunnyway.github.io/bunny-stream-ios/documentation/bunnystreamapi/)** | The core package that provides a comprehensive Swift interface to Bunny's REST Stream API. It handles all API communication, request authentication, and response parsing, allowing you to easily manage your video content, retrieve analytics, and control CDN settings. Features include video management, collection organization, thumbnail generation, and live stream management through `liveStreams`. |
| **[BunnyStreamUploader](https://bunnyway.github.io/bunny-stream-ios/documentation/bunnystreamuploader/)** | A sophisticated video upload solution built on the TUS (Tus Upload Server) protocol. This package ensures reliable file uploads even in challenging network conditions, with support for pause/resume functionality, upload progress tracking, and background upload capabilities. It handles chunked uploads, automatic retries, and provides detailed upload status information. |
| **[BunnyStreamPlayer](https://bunnyway.github.io/bunny-stream-ios/documentation/bunnystreamplayer/)** | A feature-rich video player specifically optimized for Bunny's CDN. It provides smooth playback with adaptive bitrate streaming, customizable controls, support for multiple video formats, and integration with Bunny's analytics. The player includes features like AirPlay support, Picture in Picture, FairPlay DRM, and customizable UI elements. `BunnyStreamLivePlayer` adds live playback with countdown, pre-stream trailer and DVR. |
| **[BunnyStreamCameraUpload](https://bunnyway.github.io/bunny-stream-ios/documentation/bunnystreamcameraupload/)** | A comprehensive camera integration solution that enables recording and direct upload of videos from the device camera. It provides easy-to-use APIs for managing video recording, camera controls, and seamless upload integration, plus live RTMP broadcasting to a Bunny live stream with primary/backup ingest failover. |

## System Requirements

### Supported Platforms

- iOS 15.0 or later
- macOS 13.0
- Swift 5.9 or later
- Xcode 15.0 or later

Live broadcasting from the device camera requires a physical device — the simulator has no camera or microphone.

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

<!-- For camera upload and live broadcasting -->
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video recording</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video recording</string>

<!-- fetch/processing: background uploads. audio: Picture in Picture and
     background audio playback. Include only the modes you actually use. -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
    <string>audio</string>
</array>
```

> **Picture in Picture** additionally requires the *Audio, AirPlay, and Picture in Picture* background mode to be enabled under **Signing & Capabilities → Background Modes** in your app target. Without it, iOS refuses to start a PiP session.

### Initialization

After installation, you'll need to configure the package with your Bunny credentials:

```swift
import BunnyStreamAPI

// Initialize with your access key
let BunnyStreamAPI = BunnyStreamAPI(accessKey: "your_access_key")
```

## Documentation and Examples

- **API reference** — [generated DocC documentation](https://bunnyway.github.io/bunny-stream-ios/documentation/), published from CI for every package.
- **Example App** — [`Example-App/`](Example-App) is a working SwiftUI integration covering video management, uploads, on-demand playback, live playback, live stream creation and scheduling, and broadcasting from the camera. Open it in Xcode and fill in your own library id and access key.

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
  libraryId: libraryId
)
```

Pass `accessKey: nil` to play public videos without authenticating. When the library enforces token authentication, pass the signed `token` and the `expires` timestamp it was signed with:

```swift
BunnyStreamPlayer(
  accessKey: accessKey,
  videoId: videoId,
  libraryId: libraryId,
  token: signedToken,
  expires: expiresAt
)
```

If the library has **Block direct URL file access** enabled, supply the allowed referrer through `headers`, which are applied to manifest and segment requests:

```swift
BunnyStreamPlayer(
  accessKey: accessKey,
  videoId: videoId,
  libraryId: libraryId,
  headers: ["Referer": "https://your-allowed-domain.example"]
)
```

**Customizing Player:**

You can customize the BunnyStreamPlayer by passing custom icons. Other customizations like primary color, font, handling control visibility, captions, and heatmap can be controlled from the Bunny dashboard.

```swift
extension BunnyStreamPlayer {
  static func make(videoId: String) -> BunnyStreamPlayer {
    let playerIcons = PlayerIcons(play: Image(systemName: "play.fill"))

    return BunnyStreamPlayer(
      accessKey: accessKey,
      videoId: videoId,
      libraryId: libraryId,
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

## Live Streaming

Live streaming spans three packages: `BunnyStreamPlayer` plays a stream, `BunnyStreamCameraUpload` broadcasts to one from the device camera, and `BunnyStreamAPI` manages the stream itself.

### Live Playback

`BunnyStreamLivePlayer` is a self-driving SwiftUI view — give it a stream GUID and it handles the rest:

```swift
import BunnyStreamPlayer

BunnyStreamLivePlayer(
  accessKey: "your_access_key",
  libraryId: 12345,
  streamId: "stream-guid"
)
```

It polls the stream and swaps what is on screen by itself:

- a **countdown** for a scheduled stream that hasn't started,
- a looping, muted **pre-stream trailer** when the stream has one configured,
- **live playback** the moment the stream goes live, with DVR seeking and jump-to-live when the stream has DVR enabled,
- an **offline** state before the start and after the end,
- the **recording** once a finished stream has been converted to a VOD.

For a token-authenticated library, pass the signed token and its expiry. `watermark` renders a client-side watermark over the video — it takes the image's remote URL, and pins it to a corner at a width relative to the player:

```swift
BunnyStreamLivePlayer(
  accessKey: "your_access_key",
  libraryId: 12345,
  streamId: "stream-guid",
  watermark: PlayerWatermark(
    imageURL: URL(string: "https://example.com/logo.png")!,
    position: .topTrailing,   // default
    relativeWidth: 0.18,      // fraction of player width, default
    opacity: 0.85,            // default
    margin: 12                // points from the edges, default
  ),
  token: signedToken,
  expires: expiresAt
)
```

`PlayerWatermark` works the same way on `BunnyStreamPlayer` for on-demand video. A PNG with transparency is recommended.

**Observing the player.** Use `onStateChange` to keep surrounding UI (titles, share buttons, analytics) in step. This observes the player; it does not control it.

`BunnyLiveStreamError` lives in `BunnyStreamAPI`, which is not re-exported — import it explicitly to inspect the error.

```swift
import BunnyStreamPlayer
import BunnyStreamAPI

BunnyStreamLivePlayer(
  accessKey: accessKey,
  libraryId: libraryId,
  streamId: streamId,
  onStateChange: { state in
    switch state {
    case .loading:                          break
    case .playing(let isVodRecording):      print("playing, recording: \(isVodRecording)")
    case .countdown(let until, let title):  print("\(title ?? "Stream") starts at \(until)")
    case .trailer(let vodId, _, _):         print("trailer \(vodId)")
    case .offline(let message):             print("offline: \(message)")
    case .failed(let message):              print("failed: \(message)")
    }
  },
  onPlaybackError: { error in
    // Fires for transient failures the player recovers from on its own, too.
    // Check isPermanent to tell a real dead end from a hiccup.
    if (error as? BunnyLiveStreamError)?.isPermanent == true {
      // Polling has stopped; the player has settled on .failed.
    }
  }
)
```

> When the CDN refuses playback with HTTP 403 — geo-blocking, referrer protection or an expired token — the player shows a generic "Video is not available" with no retry, and reports a permanent `BunnyLiveStreamError`. The cause is deliberately not shown to viewers; diagnose it from your Bunny dashboard logs.

### Broadcasting from the Device Camera

Point `BunnyStreamCameraUploadView` at an existing live stream and it publishes to that stream's RTMP ingest, starting and stopping the stream server-side for you:

```swift
import BunnyStreamCameraUpload
import BunnyStreamAPI   // for BunnyLiveStream

struct BroadcastView: View {
  let liveStream: BunnyLiveStream   // from BunnyStreamAPI.liveStreams

  var body: some View {
    BunnyStreamCameraUploadView(
      liveStream: liveStream,
      accessKey: "your_access_key",
      libraryId: 12345,
      quality: .fullHd1080
    )
  }
}
```

Without a `liveStream`, the same view records and uploads a regular video instead:

```swift
BunnyStreamCameraUploadView(
  accessKey: "your_access_key",
  libraryId: 12345
)
```

**Encoder presets.** `quality` takes a `BroadcastQuality`; the built-in presets are:

| Preset | Resolution | Frame rate | Video bitrate |
|---|---|---|---|
| `.sd480` | 480p | 30 fps | ~1.2 Mbps |
| `.hd720` | 720p | 30 fps | ~2.5 Mbps |
| `.fullHd1080` | 1080p | 30 fps | ~4.5 Mbps |
| `.fullHd1080p60` | 1080p | 60 fps | ~6 Mbps |
| `.default` | same as `.fullHd1080` | | |

Audio is 128 kbps on every preset. Build a custom one with `BroadcastQuality(resolution:frameRate:videoBitrate:audioBitrate:)`.

**Driving the broadcast from your own UI.** Pass a `BunnyBroadcastController` to start and stop the broadcast from outside the view and observe what the encoder is doing. The view works without one, using its built-in controls.

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

    // controller.state, .elapsedTime, .isMuted, .cameraPosition,
    // .primaryIngestLive and .backupIngestLive are all @Published.
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

The broadcaster publishes to the primary ingest and fails over to the backup on connection loss. `primaryIngestLive` and `backupIngestLive` report which one the server currently sees.

> Requires a physical device, plus `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` in your Info.plist — see [Required Permissions](#required-permissions).

### Managing Live Streams

`BunnyStreamAPI.liveStreams` is a `DefaultLiveStreamRepository` over Bunny's Manage Live Streams API. It speaks domain types only, so regenerating the OpenAPI client cannot change this surface.

```swift
import BunnyStreamAPI

let api = BunnyStreamAPI(accessKey: "your_access_key")
let streams = api.liveStreams
```

#### Full API reference

Every method throws `BunnyLiveStreamError`.

| Method | Returns | What it does |
|---|---|---|
| `listLiveStreams(libraryId:page:itemsPerPage:search:orderBy:)` | `BunnyLiveStreamList` | Lists live streams in a library. Pass `nil` for any parameter to accept the server default. |
| `getLiveStream(libraryId:streamId:)` | `BunnyLiveStream` | Fetches a single live stream by its GUID. |
| `createLiveStream(libraryId:request:)` | `BunnyLiveStream` | Creates a live stream. Returns the created stream, so the assigned id and stream key are available without a follow-up fetch. |
| `updateLiveStream(libraryId:streamId:request:)` | `BunnyLiveStream` | Updates a live stream and returns the updated version. |
| `deleteLiveStream(libraryId:streamId:)` | — | Permanently deletes a live stream. Any recorded VOD stays in the library. |
| `startLiveStream(libraryId:streamId:)` | — | Takes the stream live. Call once the encoder is connected and the stream is in `.preview`; it moves to `.running`. |
| `stopLiveStream(libraryId:streamId:)` | — | Stops the stream. The ingest server cuts the publish, and with `recordVod` enabled the stream is converted to a VOD. Cannot be undone. |
| `regenerateStreamKey(libraryId:streamId:)` | `BunnyLiveStream` | Issues a new stream key, invalidating the old one. Rejected once a stream has ended. |
| `fetchPlayData(libraryId:streamId:token:expires:)` | `BunnyLiveStreamPlayData` | Fetches playback data — playlist URL, thumbnails, DRM flag and the dashboard's player theming. `token`/`expires` are forwarded for token-authenticated libraries. |
| `ingestStatus(libraryId:streamId:)` | `BunnyLiveStreamIngestStatus` | Fetches the lightweight ingest status — the endpoint suited to frequent polling. |
| `setThumbnail(libraryId:streamId:thumbnailUrl:)` | — | Sets the offline thumbnail from a remote image URL. |
| `uploadThumbnail(libraryId:streamId:imageData:format:)` | — | Uploads a local image as the offline thumbnail. `format` is a `BunnyImageFormat` (`.jpeg`, `.png`, `.webp`, `.gif`). |
| `listThumbnails(libraryId:streamId:limit:from:to:)` | `[BunnyLiveStreamThumbnail]` | Lists recently captured thumbnails, most recent first. The server defaults to 5; `from`/`to` bound the capture time. |
| `deleteThumbnail(libraryId:streamId:restoreLibraryDefault:)` | — | Removes the custom offline thumbnail. `restoreLibraryDefault` falls back to the library's default live thumbnail instead of leaving the stream with none. |

> **Optional parameters carry defaults on `DefaultLiveStreamRepository`, not on the `LiveStreamRepository` protocol** — a Swift protocol requirement cannot declare them. Calling through the concrete type lets you omit `page`, `token`, `limit` and friends; code written against the protocol (for example, a test double) has to pass every parameter explicitly.

#### A typical flow

```swift
// 1. Create a stream, scheduled for later, recording to a VOD when it ends.
let created = try await streams.createLiveStream(
  libraryId: libraryId,
  request: BunnyLiveStreamCreateRequest(
    title: "Launch event",
    scheduledStartTime: startDate,
    dvrEnabled: true,
    recordVod: true,
    enableCountdown: true
  )
)

guard let streamId = created.id else { return }

// 2. Point your encoder at it — or hand `created` to BunnyStreamCameraUploadView
//    to broadcast from the device.
print(created.primaryIngestUrl ?? "", created.streamKey ?? "")

// 3. Wait until the ingest server sees the encoder, then go live.
let status = try await streams.ingestStatus(libraryId: libraryId, streamId: streamId)
if status.readyToStart {
  try await streams.startLiveStream(libraryId: libraryId, streamId: streamId)
}

// 4. End it. With recordVod enabled, the stream becomes a VOD.
try await streams.stopLiveStream(libraryId: libraryId, streamId: streamId)
```

Model fields such as `id`, `streamKey` and `primaryIngestUrl` are optional, because the API does not guarantee them on every response shape.

#### Stream status

`BunnyLiveStream.status` is a `BunnyLiveStreamStatus`:

| Case | Raw | Meaning |
|---|---|---|
| `.unknown` | 0 | Status not recognised. |
| `.created` | 1 | Created, not scheduled and not started. |
| `.scheduled` | 2 | Has a scheduled start time in the future. |
| `.preview` | 3 | The encoder is connected; the stream is not yet public. |
| `.running` | 4 | Live. |
| `.ended` | 5 | Finished. |
| `.vodProcessing` | 6 | Being converted to a recording. |
| `.error` | 7 | The stream failed. |

## Error Handling

Failures are reported differently depending on which part of the SDK you are calling.

### REST calls through `BunnyStreamAPI.client`

The generated OpenAPI client does not throw on HTTP errors — it returns them as cases of a typed `Output` enum, so the compiler makes you handle each documented status. It throws only when no response could be read at all (no connectivity, cancellation, a body that doesn't match the schema).

```swift
do {
    let output = try await bunnyStreamAPI.client.getVideo(
        path: .init(libraryId: 123, videoId: "videoId")
    )
    switch output {
    case .ok(let response):
        let video = try response.body.json
        print(video.title ?? "")
    case .unauthorized:
        print("Invalid access key")
    case .notFound:
        print("Video not found")
    case .internalServerError:
        print("Server error")
    case .undocumented(let statusCode, _):
        print("Unexpected status: \(statusCode)")
    }
} catch {
    // Transport or decoding failure — the request never produced a usable response.
    print("Request failed: \(error)")
}
```

### Live stream management

Every `BunnyStreamAPI.liveStreams` method throws a single type, `BunnyLiveStreamError`, which keeps the HTTP status code. Use `isPermanent` to decide whether retrying is worth it — it mirrors the web player's polling rules, so a poll loop can branch on it instead of matching on status codes.

```swift
do {
    let stream = try await bunnyStreamAPI.liveStreams.getLiveStream(
        libraryId: 123,
        streamId: "stream-guid"
    )
    print(stream.status)
} catch let error as BunnyLiveStreamError {
    switch error.kind {
    case .unauthorized:    print("Invalid access key, or no permission")
    case .notFound:        print("No such library or stream")
    case .invalidRequest:  print("Rejected as invalid (400)")
    case .unprocessable:   print("Understood but not actionable (422)")
    case .server:          print("Server failed (5xx)")
    case .transport:       print("Never reached the server")
    case .invalidResponse: print("Response did not match the schema")
    case .unexpected:      print("Other status: \(error.statusCode ?? -1)")
    }

    if !error.isPermanent {
        // 5xx and transport failures are worth another attempt.
    }
}
```

`BunnyLiveStreamError` conforms to `LocalizedError`, so `error.localizedDescription` gives a usable message — the server's own text when there is one, otherwise a description of the kind with the status code appended.

### Uploads

`TUSVideoUploader` throws `VideoUploaderError`:

```swift
do {
    try await videoUploader.uploadVideos(with: [videoInfo]) { progress in
        print("Upload progress: \(progress.fractionCompleted)")
    }
} catch let error as VideoUploaderError {
    switch error {
    case .failedToCreateVideoWithReason(let message):
        print("Could not create the video: \(message)")
    case .failedToCreateVideo, .failedToUploadVideo:
        print(error.localizedDescription)
    case .failedToCreateRequest, .failedToCreateUploadTask:
        print("Could not start the upload")
    case .invalidVideoUUID:
        print("Invalid video id")
    }
}
```

### Playback

Playback failures are surfaced on screen by the player itself. `BunnyStreamLivePlayer` additionally reports them through `onPlaybackError` — see [Live Playback](#live-playback).

When the CDN answers a playback request with HTTP 403 — geo-blocking, referrer protection, or an expired or invalid token — the player shows a generic "Video is not available" and offers no retry, because retrying cannot help. The three causes are deliberately not told apart in the UI; identify which one applies from your Bunny dashboard logs.

## Troubleshooting

### Build Plugin Validation Error

If you encounter an error related to the OpenAPI Generator plugin when building the project (either in Xcode or from the command line), this is because Swift build plugins require explicit trust before first use. Here's how to fix it:

**For Xcode Users:**
1. Open the project in Xcode
2. Try to build the project (⌘+B)
3. You'll see a dialog asking you to trust the "OpenAPIGenerator" plugin
4. Click "Trust & Enable" to allow the plugin to run
5. Build again - it should now work

**For Command Line Builds:**

Run this command before building:
```bash
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
```

Then build with the skip validation flag:
```bash
xcodebuild build -scheme Bunny-Package \
  -destination 'generic/platform=iOS Simulator' \
  -skipPackagePluginValidation
```

### `swift build` fails on the Google IMA framework

Building from the command line with plain `swift build` targets macOS, and the Google Interactive Media Ads dependency ships an iOS-only `.xcframework`:

```
error: ... GoogleInteractiveMediaAds.xcframework While building for macOS,
no library for this platform was found
```

This is expected — build against an iOS destination with `xcodebuild` instead, as shown above and as the [CI workflows](.github/workflows/BuildAndTest.yml) do.

**For CI/CD Environments:**

Add the `-skipPackagePluginValidation` flag to your build commands. See our [GitHub Actions workflows](.github/workflows/BuildAndTest.yml) for reference implementation.

This is a security feature in Xcode that requires manual approval for build plugins. Once trusted locally, you won't see this error again on your machine.

## License

Bunny Stream iOS is licensed under the [MIT License](LICENSE). See the LICENSE file for more details.
