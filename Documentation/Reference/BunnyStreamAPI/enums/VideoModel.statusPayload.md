**ENUM**

# `VideoModel.statusPayload`

```swift
@frozen public enum statusPayload: Codable, Hashable, Sendable
```

The current status of the video (e.g., processing, finished, error).

- Remark: Generated from `#/components/schemas/VideoModel/status`.

## Cases
### `VideoModelStatus(_:)`

```swift
case VideoModelStatus(Components.Schemas.VideoModelStatus)
```

- Remark: Generated from `#/components/schemas/VideoModel/status/case1`.

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