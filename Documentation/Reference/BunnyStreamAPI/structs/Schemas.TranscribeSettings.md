**STRUCT**

# `Schemas.TranscribeSettings`

```swift
public struct TranscribeSettings: Codable, Hashable, Sendable
```

Settings for video transcription that allow overriding default transcription options.

- Remark: Generated from `#/components/schemas/TranscribeSettings`.

## Properties
### `targetLanguages`

```swift
public var targetLanguages: [Swift.String]?
```

List of target language codes (ISO 639-1) for transcription.

- Remark: Generated from `#/components/schemas/TranscribeSettings/targetLanguages`.

### `generateTitle`

```swift
public var generateTitle: Swift.Bool?
```

Determines if the video title should be automatically generated.

- Remark: Generated from `#/components/schemas/TranscribeSettings/generateTitle`.

### `generateDescription`

```swift
public var generateDescription: Swift.Bool?
```

Determines if the video description should be automatically generated.

- Remark: Generated from `#/components/schemas/TranscribeSettings/generateDescription`.

### `sourceLanguage`

```swift
public var sourceLanguage: Swift.String?
```

The source language code (ISO 639-1) of the video. This takes precedence over the query parameter if provided.

- Remark: Generated from `#/components/schemas/TranscribeSettings/sourceLanguage`.

## Methods
### `init(targetLanguages:generateTitle:generateDescription:sourceLanguage:)`

```swift
public init(
    targetLanguages: [Swift.String]? = nil,
    generateTitle: Swift.Bool? = nil,
    generateDescription: Swift.Bool? = nil,
    sourceLanguage: Swift.String? = nil
)
```

Creates a new `TranscribeSettings`.

- Parameters:
  - targetLanguages: List of target language codes (ISO 639-1) for transcription.
  - generateTitle: Determines if the video title should be automatically generated.
  - generateDescription: Determines if the video description should be automatically generated.
  - sourceLanguage: The source language code (ISO 639-1) of the video. This takes precedence over the query parameter if provided.

#### Parameters

| Name | Description |
| ---- | ----------- |
| targetLanguages | List of target language codes (ISO 639-1) for transcription. |
| generateTitle | Determines if the video title should be automatically generated. |
| generateDescription | Determines if the video description should be automatically generated. |
| sourceLanguage | The source language code (ISO 639-1) of the video. This takes precedence over the query parameter if provided. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |