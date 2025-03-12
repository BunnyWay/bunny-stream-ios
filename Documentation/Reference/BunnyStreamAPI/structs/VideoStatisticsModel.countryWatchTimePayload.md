**STRUCT**

# `VideoStatisticsModel.countryWatchTimePayload`

```swift
public struct countryWatchTimePayload: Codable, Hashable, Sendable
```

Total watch time grouped by country.

- Remark: Generated from `#/components/schemas/VideoStatisticsModel/countryWatchTime`.

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

Creates a new `countryWatchTimePayload`.

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