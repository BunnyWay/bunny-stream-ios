**ENUM**

# `VideoModel.StatusPayload`

```swift
@frozen public enum StatusPayload: Codable, Hashable, Sendable
```

The current status of the video (e.g., processing, finished, error).

## Cases
### `VideoModelStatus(_:)`

```swift
case VideoModelStatus(Components.Schemas.VideoModelStatus)
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