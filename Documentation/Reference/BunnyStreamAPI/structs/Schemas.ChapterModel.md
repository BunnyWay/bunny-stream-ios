**STRUCT**

# `Schemas.ChapterModel`

```swift
public struct ChapterModel: Codable, Hashable, Sendable
```

Represents a chapter within a video, including its title and start/end times.

- Remark: Generated from `#/components/schemas/ChapterModel`.

## Properties
### `title`

```swift
public var title: Swift.String
```

The title of the chapter.

- Remark: Generated from `#/components/schemas/ChapterModel/title`.

### `start`

```swift
public var start: Swift.Int32?
```

The start time of the chapter in seconds.

- Remark: Generated from `#/components/schemas/ChapterModel/start`.

### `end`

```swift
public var end: Swift.Int32?
```

The end time of the chapter in seconds.

- Remark: Generated from `#/components/schemas/ChapterModel/end`.

## Methods
### `init(title:start:end:)`

```swift
public init(
    title: Swift.String,
    start: Swift.Int32? = nil,
    end: Swift.Int32? = nil
)
```

Creates a new `ChapterModel`.

- Parameters:
  - title: The title of the chapter.
  - start: The start time of the chapter in seconds.
  - end: The end time of the chapter in seconds.

#### Parameters

| Name | Description |
| ---- | ----------- |
| title | The title of the chapter. |
| start | The start time of the chapter in seconds. |
| end | The end time of the chapter in seconds. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |