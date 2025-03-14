**ENUM**

# `VideoPlayDataModel.VideoPayload`

```swift
@frozen public enum VideoPayload: Codable, Hashable, Sendable
```

The video data model.

## Cases
### `VideoModel(_:)`

```swift
case VideoModel(Components.Schemas.VideoModel)
```

## Methods
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