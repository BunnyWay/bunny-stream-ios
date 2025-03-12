**STRUCT**

# `Schemas.PaginationListOfCollectionModel`

```swift
public struct PaginationListOfCollectionModel: Codable, Hashable, Sendable
```

A paginated list of collections.

- Remark: Generated from `#/components/schemas/PaginationListOfCollectionModel`.

## Properties
### `totalItems`

```swift
public var totalItems: Swift.Int64?
```

The total number of collections available.

- Remark: Generated from `#/components/schemas/PaginationListOfCollectionModel/totalItems`.

### `currentPage`

```swift
public var currentPage: Swift.Int64?
```

The current page number.

- Remark: Generated from `#/components/schemas/PaginationListOfCollectionModel/currentPage`.

### `itemsPerPage`

```swift
public var itemsPerPage: Swift.Int32?
```

The number of collections per page.

- Remark: Generated from `#/components/schemas/PaginationListOfCollectionModel/itemsPerPage`.

### `items`

```swift
public var items: [Components.Schemas.CollectionModel]?
```

The collections returned on the current page.

- Remark: Generated from `#/components/schemas/PaginationListOfCollectionModel/items`.

## Methods
### `init(totalItems:currentPage:itemsPerPage:items:)`

```swift
public init(
    totalItems: Swift.Int64? = nil,
    currentPage: Swift.Int64? = nil,
    itemsPerPage: Swift.Int32? = nil,
    items: [Components.Schemas.CollectionModel]? = nil
)
```

Creates a new `PaginationListOfCollectionModel`.

- Parameters:
  - totalItems: The total number of collections available.
  - currentPage: The current page number.
  - itemsPerPage: The number of collections per page.
  - items: The collections returned on the current page.

#### Parameters

| Name | Description |
| ---- | ----------- |
| totalItems | The total number of collections available. |
| currentPage | The current page number. |
| itemsPerPage | The number of collections per page. |
| items | The collections returned on the current page. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |