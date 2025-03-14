**STRUCT**

# `Schemas.CaptionModelAdd`

```swift
public struct CaptionModelAdd: Codable, Hashable, Sendable
```

Schema for adding a caption. Includes language code, descriptive label, and a base64 encoded captions file.

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

### `captionsFile`

```swift
public var captionsFile: Swift.String?
```

The base64 encoded captions file content.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(srclang:label:captionsFile:additionalProperties:)`

```swift
public init(
    srclang: Swift.String? = nil,
    label: Swift.String? = nil,
    captionsFile: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `CaptionModelAdd`.

- Parameters:
  - srclang: The ISO 639-1 language code for the caption.
  - label: A descriptive label for the caption.
  - captionsFile: The base64 encoded captions file content.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| srclang | The ISO 639-1 language code for the caption. |
| label | A descriptive label for the caption. |
| captionsFile | The base64 encoded captions file content. |
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