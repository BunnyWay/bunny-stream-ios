**STRUCT**

# `VideoHeatmapModel.HeatmapPayload`

```swift
public struct HeatmapPayload: Codable, Hashable, Sendable
```

The heatmap where keys are time segments and values are watch percentages.

## Properties
### `additionalProperties`

```swift
public var additionalProperties: [String: Swift.Int32]
```

A container of undocumented properties.

## Methods
### `init(additionalProperties:)`

```swift
public init(additionalProperties: [String: Swift.Int32] = .init())
```

Creates a new `HeatmapPayload`.

- Parameters:
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
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