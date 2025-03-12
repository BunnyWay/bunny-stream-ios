**STRUCT**

# `Schemas.StatusModelOfVideoResolutionsInfoModel`

```swift
public struct StatusModelOfVideoResolutionsInfoModel: Codable, Hashable, Sendable
```

- Remark: Generated from `#/components/schemas/StatusModelOfVideoResolutionsInfoModel`.

## Properties
### `value1`

```swift
public var value1: Components.Schemas.StatusModel
```

- Remark: Generated from `#/components/schemas/StatusModelOfVideoResolutionsInfoModel/value1`.

### `value2`

```swift
public var value2: Components.Schemas.StatusModelOfVideoResolutionsInfoModel.Value2Payload
```

Wraps the VideoResolutionsInfoModel with a status response.

- Remark: Generated from `#/components/schemas/StatusModelOfVideoResolutionsInfoModel/value2`.

## Methods
### `init(value1:value2:)`

```swift
public init(
    value1: Components.Schemas.StatusModel,
    value2: Components.Schemas.StatusModelOfVideoResolutionsInfoModel.Value2Payload
)
```

Creates a new `StatusModelOfVideoResolutionsInfoModel`.

- Parameters:
  - value1:
  - value2: Wraps the VideoResolutionsInfoModel with a status response.

#### Parameters

| Name | Description |
| ---- | ----------- |
| value1 |  |
| value2 | Wraps the VideoResolutionsInfoModel with a status response. |

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