**STRUCT**

# `Schemas.VideoHeatmapModel`

```swift
public struct VideoHeatmapModel: Codable, Hashable, Sendable
```

Represents the heatmap data for a video. Each key represents a time segment and its corresponding watch percentage.

- Remark: Generated from `#/components/schemas/VideoHeatmapModel`.

## Properties
### `heatmap`

```swift
public var heatmap: Components.Schemas.VideoHeatmapModel.heatmapPayload?
```

The heatmap where keys are time segments and values are watch percentages.

- Remark: Generated from `#/components/schemas/VideoHeatmapModel/heatmap`.

## Methods
### `init(heatmap:)`

```swift
public init(heatmap: Components.Schemas.VideoHeatmapModel.heatmapPayload? = nil)
```

Creates a new `VideoHeatmapModel`.

- Parameters:
  - heatmap: The heatmap where keys are time segments and values are watch percentages.

#### Parameters

| Name | Description |
| ---- | ----------- |
| heatmap | The heatmap where keys are time segments and values are watch percentages. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |