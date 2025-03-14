**STRUCT**

# `Schemas.VideoStatisticsModel`

```swift
public struct VideoStatisticsModel: Codable, Hashable, Sendable
```

Represents various statistics for a video including view counts, watch time, and engagement score.

## Properties
### `viewsChart`

```swift
public var viewsChart: Components.Schemas.VideoStatisticsModel.ViewsChartPayload?
```

A chart representing view counts over time.

### `watchTimeChart`

```swift
public var watchTimeChart: Components.Schemas.VideoStatisticsModel.WatchTimeChartPayload?
```

A chart representing total watch time over time.

### `countryViewCounts`

```swift
public var countryViewCounts: Components.Schemas.VideoStatisticsModel.CountryViewCountsPayload?
```

View counts grouped by country.

### `countryWatchTime`

```swift
public var countryWatchTime: Components.Schemas.VideoStatisticsModel.CountryWatchTimePayload?
```

Total watch time grouped by country.

### `engagementScore`

```swift
public var engagementScore: Swift.Int32?
```

A score representing viewer engagement.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(viewsChart:watchTimeChart:countryViewCounts:countryWatchTime:engagementScore:additionalProperties:)`

```swift
public init(
    viewsChart: Components.Schemas.VideoStatisticsModel.ViewsChartPayload? = nil,
    watchTimeChart: Components.Schemas.VideoStatisticsModel.WatchTimeChartPayload? = nil,
    countryViewCounts: Components.Schemas.VideoStatisticsModel.CountryViewCountsPayload? = nil,
    countryWatchTime: Components.Schemas.VideoStatisticsModel.CountryWatchTimePayload? = nil,
    engagementScore: Swift.Int32? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `VideoStatisticsModel`.

- Parameters:
  - viewsChart: A chart representing view counts over time.
  - watchTimeChart: A chart representing total watch time over time.
  - countryViewCounts: View counts grouped by country.
  - countryWatchTime: Total watch time grouped by country.
  - engagementScore: A score representing viewer engagement.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| viewsChart | A chart representing view counts over time. |
| watchTimeChart | A chart representing total watch time over time. |
| countryViewCounts | View counts grouped by country. |
| countryWatchTime | Total watch time grouped by country. |
| engagementScore | A score representing viewer engagement. |
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