**ENUM**

# `Body.JsonPayload`

```swift
@frozen public enum JsonPayload: Codable, Hashable, Sendable
```

## Cases
### `TranscribeSettings(_:)`

```swift
case TranscribeSettings(Components.Schemas.TranscribeSettings)
```

## Methods
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