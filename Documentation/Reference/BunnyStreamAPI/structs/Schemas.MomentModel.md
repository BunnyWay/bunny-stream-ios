**STRUCT**

# `Schemas.MomentModel`

```swift
public struct MomentModel: Codable, Hashable, Sendable
```

Represents a key moment in the video with a descriptive label and timestamp.

## Properties
### `label`

```swift
public var label: Swift.String
```

A descriptive label for the moment.

### `timestamp`

```swift
public var timestamp: Swift.Int32?
```

The timestamp of the moment in seconds.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(label:timestamp:additionalProperties:)`

```swift
public init(
    label: Swift.String,
    timestamp: Swift.Int32? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `MomentModel`.

- Parameters:
  - label: A descriptive label for the moment.
  - timestamp: The timestamp of the moment in seconds.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| label | A descriptive label for the moment. |
| timestamp | The timestamp of the moment in seconds. |
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