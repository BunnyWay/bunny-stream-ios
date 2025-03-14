**STRUCT**

# `Schemas.CollectionModel`

```swift
public struct CollectionModel: Codable, Hashable, Sendable
```

Represents a video collection in the library. Contains metadata such as the unique identifier, name, video count, total storage size, and preview information.

## Properties
### `videoLibraryId`

```swift
public var videoLibraryId: Swift.Int64?
```

The ID of the video library that contains the collection.

### `guid`

```swift
public var guid: Swift.String?
```

The unique identifier of the collection.

### `name`

```swift
public var name: Swift.String?
```

The name of the collection.

### `videoCount`

```swift
public var videoCount: Swift.Int64?
```

The number of videos in the collection.

### `totalSize`

```swift
public var totalSize: Swift.Int64?
```

The total storage size of the collection in bytes.

### `previewVideoIds`

```swift
public var previewVideoIds: Swift.String?
```

Comma-separated list of video IDs used as preview icons.

### `previewImageUrls`

```swift
public var previewImageUrls: [Swift.String]?
```

An array of URLs for preview images of the videos in the collection.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(videoLibraryId:guid:name:videoCount:totalSize:previewVideoIds:previewImageUrls:additionalProperties:)`

```swift
public init(
    videoLibraryId: Swift.Int64? = nil,
    guid: Swift.String? = nil,
    name: Swift.String? = nil,
    videoCount: Swift.Int64? = nil,
    totalSize: Swift.Int64? = nil,
    previewVideoIds: Swift.String? = nil,
    previewImageUrls: [Swift.String]? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `CollectionModel`.

- Parameters:
  - videoLibraryId: The ID of the video library that contains the collection.
  - guid: The unique identifier of the collection.
  - name: The name of the collection.
  - videoCount: The number of videos in the collection.
  - totalSize: The total storage size of the collection in bytes.
  - previewVideoIds: Comma-separated list of video IDs used as preview icons.
  - previewImageUrls: An array of URLs for preview images of the videos in the collection.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| videoLibraryId | The ID of the video library that contains the collection. |
| guid | The unique identifier of the collection. |
| name | The name of the collection. |
| videoCount | The number of videos in the collection. |
| totalSize | The total storage size of the collection in bytes. |
| previewVideoIds | Comma-separated list of video IDs used as preview icons. |
| previewImageUrls | An array of URLs for preview images of the videos in the collection. |
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