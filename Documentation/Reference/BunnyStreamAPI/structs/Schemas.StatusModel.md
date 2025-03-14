**STRUCT**

# `Schemas.StatusModel`

```swift
public struct StatusModel: Codable, Hashable, Sendable
```

Generic status response model indicating the success or failure of an operation.

## Properties
### `success`

```swift
public var success: Swift.Bool?
```

Indicates whether the operation was successful.

### `message`

```swift
public var message: Swift.String?
```

A descriptive message regarding the operation outcome.

### `statusCode`

```swift
public var statusCode: Swift.Int32?
```

The HTTP status code for the response.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(success:message:statusCode:additionalProperties:)`

```swift
public init(
    success: Swift.Bool? = nil,
    message: Swift.String? = nil,
    statusCode: Swift.Int32? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `StatusModel`.

- Parameters:
  - success: Indicates whether the operation was successful.
  - message: A descriptive message regarding the operation outcome.
  - statusCode: The HTTP status code for the response.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| success | Indicates whether the operation was successful. |
| message | A descriptive message regarding the operation outcome. |
| statusCode | The HTTP status code for the response. |
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