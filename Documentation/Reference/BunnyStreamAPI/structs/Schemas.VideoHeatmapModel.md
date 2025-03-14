**STRUCT**

# `Schemas.VideoHeatmapModel`

```swift
public struct VideoHeatmapModel: Codable, Hashable, Sendable
```

Represents the heatmap data for a video. Each key represents a time segment and its corresponding watch percentage.

## Properties
### `heatmap`

```swift
public var heatmap: Components.Schemas.VideoHeatmapModel.HeatmapPayload?
```

The heatmap where keys are time segments and values are watch percentages.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(heatmap:additionalProperties:)`

```swift
public init(
    heatmap: Components.Schemas.VideoHeatmapModel.HeatmapPayload? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `VideoHeatmapModel`.

- Parameters:
  - heatmap: The heatmap where keys are time segments and values are watch percentages.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| heatmap | The heatmap where keys are time segments and values are watch percentages. |
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