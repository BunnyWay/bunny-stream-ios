**STRUCT**

# `Schemas.CreateVideoModel`

```swift
public struct CreateVideoModel: Codable, Hashable, Sendable
```

Schema for creating a new video entry. 'title' is required.

- Remark: Generated from `#/components/schemas/CreateVideoModel`.

## Properties
### `title`

```swift
public var title: Swift.String
```

The title of the new video.

- Remark: Generated from `#/components/schemas/CreateVideoModel/title`.

### `collectionId`

```swift
public var collectionId: Swift.String?
```

Optional collection ID where the video will be placed.

- Remark: Generated from `#/components/schemas/CreateVideoModel/collectionId`.

### `thumbnailTime`

```swift
public var thumbnailTime: Swift.Int32?
```

Video time in milliseconds used to extract the main video thumbnail.

- Remark: Generated from `#/components/schemas/CreateVideoModel/thumbnailTime`.

## Methods
### `init(title:collectionId:thumbnailTime:)`

```swift
public init(
    title: Swift.String,
    collectionId: Swift.String? = nil,
    thumbnailTime: Swift.Int32? = nil
)
```

Creates a new `CreateVideoModel`.

- Parameters:
  - title: The title of the new video.
  - collectionId: Optional collection ID where the video will be placed.
  - thumbnailTime: Video time in milliseconds used to extract the main video thumbnail.

#### Parameters

| Name | Description |
| ---- | ----------- |
| title | The title of the new video. |
| collectionId | Optional collection ID where the video will be placed. |
| thumbnailTime | Video time in milliseconds used to extract the main video thumbnail. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |