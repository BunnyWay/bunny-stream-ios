**STRUCT**

# `Schemas.CaptionModel`

```swift
public struct CaptionModel: Codable, Hashable, Sendable
```

Represents caption details for a video.

- Remark: Generated from `#/components/schemas/CaptionModel`.

## Properties
### `srclang`

```swift
public var srclang: Swift.String?
```

The ISO 639-1 language code for the caption.

- Remark: Generated from `#/components/schemas/CaptionModel/srclang`.

### `label`

```swift
public var label: Swift.String?
```

A descriptive label for the caption.

- Remark: Generated from `#/components/schemas/CaptionModel/label`.

## Methods
### `init(srclang:label:)`

```swift
public init(
    srclang: Swift.String? = nil,
    label: Swift.String? = nil
)
```

Creates a new `CaptionModel`.

- Parameters:
  - srclang: The ISO 639-1 language code for the caption.
  - label: A descriptive label for the caption.

#### Parameters

| Name | Description |
| ---- | ----------- |
| srclang | The ISO 639-1 language code for the caption. |
| label | A descriptive label for the caption. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |