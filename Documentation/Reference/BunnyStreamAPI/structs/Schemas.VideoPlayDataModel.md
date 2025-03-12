**STRUCT**

# `Schemas.VideoPlayDataModel`

```swift
public struct VideoPlayDataModel: Codable, Hashable, Sendable
```

Contains all necessary playback information for a video, including various URLs and player configurations.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel`.

## Properties
### `video`

```swift
public var video: Components.Schemas.VideoPlayDataModel.videoPayload?
```

The video data model.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/video`.

### `captionsPath`

```swift
public var captionsPath: Swift.String?
```

The path where caption files are stored.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/captionsPath`.

### `seekPath`

```swift
public var seekPath: Swift.String?
```

The URL to be used for seeking within the video.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/seekPath`.

### `thumbnailUrl`

```swift
public var thumbnailUrl: Swift.String?
```

The URL of the video's thumbnail.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/thumbnailUrl`.

### `fallbackUrl`

```swift
public var fallbackUrl: Swift.String?
```

The fallback URL for the video.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/fallbackUrl`.

### `videoPlaylistUrl`

```swift
public var videoPlaylistUrl: Swift.String?
```

The URL of the video playlist.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/videoPlaylistUrl`.

### `originalUrl`

```swift
public var originalUrl: Swift.String?
```

The URL of the original video file.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/originalUrl`.

### `previewUrl`

```swift
public var previewUrl: Swift.String?
```

The URL of the video preview.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/previewUrl`.

### `controls`

```swift
public var controls: Swift.String?
```

Player control settings.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/controls`.

### `enableDRM`

```swift
public var enableDRM: Swift.Bool?
```

Indicates if DRM is enabled for the video.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/enableDRM`.

### `drmVersion`

```swift
public var drmVersion: Swift.Int32?
```

The version number of DRM used.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/drmVersion`.

### `playerKeyColor`

```swift
public var playerKeyColor: Swift.String?
```

The primary color used for the video player interface.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/playerKeyColor`.

### `vastTagUrl`

```swift
public var vastTagUrl: Swift.String?
```

The VAST tag URL for video ads.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/vastTagUrl`.

### `captionsFontSize`

```swift
public var captionsFontSize: Swift.Int32?
```

Font size for captions in the video player.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/captionsFontSize`.

### `captionsFontColor`

```swift
public var captionsFontColor: Swift.String?
```

Font color for captions in the video player.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/captionsFontColor`.

### `captionsBackground`

```swift
public var captionsBackground: Swift.String?
```

Background color for captions.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/captionsBackground`.

### `uiLanguage`

```swift
public var uiLanguage: Swift.String?
```

The language used for the player UI.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/uiLanguage`.

### `allowEarlyPlay`

```swift
public var allowEarlyPlay: Swift.Bool?
```

Indicates if early playback is allowed.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/allowEarlyPlay`.

### `tokenAuthEnabled`

```swift
public var tokenAuthEnabled: Swift.Bool?
```

Indicates if token-based authentication is enabled for playback.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/tokenAuthEnabled`.

### `enableMP4Fallback`

```swift
public var enableMP4Fallback: Swift.Bool?
```

Indicates if MP4 fallback files should be used.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/enableMP4Fallback`.

### `showHeatmap`

```swift
public var showHeatmap: Swift.Bool?
```

Indicates if the heatmap should be displayed on the player.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/showHeatmap`.

### `fontFamily`

```swift
public var fontFamily: Swift.String?
```

The font family used for captions.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/fontFamily`.

### `playbackSpeeds`

```swift
public var playbackSpeeds: Swift.String?
```

Available playback speed options for the video.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/playbackSpeeds`.

## Methods
### `init(video:captionsPath:seekPath:thumbnailUrl:fallbackUrl:videoPlaylistUrl:originalUrl:previewUrl:controls:enableDRM:drmVersion:playerKeyColor:vastTagUrl:captionsFontSize:captionsFontColor:captionsBackground:uiLanguage:allowEarlyPlay:tokenAuthEnabled:enableMP4Fallback:showHeatmap:fontFamily:playbackSpeeds:)`

```swift
public init(
    video: Components.Schemas.VideoPlayDataModel.videoPayload? = nil,
    captionsPath: Swift.String? = nil,
    seekPath: Swift.String? = nil,
    thumbnailUrl: Swift.String? = nil,
    fallbackUrl: Swift.String? = nil,
    videoPlaylistUrl: Swift.String? = nil,
    originalUrl: Swift.String? = nil,
    previewUrl: Swift.String? = nil,
    controls: Swift.String? = nil,
    enableDRM: Swift.Bool? = nil,
    drmVersion: Swift.Int32? = nil,
    playerKeyColor: Swift.String? = nil,
    vastTagUrl: Swift.String? = nil,
    captionsFontSize: Swift.Int32? = nil,
    captionsFontColor: Swift.String? = nil,
    captionsBackground: Swift.String? = nil,
    uiLanguage: Swift.String? = nil,
    allowEarlyPlay: Swift.Bool? = nil,
    tokenAuthEnabled: Swift.Bool? = nil,
    enableMP4Fallback: Swift.Bool? = nil,
    showHeatmap: Swift.Bool? = nil,
    fontFamily: Swift.String? = nil,
    playbackSpeeds: Swift.String? = nil
)
```

Creates a new `VideoPlayDataModel`.

- Parameters:
  - video: The video data model.
  - captionsPath: The path where caption files are stored.
  - seekPath: The URL to be used for seeking within the video.
  - thumbnailUrl: The URL of the video's thumbnail.
  - fallbackUrl: The fallback URL for the video.
  - videoPlaylistUrl: The URL of the video playlist.
  - originalUrl: The URL of the original video file.
  - previewUrl: The URL of the video preview.
  - controls: Player control settings.
  - enableDRM: Indicates if DRM is enabled for the video.
  - drmVersion: The version number of DRM used.
  - playerKeyColor: The primary color used for the video player interface.
  - vastTagUrl: The VAST tag URL for video ads.
  - captionsFontSize: Font size for captions in the video player.
  - captionsFontColor: Font color for captions in the video player.
  - captionsBackground: Background color for captions.
  - uiLanguage: The language used for the player UI.
  - allowEarlyPlay: Indicates if early playback is allowed.
  - tokenAuthEnabled: Indicates if token-based authentication is enabled for playback.
  - enableMP4Fallback: Indicates if MP4 fallback files should be used.
  - showHeatmap: Indicates if the heatmap should be displayed on the player.
  - fontFamily: The font family used for captions.
  - playbackSpeeds: Available playback speed options for the video.

#### Parameters

| Name | Description |
| ---- | ----------- |
| video | The video data model. |
| captionsPath | The path where caption files are stored. |
| seekPath | The URL to be used for seeking within the video. |
| thumbnailUrl | The URL of the video’s thumbnail. |
| fallbackUrl | The fallback URL for the video. |
| videoPlaylistUrl | The URL of the video playlist. |
| originalUrl | The URL of the original video file. |
| previewUrl | The URL of the video preview. |
| controls | Player control settings. |
| enableDRM | Indicates if DRM is enabled for the video. |
| drmVersion | The version number of DRM used. |
| playerKeyColor | The primary color used for the video player interface. |
| vastTagUrl | The VAST tag URL for video ads. |
| captionsFontSize | Font size for captions in the video player. |
| captionsFontColor | Font color for captions in the video player. |
| captionsBackground | Background color for captions. |
| uiLanguage | The language used for the player UI. |
| allowEarlyPlay | Indicates if early playback is allowed. |
| tokenAuthEnabled | Indicates if token-based authentication is enabled for playback. |
| enableMP4Fallback | Indicates if MP4 fallback files should be used. |
| showHeatmap | Indicates if the heatmap should be displayed on the player. |
| fontFamily | The font family used for captions. |
| playbackSpeeds | Available playback speed options for the video. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |