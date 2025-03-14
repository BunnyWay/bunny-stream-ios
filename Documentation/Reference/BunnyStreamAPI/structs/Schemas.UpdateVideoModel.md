**STRUCT**

# `Schemas.UpdateVideoModel`

```swift
public struct UpdateVideoModel: Codable, Hashable, Sendable
```

Schema for updating video metadata.

## Properties
### `title`

```swift
public var title: Swift.String?
```

The updated title of the video.

### `collectionId`

```swift
public var collectionId: Swift.String?
```

The ID of the collection to which the video belongs.

### `chapters`

```swift
public var chapters: [Components.Schemas.ChapterModel]?
```

A list of chapters for the video.

### `moments`

```swift
public var moments: [Components.Schemas.MomentModel]?
```

A list of key moments in the video.

### `metaTags`

```swift
public var metaTags: [Components.Schemas.MetaTagModel]?
```

A list of meta tags to associate with the video.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(title:collectionId:chapters:moments:metaTags:additionalProperties:)`

```swift
public init(
    title: Swift.String? = nil,
    collectionId: Swift.String? = nil,
    chapters: [Components.Schemas.ChapterModel]? = nil,
    moments: [Components.Schemas.MomentModel]? = nil,
    metaTags: [Components.Schemas.MetaTagModel]? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `UpdateVideoModel`.

- Parameters:
  - title: The updated title of the video.
  - collectionId: The ID of the collection to which the video belongs.
  - chapters: A list of chapters for the video.
  - moments: A list of key moments in the video.
  - metaTags: A list of meta tags to associate with the video.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| title | The updated title of the video. |
| collectionId | The ID of the collection to which the video belongs. |
| chapters | A list of chapters for the video. |
| moments | A list of key moments in the video. |
| metaTags | A list of meta tags to associate with the video. |
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