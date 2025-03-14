**STRUCT**

# `Schemas.VideoOEmbedModel`

```swift
public struct VideoOEmbedModel: Codable, Hashable, Sendable
```

Represents OEmbed data for a video, including embed HTML and metadata such as title and provider information.

## Properties
### `version`

```swift
public var version: Swift.String?
```

The version of the OEmbed specification being used.

### `title`

```swift
public var title: Swift.String?
```

The title of the video.

### `_type`

```swift
public var _type: Swift.String?
```

The type of the embedded object (e.g., video).

### `thumbnailUrl`

```swift
public var thumbnailUrl: Swift.String?
```

The URL of the video thumbnail.

### `width`

```swift
public var width: Swift.Int32?
```

The width of the embedded video.

### `height`

```swift
public var height: Swift.Int32?
```

The height of the embedded video.

### `html`

```swift
public var html: Swift.String?
```

The HTML snippet for embedding the video.

### `providerName`

```swift
public var providerName: Swift.String?
```

The name of the provider (e.g., bunny.net).

### `providerUrl`

```swift
public var providerUrl: Swift.String?
```

The URL of the provider's website.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(version:title:_type:thumbnailUrl:width:height:html:providerName:providerUrl:additionalProperties:)`

```swift
public init(
    version: Swift.String? = nil,
    title: Swift.String? = nil,
    _type: Swift.String? = nil,
    thumbnailUrl: Swift.String? = nil,
    width: Swift.Int32? = nil,
    height: Swift.Int32? = nil,
    html: Swift.String? = nil,
    providerName: Swift.String? = nil,
    providerUrl: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `VideoOEmbedModel`.

- Parameters:
  - version: The version of the OEmbed specification being used.
  - title: The title of the video.
  - _type: The type of the embedded object (e.g., video).
  - thumbnailUrl: The URL of the video thumbnail.
  - width: The width of the embedded video.
  - height: The height of the embedded video.
  - html: The HTML snippet for embedding the video.
  - providerName: The name of the provider (e.g., bunny.net).
  - providerUrl: The URL of the provider's website.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| version | The version of the OEmbed specification being used. |
| title | The title of the video. |
| _type | The type of the embedded object (e.g., video). |
| thumbnailUrl | The URL of the video thumbnail. |
| width | The width of the embedded video. |
| height | The height of the embedded video. |
| html | The HTML snippet for embedding the video. |
| providerName | The name of the provider (e.g., bunny.net). |
| providerUrl | The URL of the provider’s website. |
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