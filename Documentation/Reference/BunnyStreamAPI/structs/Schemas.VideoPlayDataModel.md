**STRUCT**

# `Schemas.VideoPlayDataModel`

```swift
public struct VideoPlayDataModel: Codable, Hashable, Sendable
```

Contains all necessary playback information for a video, including various URLs and player configurations.

## Properties
### `video`

```swift
public var video: Components.Schemas.VideoPlayDataModel.VideoPayload?
```

The video data model.

### `captionsPath`

```swift
public var captionsPath: Swift.String?
```

The path where caption files are stored.

### `seekPath`

```swift
public var seekPath: Swift.String?
```

The URL to be used for seeking within the video.

### `thumbnailUrl`

```swift
public var thumbnailUrl: Swift.String?
```

The URL of the video's thumbnail.

### `fallbackUrl`

```swift
public var fallbackUrl: Swift.String?
```

The fallback URL for the video.

### `videoPlaylistUrl`

```swift
public var videoPlaylistUrl: Swift.String?
```

The URL of the video playlist.

### `originalUrl`

```swift
public var originalUrl: Swift.String?
```

The URL of the original video file.

### `previewUrl`

```swift
public var previewUrl: Swift.String?
```

The URL of the video preview.

### `controls`

```swift
public var controls: Swift.String?
```

Player control settings.

### `enableDRM`

```swift
public var enableDRM: Swift.Bool?
```

Indicates if DRM is enabled for the video.

### `drmVersion`

```swift
public var drmVersion: Swift.Int32?
```

The version number of DRM used.

### `playerKeyColor`

```swift
public var playerKeyColor: Swift.String?
```

The primary color used for the video player interface.

### `vastTagUrl`

```swift
public var vastTagUrl: Swift.String?
```

The VAST tag URL for video ads.

### `captionsFontSize`

```swift
public var captionsFontSize: Swift.Int32?
```

Font size for captions in the video player.

### `captionsFontColor`

```swift
public var captionsFontColor: Swift.String?
```

Font color for captions in the video player.

### `captionsBackground`

```swift
public var captionsBackground: Swift.String?
```

Background color for captions.

### `uiLanguage`

```swift
public var uiLanguage: Swift.String?
```

The language used for the player UI.

### `allowEarlyPlay`

```swift
public var allowEarlyPlay: Swift.Bool?
```

Indicates if early playback is allowed.

### `tokenAuthEnabled`

```swift
public var tokenAuthEnabled: Swift.Bool?
```

Indicates if token-based authentication is enabled for playback.

### `enableMP4Fallback`

```swift
public var enableMP4Fallback: Swift.Bool?
```

Indicates if MP4 fallback files should be used.

### `showHeatmap`

```swift
public var showHeatmap: Swift.Bool?
```

Indicates if the heatmap should be displayed on the player.

### `fontFamily`

```swift
public var fontFamily: Swift.String?
```

The font family used for captions.

### `playbackSpeeds`

```swift
public var playbackSpeeds: Swift.String?
```

Available playback speed options for the video.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(video:captionsPath:seekPath:thumbnailUrl:fallbackUrl:videoPlaylistUrl:originalUrl:previewUrl:controls:enableDRM:drmVersion:playerKeyColor:vastTagUrl:captionsFontSize:captionsFontColor:captionsBackground:uiLanguage:allowEarlyPlay:tokenAuthEnabled:enableMP4Fallback:showHeatmap:fontFamily:playbackSpeeds:additionalProperties:)`

```swift
public init(
    video: Components.Schemas.VideoPlayDataModel.VideoPayload? = nil,
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
    playbackSpeeds: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
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
  - additionalProperties: A container of undocumented properties.

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
| additionalProperties | A container of undocumented properties. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |

### `encode(to:)`

```swift
public func encode(to encoder: any Encoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| encoder | The encoder to write data to. |