**STRUCT**

# `Schemas.UpdateCollectionModel`

```swift
public struct UpdateCollectionModel: Codable, Hashable, Sendable
```

Schema for updating collection details.

- Remark: Generated from `#/components/schemas/UpdateCollectionModel`.

## Properties
### `name`

```swift
public var name: Swift.String?
```

The updated name of the collection.

- Remark: Generated from `#/components/schemas/UpdateCollectionModel/name`.

## Methods
### `init(name:)`

```swift
public init(name: Swift.String? = nil)
```

Creates a new `UpdateCollectionModel`.

- Parameters:
  - name: The updated name of the collection.

#### Parameters

| Name | Description |
| ---- | ----------- |
| name | The updated name of the collection. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |