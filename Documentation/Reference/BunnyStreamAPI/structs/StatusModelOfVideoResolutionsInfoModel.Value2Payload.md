**STRUCT**

# `StatusModelOfVideoResolutionsInfoModel.Value2Payload`

```swift
public struct Value2Payload: Codable, Hashable, Sendable
```

Wraps the VideoResolutionsInfoModel with a status response.

- Remark: Generated from `#/components/schemas/StatusModelOfVideoResolutionsInfoModel/value2`.

## Properties
### `data`

```swift
public var data: Components.Schemas.StatusModelOfVideoResolutionsInfoModel.Value2Payload.dataPayload?
```

- Remark: Generated from `#/components/schemas/StatusModelOfVideoResolutionsInfoModel/value2/data`.

## Methods
### `init(data:)`

```swift
public init(data: Components.Schemas.StatusModelOfVideoResolutionsInfoModel.Value2Payload.dataPayload? = nil)
```

Creates a new `Value2Payload`.

- Parameters:
  - data:

#### Parameters

| Name | Description |
| ---- | ----------- |
| data |  |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |