**STRUCT**

# `Input.Path`

```swift
public struct Path: Sendable, Hashable
```

- Remark: Generated from `#/paths/library/{libraryId}/videos/{videoId}/resolutions/cleanup/POST/path`.

## Properties
### `libraryId`

```swift
public var libraryId: Swift.Int64
```

The ID of the video library.

- Remark: Generated from `#/paths/library/{libraryId}/videos/{videoId}/resolutions/cleanup/POST/path/libraryId`.

### `videoId`

```swift
public var videoId: Swift.String
```

The unique identifier of the video.

- Remark: Generated from `#/paths/library/{libraryId}/videos/{videoId}/resolutions/cleanup/POST/path/videoId`.

## Methods
### `init(libraryId:videoId:)`

```swift
public init(
    libraryId: Swift.Int64,
    videoId: Swift.String
)
```

Creates a new `Path`.

- Parameters:
  - libraryId: The ID of the video library.
  - videoId: The unique identifier of the video.

#### Parameters

| Name | Description |
| ---- | ----------- |
| libraryId | The ID of the video library. |
| videoId | The unique identifier of the video. |