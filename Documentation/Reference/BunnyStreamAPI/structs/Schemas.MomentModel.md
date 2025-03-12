**STRUCT**

# `Schemas.MomentModel`

```swift
public struct MomentModel: Codable, Hashable, Sendable
```

Represents a key moment in the video with a descriptive label and timestamp.

- Remark: Generated from `#/components/schemas/MomentModel`.

## Properties
### `label`

```swift
public var label: Swift.String
```

A descriptive label for the moment.

- Remark: Generated from `#/components/schemas/MomentModel/label`.

### `timestamp`

```swift
public var timestamp: Swift.Int32?
```

The timestamp of the moment in seconds.

- Remark: Generated from `#/components/schemas/MomentModel/timestamp`.

## Methods
### `init(label:timestamp:)`

```swift
public init(
    label: Swift.String,
    timestamp: Swift.Int32? = nil
)
```

Creates a new `MomentModel`.

- Parameters:
  - label: A descriptive label for the moment.
  - timestamp: The timestamp of the moment in seconds.

#### Parameters

| Name | Description |
| ---- | ----------- |
| label | A descriptive label for the moment. |
| timestamp | The timestamp of the moment in seconds. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |