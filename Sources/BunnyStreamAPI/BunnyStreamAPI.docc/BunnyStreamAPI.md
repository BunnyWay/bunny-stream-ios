# ``BunnyStreamAPI``

A comprehensive Swift interface to Bunny's REST Stream API.

## Overview

BunnyStreamAPI is the core package of the Bunny Stream iOS SDK. It handles all API communication, request authentication, and response parsing, enabling seamless video content management — including video and collection operations, thumbnail generation, analytics, and CDN settings — through a type-safe Swift surface.

Video and collection operations go through ``BunnyStreamAPI/client``, the generated OpenAPI client. Live streams go through ``BunnyStreamAPI/liveStreams``, which speaks domain types instead, so regenerating the client cannot change that surface.

### Features

- Complete Bunny REST Stream API integration
- Comprehensive video management capabilities
- Collection organization and management
- Live stream management: create, schedule, start, stop, poll, thumbnails
- Thumbnail generation and management
- Analytics and CDN settings control
- Type-safe Swift API interface
- Detailed error handling and recovery options

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

### Installation

```swift
dependencies: [
    .package(url: "https://github.com/BunnyWay/bunny-stream-ios.git", .upToNextMajor(from: "1.0.0"))
]
```

## Managing videos

Initialize the API client and retrieve video details:

```swift
import BunnyStreamAPI

let bunnyStreamAPI = BunnyStreamAPI(accessKey: "your_access_key")

let videoInfo = try await bunnyStreamAPI.client.getVideo(
    path: .init(
        libraryId: 12345,
        videoId: "abcd-e9bb-4b96-wxyz-c17bc6a5292b"
    )
)
```

## Managing live streams

``BunnyStreamAPI/liveStreams`` covers the Manage Live Streams API: list, get, create, update, delete, start, stop, regenerate the stream key, fetch play data, poll ingest status, and manage thumbnails.

```swift
let streams = bunnyStreamAPI.liveStreams

// Create a stream, scheduled for later, recording to a VOD when it ends.
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

// Point an encoder at `created.primaryIngestUrl` with `created.streamKey`,
// then go live once the ingest server sees it.
let status = try await streams.ingestStatus(libraryId: libraryId, streamId: streamId)
if status.readyToStart {
  try await streams.startLiveStream(libraryId: libraryId, streamId: streamId)
}

try await streams.stopLiveStream(libraryId: libraryId, streamId: streamId)
```

> Note: Optional parameters carry defaults on ``DefaultLiveStreamRepository``, not on the ``LiveStreamRepository`` protocol — a Swift protocol requirement cannot declare them. Code written against the protocol, such as a test double, has to pass every parameter explicitly.

## Error handling

The generated client does not throw on HTTP errors. It returns them as cases of a typed `Output` enum, so the compiler makes you handle each documented status, and throws only when no response could be read at all.

```swift
let output = try await bunnyStreamAPI.client.getVideo(
    path: .init(libraryId: 123, videoId: "videoId")
)
switch output {
case .ok(let response):
    print(try response.body.json.title ?? "")
case .unauthorized:
    print("Invalid access key")
case .notFound:
    print("Video not found")
case .internalServerError:
    print("Server error")
case .undocumented(let statusCode, _):
    print("Unexpected status: \(statusCode)")
}
```

Every ``LiveStreamRepository`` method instead throws a single type, ``BunnyLiveStreamError``, which keeps the HTTP status code. Use ``BunnyLiveStreamError/isPermanent`` to decide whether retrying is worth it — it mirrors the web player's polling rules, so a poll loop can branch on it rather than matching status codes.

```swift
do {
    let stream = try await bunnyStreamAPI.liveStreams.getLiveStream(
        libraryId: 123,
        streamId: "stream-guid"
    )
    print(stream.status)
} catch let error as BunnyLiveStreamError {
    if error.isPermanent {
        print("Giving up: \(error.localizedDescription)")
    } else {
        print("Worth another attempt: \(error.localizedDescription)")
    }
}
```

## Topics

### Essentials

- ``BunnyStreamAPI``
- ``SDKInfo``

### Live stream management

- ``LiveStreamRepository``
- ``DefaultLiveStreamRepository``
- ``BunnyLiveStreamCreateRequest``
- ``BunnyLiveStreamUpdateRequest``

### Live stream models

- ``BunnyLiveStream``
- ``BunnyLiveStreamStatus``
- ``BunnyLiveStreamList``
- ``BunnyLiveStreamPlayData``
- ``BunnyLiveStreamIngestStatus``
- ``BunnyLiveStreamThumbnail``
- ``BunnyRtmpOutput``
- ``BunnyImageFormat``

### Errors

- ``BunnyLiveStreamError``
