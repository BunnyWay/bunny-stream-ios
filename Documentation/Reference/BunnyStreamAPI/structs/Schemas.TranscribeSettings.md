**STRUCT**

# `Schemas.TranscribeSettings`

```swift
public struct TranscribeSettings: Codable, Hashable, Sendable
```

Settings for video transcription that allow overriding default transcription options.

## Properties
### `targetLanguages`

```swift
public var targetLanguages: [Swift.String]?
```

List of target language codes (ISO 639-1) for transcription.

### `generateTitle`

```swift
public var generateTitle: Swift.Bool?
```

Determines if the video title should be automatically generated.

### `generateDescription`

```swift
public var generateDescription: Swift.Bool?
```

Determines if the video description should be automatically generated.

### `sourceLanguage`

```swift
public var sourceLanguage: Swift.String?
```

The source language code (ISO 639-1) of the video. This takes precedence over the query parameter if provided.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(targetLanguages:generateTitle:generateDescription:sourceLanguage:additionalProperties:)`

```swift
public init(
    targetLanguages: [Swift.String]? = nil,
    generateTitle: Swift.Bool? = nil,
    generateDescription: Swift.Bool? = nil,
    sourceLanguage: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `TranscribeSettings`.

- Parameters:
  - targetLanguages: List of target language codes (ISO 639-1) for transcription.
  - generateTitle: Determines if the video title should be automatically generated.
  - generateDescription: Determines if the video description should be automatically generated.
  - sourceLanguage: The source language code (ISO 639-1) of the video. This takes precedence over the query parameter if provided.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| targetLanguages | List of target language codes (ISO 639-1) for transcription. |
| generateTitle | Determines if the video title should be automatically generated. |
| generateDescription | Determines if the video description should be automatically generated. |
| sourceLanguage | The source language code (ISO 639-1) of the video. This takes precedence over the query parameter if provided. |
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