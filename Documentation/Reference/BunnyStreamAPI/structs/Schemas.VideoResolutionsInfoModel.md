**STRUCT**

# `Schemas.VideoResolutionsInfoModel`

```swift
public struct VideoResolutionsInfoModel: Codable, Hashable, Sendable
```

Represents detailed resolution information for a video, including available, configured, and storage resolutions.

## Properties
### `videoId`

```swift
public var videoId: Swift.String?
```

The unique identifier of the video.

### `videoLibraryId`

```swift
public var videoLibraryId: Swift.Int64?
```

The ID of the video library.

### `availableResolutions`

```swift
public var availableResolutions: [Swift.String]?
```

A list of available resolutions for the video.

### `configuredResolutions`

```swift
public var configuredResolutions: [Swift.String]?
```

A list of resolutions configured for encoding.

### `playlistResolutions`

```swift
public var playlistResolutions: [Components.Schemas.ResolutionReference]?
```

A list of resolutions used in playlists.

### `storageResolutions`

```swift
public var storageResolutions: [Components.Schemas.ResolutionReference]?
```

A list of resolutions stored on the server.

### `mp4Resolutions`

```swift
public var mp4Resolutions: [Components.Schemas.ResolutionReference]?
```

A list of MP4 fallback resolutions.

### `storageObjects`

```swift
public var storageObjects: [Components.Schemas.StorageObjectModel]?
```

A list of storage objects related to the video resolutions.

### `oldResolutions`

```swift
public var oldResolutions: [Components.Schemas.StorageObjectModel]?
```

A list of previous resolution objects that may be removed.

### `hasBothOldAndNewResolutionFormat`

```swift
public var hasBothOldAndNewResolutionFormat: Swift.Bool?
```

Indicates if both old and new resolution formats are present.

### `hasOriginal`

```swift
public var hasOriginal: Swift.Bool?
```

Indicates if the original video file is available.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(videoId:videoLibraryId:availableResolutions:configuredResolutions:playlistResolutions:storageResolutions:mp4Resolutions:storageObjects:oldResolutions:hasBothOldAndNewResolutionFormat:hasOriginal:additionalProperties:)`

```swift
public init(
    videoId: Swift.String? = nil,
    videoLibraryId: Swift.Int64? = nil,
    availableResolutions: [Swift.String]? = nil,
    configuredResolutions: [Swift.String]? = nil,
    playlistResolutions: [Components.Schemas.ResolutionReference]? = nil,
    storageResolutions: [Components.Schemas.ResolutionReference]? = nil,
    mp4Resolutions: [Components.Schemas.ResolutionReference]? = nil,
    storageObjects: [Components.Schemas.StorageObjectModel]? = nil,
    oldResolutions: [Components.Schemas.StorageObjectModel]? = nil,
    hasBothOldAndNewResolutionFormat: Swift.Bool? = nil,
    hasOriginal: Swift.Bool? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `VideoResolutionsInfoModel`.

- Parameters:
  - videoId: The unique identifier of the video.
  - videoLibraryId: The ID of the video library.
  - availableResolutions: A list of available resolutions for the video.
  - configuredResolutions: A list of resolutions configured for encoding.
  - playlistResolutions: A list of resolutions used in playlists.
  - storageResolutions: A list of resolutions stored on the server.
  - mp4Resolutions: A list of MP4 fallback resolutions.
  - storageObjects: A list of storage objects related to the video resolutions.
  - oldResolutions: A list of previous resolution objects that may be removed.
  - hasBothOldAndNewResolutionFormat: Indicates if both old and new resolution formats are present.
  - hasOriginal: Indicates if the original video file is available.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| videoId | The unique identifier of the video. |
| videoLibraryId | The ID of the video library. |
| availableResolutions | A list of available resolutions for the video. |
| configuredResolutions | A list of resolutions configured for encoding. |
| playlistResolutions | A list of resolutions used in playlists. |
| storageResolutions | A list of resolutions stored on the server. |
| mp4Resolutions | A list of MP4 fallback resolutions. |
| storageObjects | A list of storage objects related to the video resolutions. |
| oldResolutions | A list of previous resolution objects that may be removed. |
| hasBothOldAndNewResolutionFormat | Indicates if both old and new resolution formats are present. |
| hasOriginal | Indicates if the original video file is available. |
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