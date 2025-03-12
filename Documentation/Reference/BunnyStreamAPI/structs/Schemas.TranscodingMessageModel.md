**STRUCT**

# `Schemas.TranscodingMessageModel`

```swift
public struct TranscodingMessageModel: Codable, Hashable, Sendable
```

Represents a message from the transcoding process indicating warnings or errors.

- Remark: Generated from `#/components/schemas/TranscodingMessageModel`.

## Properties
### `timeStamp`

```swift
public var timeStamp: Foundation.Date?
```

The timestamp when the message was generated.

- Remark: Generated from `#/components/schemas/TranscodingMessageModel/timeStamp`.

### `level`

```swift
public var level: Components.Schemas.Severity?
```

- Remark: Generated from `#/components/schemas/TranscodingMessageModel/level`.

### `issueCode`

```swift
public var issueCode: Components.Schemas.IssueCodes?
```

- Remark: Generated from `#/components/schemas/TranscodingMessageModel/issueCode`.

### `message`

```swift
public var message: Swift.String?
```

A descriptive message detailing the transcoding issue.

- Remark: Generated from `#/components/schemas/TranscodingMessageModel/message`.

### `value`

```swift
public var value: Swift.String?
```

An optional value providing further context for the issue.

- Remark: Generated from `#/components/schemas/TranscodingMessageModel/value`.

## Methods
### `init(timeStamp:level:issueCode:message:value:)`

```swift
public init(
    timeStamp: Foundation.Date? = nil,
    level: Components.Schemas.Severity? = nil,
    issueCode: Components.Schemas.IssueCodes? = nil,
    message: Swift.String? = nil,
    value: Swift.String? = nil
)
```

Creates a new `TranscodingMessageModel`.

- Parameters:
  - timeStamp: The timestamp when the message was generated.
  - level:
  - issueCode:
  - message: A descriptive message detailing the transcoding issue.
  - value: An optional value providing further context for the issue.

#### Parameters

| Name | Description |
| ---- | ----------- |
| timeStamp | The timestamp when the message was generated. |
| level |  |
| issueCode |  |
| message | A descriptive message detailing the transcoding issue. |
| value | An optional value providing further context for the issue. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |