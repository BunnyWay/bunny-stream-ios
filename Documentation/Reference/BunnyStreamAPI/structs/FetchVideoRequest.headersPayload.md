**STRUCT**

# `FetchVideoRequest.headersPayload`

```swift
public struct headersPayload: Codable, Hashable, Sendable
```

Optional headers to include with the fetch request.

- Remark: Generated from `#/components/schemas/FetchVideoRequest/headers`.

## Properties
### `additionalProperties`

```swift
public var additionalProperties: [String: Swift.String]
```

A container of undocumented properties.

## Methods
### `init(additionalProperties:)`

```swift
public init(additionalProperties: [String: Swift.String] = .init())
```

Creates a new `headersPayload`.

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