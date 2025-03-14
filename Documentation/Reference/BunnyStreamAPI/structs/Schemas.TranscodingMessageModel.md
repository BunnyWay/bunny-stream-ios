**STRUCT**

# `Schemas.TranscodingMessageModel`

```swift
public struct TranscodingMessageModel: Codable, Hashable, Sendable
```

Represents a message from the transcoding process indicating warnings or errors.

## Properties
### `timeStamp`

```swift
public var timeStamp: Foundation.Date?
```

The timestamp when the message was generated.

### `level`

```swift
public var level: Components.Schemas.Severity?
```

### `issueCode`

```swift
public var issueCode: Components.Schemas.IssueCodes?
```

### `message`

```swift
public var message: Swift.String?
```

A descriptive message detailing the transcoding issue.

### `value`

```swift
public var value: Swift.String?
```

An optional value providing further context for the issue.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(timeStamp:level:issueCode:message:value:additionalProperties:)`

```swift
public init(
    timeStamp: Foundation.Date? = nil,
    level: Components.Schemas.Severity? = nil,
    issueCode: Components.Schemas.IssueCodes? = nil,
    message: Swift.String? = nil,
    value: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `TranscodingMessageModel`.

- Parameters:
  - timeStamp: The timestamp when the message was generated.
  - level:
  - issueCode:
  - message: A descriptive message detailing the transcoding issue.
  - value: An optional value providing further context for the issue.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| timeStamp | The timestamp when the message was generated. |
| level |  |
| issueCode |  |
| message | A descriptive message detailing the transcoding issue. |
| value | An optional value providing further context for the issue. |
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