**STRUCT**

# `Schemas.StatusModel`

```swift
public struct StatusModel: Codable, Hashable, Sendable
```

Generic status response model indicating the success or failure of an operation.

- Remark: Generated from `#/components/schemas/StatusModel`.

## Properties
### `success`

```swift
public var success: Swift.Bool?
```

Indicates whether the operation was successful.

- Remark: Generated from `#/components/schemas/StatusModel/success`.

### `message`

```swift
public var message: Swift.String?
```

A descriptive message regarding the operation outcome.

- Remark: Generated from `#/components/schemas/StatusModel/message`.

### `statusCode`

```swift
public var statusCode: Swift.Int32?
```

The HTTP status code for the response.

- Remark: Generated from `#/components/schemas/StatusModel/statusCode`.

## Methods
### `init(success:message:statusCode:)`

```swift
public init(
    success: Swift.Bool? = nil,
    message: Swift.String? = nil,
    statusCode: Swift.Int32? = nil
)
```

Creates a new `StatusModel`.

- Parameters:
  - success: Indicates whether the operation was successful.
  - message: A descriptive message regarding the operation outcome.
  - statusCode: The HTTP status code for the response.

#### Parameters

| Name | Description |
| ---- | ----------- |
| success | Indicates whether the operation was successful. |
| message | A descriptive message regarding the operation outcome. |
| statusCode | The HTTP status code for the response. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |