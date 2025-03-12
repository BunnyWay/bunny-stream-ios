**STRUCT**

# `Schemas.MetaTagModel`

```swift
public struct MetaTagModel: Codable, Hashable, Sendable
```

Represents a metadata tag for a video.

- Remark: Generated from `#/components/schemas/MetaTagModel`.

## Properties
### `property`

```swift
public var property: Swift.String?
```

The property name of the meta tag.

- Remark: Generated from `#/components/schemas/MetaTagModel/property`.

### `value`

```swift
public var value: Swift.String?
```

The value associated with the meta tag property.

- Remark: Generated from `#/components/schemas/MetaTagModel/value`.

## Methods
### `init(property:value:)`

```swift
public init(
    property: Swift.String? = nil,
    value: Swift.String? = nil
)
```

Creates a new `MetaTagModel`.

- Parameters:
  - property: The property name of the meta tag.
  - value: The value associated with the meta tag property.

#### Parameters

| Name | Description |
| ---- | ----------- |
| property | The property name of the meta tag. |
| value | The value associated with the meta tag property. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |