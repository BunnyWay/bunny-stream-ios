**STRUCT**

# `Schemas.VideoStatisticsModel`

```swift
public struct VideoStatisticsModel: Codable, Hashable, Sendable
```

Represents various statistics for a video including view counts, watch time, and engagement score.

- Remark: Generated from `#/components/schemas/VideoStatisticsModel`.

## Properties
### `viewsChart`

```swift
public var viewsChart: Components.Schemas.VideoStatisticsModel.viewsChartPayload?
```

A chart representing view counts over time.

- Remark: Generated from `#/components/schemas/VideoStatisticsModel/viewsChart`.

### `watchTimeChart`

```swift
public var watchTimeChart: Components.Schemas.VideoStatisticsModel.watchTimeChartPayload?
```

A chart representing total watch time over time.

- Remark: Generated from `#/components/schemas/VideoStatisticsModel/watchTimeChart`.

### `countryViewCounts`

```swift
public var countryViewCounts: Components.Schemas.VideoStatisticsModel.countryViewCountsPayload?
```

View counts grouped by country.

- Remark: Generated from `#/components/schemas/VideoStatisticsModel/countryViewCounts`.

### `countryWatchTime`

```swift
public var countryWatchTime: Components.Schemas.VideoStatisticsModel.countryWatchTimePayload?
```

Total watch time grouped by country.

- Remark: Generated from `#/components/schemas/VideoStatisticsModel/countryWatchTime`.

### `engagementScore`

```swift
public var engagementScore: Swift.Int32?
```

A score representing viewer engagement.

- Remark: Generated from `#/components/schemas/VideoStatisticsModel/engagementScore`.

## Methods
### `init(viewsChart:watchTimeChart:countryViewCounts:countryWatchTime:engagementScore:)`

```swift
public init(
    viewsChart: Components.Schemas.VideoStatisticsModel.viewsChartPayload? = nil,
    watchTimeChart: Components.Schemas.VideoStatisticsModel.watchTimeChartPayload? = nil,
    countryViewCounts: Components.Schemas.VideoStatisticsModel.countryViewCountsPayload? = nil,
    countryWatchTime: Components.Schemas.VideoStatisticsModel.countryWatchTimePayload? = nil,
    engagementScore: Swift.Int32? = nil
)
```

Creates a new `VideoStatisticsModel`.

- Parameters:
  - viewsChart: A chart representing view counts over time.
  - watchTimeChart: A chart representing total watch time over time.
  - countryViewCounts: View counts grouped by country.
  - countryWatchTime: Total watch time grouped by country.
  - engagementScore: A score representing viewer engagement.

#### Parameters

| Name | Description |
| ---- | ----------- |
| viewsChart | A chart representing view counts over time. |
| watchTimeChart | A chart representing total watch time over time. |
| countryViewCounts | View counts grouped by country. |
| countryWatchTime | Total watch time grouped by country. |
| engagementScore | A score representing viewer engagement. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |