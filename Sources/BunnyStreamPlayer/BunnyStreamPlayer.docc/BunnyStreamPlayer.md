# ``BunnyStreamPlayer``

A SwiftUI video player optimized for Bunny's CDN, with adaptive bitrate streaming, live playback, and a customizable UI.

## Overview

BunnyStreamPlayer delivers smooth video playback with adaptive bitrate streaming and a fully customizable interface built with SwiftUI. It integrates directly with Bunny CDN and exposes the controls, fonts, captions, and heatmap settings configured in your Bunny dashboard.

``BunnyStreamPlayer`` plays on-demand video. ``BunnyStreamLivePlayer`` plays live streams and drives itself — countdown, pre-stream trailer, live edge, DVR, and the recording afterwards.

### Features

- Adaptive bitrate streaming
- Live stream playback with countdown, pre-stream trailer, and DVR
- Custom controls and UI elements
- Multiple video format support
- Multiple audio tracks support
- Bunny CDN integration
- AirPlay and Picture in Picture support
- FairPlay DRM
- Client-side watermark
- Customizable player appearance
- Caption support
- Heatmap integration
- Player UI localized into 31 languages

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

### Customization

The player supports customization via the Bunny dashboard:

- Custom player icons
- Primary color theming
- Font customization
- Control visibility
- Caption settings
- Heatmap visualization

## Playing an on-demand video

```swift
import BunnyStreamPlayer

BunnyStreamPlayer(
  accessKey: accessKey,
  videoId: videoId,
  libraryId: libraryId
)
```

Pass `accessKey: nil` to play public videos without authenticating. When the library enforces token authentication, pass the signed `token` and the `expires` timestamp it was signed with. If the library has **Block direct URL file access** enabled, supply the allowed referrer through `headers`, which are applied to manifest and segment requests:

```swift
BunnyStreamPlayer(
  accessKey: accessKey,
  videoId: videoId,
  libraryId: libraryId,
  token: signedToken,
  expires: expiresAt,
  headers: ["Referer": "https://your-allowed-domain.example"]
)
```

### Customizing the player

Pass custom icons through ``PlayerIcons``. Primary color, font, control visibility, captions, and heatmap are controlled from the Bunny dashboard.

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

struct VideoPlayerDemoView: View {
    var body: some View {
       BunnyStreamPlayer.make(videoId: videoInfo.id)
         .navigationBarTitle(Text("Video Player"), displayMode: .inline)
    }
}
```

### Adding a watermark

``PlayerWatermark`` renders an image over the video, on both the on-demand and live players. It takes the image's remote URL; a PNG with transparency is recommended.

```swift
BunnyStreamPlayer(
  accessKey: accessKey,
  videoId: videoId,
  libraryId: libraryId,
  watermark: PlayerWatermark(
    imageURL: URL(string: "https://example.com/logo.png")!,
    position: .topTrailing,
    relativeWidth: 0.18,
    opacity: 0.85,
    margin: 12
  )
)
```

## Playing a live stream

``BunnyStreamLivePlayer`` takes a stream GUID and handles the rest. It polls the stream and swaps what is on screen by itself: a countdown for a scheduled stream, a looping muted pre-stream trailer, live playback with DVR seeking and jump-to-live, an offline state before the start and after the end, and the recording once a finished stream is converted to a VOD.

```swift
import BunnyStreamPlayer

BunnyStreamLivePlayer(
  accessKey: accessKey,
  libraryId: libraryId,
  streamId: "stream-guid"
)
```

### Observing the live player

``BunnyLiveStreamPlaybackState`` reports what the player is showing, so surrounding UI — titles, share buttons, analytics — can follow it. It observes the player; it does not control it.

`BunnyLiveStreamError` lives in `BunnyStreamAPI`, which is not re-exported, so import it explicitly to inspect the error.

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
    // Fires for transient failures the player recovers from, too.
    if (error as? BunnyLiveStreamError)?.isPermanent == true {
      // Polling has stopped; the player has settled on .failed.
    }
  }
)
```

## Playback failures

When the CDN refuses playback — geo-blocking, referrer protection, or an expired or invalid token — the player shows a generic "Video is not available" and offers no retry, because retrying cannot help. The causes are deliberately not told apart in the UI; identify which one applies from your Bunny dashboard logs.

A device that cannot reach the CDN gets "No internet connection" instead, and keeps the retry: nothing about that failure is a verdict on the video.

## Topics

### On-demand playback

- ``BunnyStreamPlayer``
- ``PlayerIcons``
- ``PlayerWatermark``

### Live playback

- ``BunnyStreamLivePlayer``
- ``BunnyLiveStreamPlaybackState``
- ``LiveStreamPlayData``
- ``LiveStreamPlayDataLoader``
