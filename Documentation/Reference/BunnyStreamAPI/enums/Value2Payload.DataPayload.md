**ENUM**

# `Value2Payload.DataPayload`

```swift
@frozen public enum DataPayload: Codable, Hashable, Sendable
```

## Cases
### `VideoResolutionsInfoModel(_:)`

```swift
case VideoResolutionsInfoModel(Components.Schemas.VideoResolutionsInfoModel)
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