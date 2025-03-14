**STRUCT**

# `StatusModelOfVideoResolutionsInfoModel.Value2Payload`

```swift
public struct Value2Payload: Codable, Hashable, Sendable
```

Wraps the VideoResolutionsInfoModel with a status response.

## Properties
### `data`

```swift
public var data: Components.Schemas.StatusModelOfVideoResolutionsInfoModel.Value2Payload.DataPayload?
```

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(data:additionalProperties:)`

```swift
public init(
    data: Components.Schemas.StatusModelOfVideoResolutionsInfoModel.Value2Payload.DataPayload? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `Value2Payload`.

- Parameters:
  - data:
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| data |  |
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