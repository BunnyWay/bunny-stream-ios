**ENUM**

# `VideoPlayDataModel.videoPayload`

```swift
@frozen public enum videoPayload: Codable, Hashable, Sendable
```

The video data model.

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/video`.

## Cases
### `VideoModel(_:)`

```swift
case VideoModel(Components.Schemas.VideoModel)
```

- Remark: Generated from `#/components/schemas/VideoPlayDataModel/video/case1`.

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