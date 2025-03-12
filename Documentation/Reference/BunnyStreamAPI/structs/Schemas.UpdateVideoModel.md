**STRUCT**

# `Schemas.UpdateVideoModel`

```swift
public struct UpdateVideoModel: Codable, Hashable, Sendable
```

Schema for updating video metadata.

- Remark: Generated from `#/components/schemas/UpdateVideoModel`.

## Properties
### `title`

```swift
public var title: Swift.String?
```

The updated title of the video.

- Remark: Generated from `#/components/schemas/UpdateVideoModel/title`.

### `collectionId`

```swift
public var collectionId: Swift.String?
```

The ID of the collection to which the video belongs.

- Remark: Generated from `#/components/schemas/UpdateVideoModel/collectionId`.

### `chapters`

```swift
public var chapters: [Components.Schemas.ChapterModel]?
```

A list of chapters for the video.

- Remark: Generated from `#/components/schemas/UpdateVideoModel/chapters`.

### `moments`

```swift
public var moments: [Components.Schemas.MomentModel]?
```

A list of key moments in the video.

- Remark: Generated from `#/components/schemas/UpdateVideoModel/moments`.

### `metaTags`

```swift
public var metaTags: [Components.Schemas.MetaTagModel]?
```

A list of meta tags to associate with the video.

- Remark: Generated from `#/components/schemas/UpdateVideoModel/metaTags`.

## Methods
### `init(title:collectionId:chapters:moments:metaTags:)`

```swift
public init(
    title: Swift.String? = nil,
    collectionId: Swift.String? = nil,
    chapters: [Components.Schemas.ChapterModel]? = nil,
    moments: [Components.Schemas.MomentModel]? = nil,
    metaTags: [Components.Schemas.MetaTagModel]? = nil
)
```

Creates a new `UpdateVideoModel`.

- Parameters:
  - title: The updated title of the video.
  - collectionId: The ID of the collection to which the video belongs.
  - chapters: A list of chapters for the video.
  - moments: A list of key moments in the video.
  - metaTags: A list of meta tags to associate with the video.

#### Parameters

| Name | Description |
| ---- | ----------- |
| title | The updated title of the video. |
| collectionId | The ID of the collection to which the video belongs. |
| chapters | A list of chapters for the video. |
| moments | A list of key moments in the video. |
| metaTags | A list of meta tags to associate with the video. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |