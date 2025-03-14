**STRUCT**

# `Schemas.CaptionModel`

```swift
public struct CaptionModel: Codable, Hashable, Sendable
```

Represents caption details for a video.

## Properties
### `srclang`

```swift
public var srclang: Swift.String?
```

The ISO 639-1 language code for the caption.

### `label`

```swift
public var label: Swift.String?
```

A descriptive label for the caption.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(srclang:label:additionalProperties:)`

```swift
public init(
    srclang: Swift.String? = nil,
    label: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `CaptionModel`.

- Parameters:
  - srclang: The ISO 639-1 language code for the caption.
  - label: A descriptive label for the caption.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| srclang | The ISO 639-1 language code for the caption. |
| label | A descriptive label for the caption. |
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