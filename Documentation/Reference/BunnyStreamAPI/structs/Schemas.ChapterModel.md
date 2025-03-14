**STRUCT**

# `Schemas.ChapterModel`

```swift
public struct ChapterModel: Codable, Hashable, Sendable
```

Represents a chapter within a video, including its title and start/end times.

## Properties
### `title`

```swift
public var title: Swift.String
```

The title of the chapter.

### `start`

```swift
public var start: Swift.Int32?
```

The start time of the chapter in seconds.

### `end`

```swift
public var end: Swift.Int32?
```

The end time of the chapter in seconds.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(title:start:end:additionalProperties:)`

```swift
public init(
    title: Swift.String,
    start: Swift.Int32? = nil,
    end: Swift.Int32? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `ChapterModel`.

- Parameters:
  - title: The title of the chapter.
  - start: The start time of the chapter in seconds.
  - end: The end time of the chapter in seconds.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| title | The title of the chapter. |
| start | The start time of the chapter in seconds. |
| end | The end time of the chapter in seconds. |
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