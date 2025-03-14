**STRUCT**

# `Schemas.PaginationListOfCollectionModel`

```swift
public struct PaginationListOfCollectionModel: Codable, Hashable, Sendable
```

A paginated list of collections.

## Properties
### `totalItems`

```swift
public var totalItems: Swift.Int64?
```

The total number of collections available.

### `currentPage`

```swift
public var currentPage: Swift.Int64?
```

The current page number.

### `itemsPerPage`

```swift
public var itemsPerPage: Swift.Int32?
```

The number of collections per page.

### `items`

```swift
public var items: [Components.Schemas.CollectionModel]?
```

The collections returned on the current page.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(totalItems:currentPage:itemsPerPage:items:additionalProperties:)`

```swift
public init(
    totalItems: Swift.Int64? = nil,
    currentPage: Swift.Int64? = nil,
    itemsPerPage: Swift.Int32? = nil,
    items: [Components.Schemas.CollectionModel]? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `PaginationListOfCollectionModel`.

- Parameters:
  - totalItems: The total number of collections available.
  - currentPage: The current page number.
  - itemsPerPage: The number of collections per page.
  - items: The collections returned on the current page.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| totalItems | The total number of collections available. |
| currentPage | The current page number. |
| itemsPerPage | The number of collections per page. |
| items | The collections returned on the current page. |
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