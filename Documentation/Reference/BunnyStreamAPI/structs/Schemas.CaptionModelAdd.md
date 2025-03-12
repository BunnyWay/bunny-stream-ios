**STRUCT**

# `Schemas.CaptionModelAdd`

```swift
public struct CaptionModelAdd: Codable, Hashable, Sendable
```

Schema for adding a caption. Includes language code, descriptive label, and a base64 encoded captions file.

- Remark: Generated from `#/components/schemas/CaptionModelAdd`.

## Properties
### `srclang`

```swift
public var srclang: Swift.String?
```

The ISO 639-1 language code for the caption.

- Remark: Generated from `#/components/schemas/CaptionModelAdd/srclang`.

### `label`

```swift
public var label: Swift.String?
```

A descriptive label for the caption.

- Remark: Generated from `#/components/schemas/CaptionModelAdd/label`.

### `captionsFile`

```swift
public var captionsFile: Swift.String?
```

The base64 encoded captions file content.

- Remark: Generated from `#/components/schemas/CaptionModelAdd/captionsFile`.

## Methods
### `init(srclang:label:captionsFile:)`

```swift
public init(
    srclang: Swift.String? = nil,
    label: Swift.String? = nil,
    captionsFile: Swift.String? = nil
)
```

Creates a new `CaptionModelAdd`.

- Parameters:
  - srclang: The ISO 639-1 language code for the caption.
  - label: A descriptive label for the caption.
  - captionsFile: The base64 encoded captions file content.

#### Parameters

| Name | Description |
| ---- | ----------- |
| srclang | The ISO 639-1 language code for the caption. |
| label | A descriptive label for the caption. |
| captionsFile | The base64 encoded captions file content. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |