# ``BunnyStreamPlayer``

A SwiftUI video player optimized for Bunny's CDN, with adaptive bitrate streaming and customizable UI.

## Overview

BunnyStreamPlayer delivers smooth video playback with adaptive bitrate streaming and a fully customizable interface built with SwiftUI. It integrates directly with Bunny CDN and exposes the controls, fonts, captions, and heatmap settings configured in your Bunny dashboard.

### Features

- Adaptive bitrate streaming
- Custom controls and UI elements
- Multiple video format support
- Multiple audio tracks support
- Bunny CDN integration
- AirPlay support
- Customizable player appearance
- Caption support
- Heatmap integration

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 13.0+

### Customization

The player supports customization via the Bunny dashboard:

- Custom player icons
- Primary color theming
- Font customization
- Control visibility
- Caption settings
- Heatmap visualization

### Usage example

```swift
import BunnyStreamPlayer

BunnyStreamPlayer(
  accessKey: accessKey,
  videoId: videoId,
  libraryId: libraryId,
  cdn: cdnHostname
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
      cdn: cdnHostname,
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
