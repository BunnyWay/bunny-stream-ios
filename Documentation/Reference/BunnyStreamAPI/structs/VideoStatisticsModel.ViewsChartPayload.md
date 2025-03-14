**STRUCT**

# `VideoStatisticsModel.ViewsChartPayload`

```swift
public struct ViewsChartPayload: Codable, Hashable, Sendable
```

A chart representing view counts over time.

## Properties
### `additionalProperties`

```swift
public var additionalProperties: [String: Swift.Int64]
```

A container of undocumented properties.

## Methods
### `init(additionalProperties:)`

```swift
public init(additionalProperties: [String: Swift.Int64] = .init())
```

Creates a new `ViewsChartPayload`.

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