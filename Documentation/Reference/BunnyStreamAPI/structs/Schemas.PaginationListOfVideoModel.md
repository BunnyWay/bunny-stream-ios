**STRUCT**

# `Schemas.PaginationListOfVideoModel`

```swift
public struct PaginationListOfVideoModel: Codable, Hashable, Sendable
```

A paginated list of videos.

- Remark: Generated from `#/components/schemas/PaginationListOfVideoModel`.

## Properties
### `totalItems`

```swift
public var totalItems: Swift.Int64?
```

The total number of videos available.

- Remark: Generated from `#/components/schemas/PaginationListOfVideoModel/totalItems`.

### `currentPage`

```swift
public var currentPage: Swift.Int64?
```

The current page number.

- Remark: Generated from `#/components/schemas/PaginationListOfVideoModel/currentPage`.

### `itemsPerPage`

```swift
public var itemsPerPage: Swift.Int32?
```

The number of videos per page.

- Remark: Generated from `#/components/schemas/PaginationListOfVideoModel/itemsPerPage`.

### `items`

```swift
public var items: [Components.Schemas.VideoModel]?
```

The videos returned on the current page.

- Remark: Generated from `#/components/schemas/PaginationListOfVideoModel/items`.

## Methods
### `init(totalItems:currentPage:itemsPerPage:items:)`

```swift
public init(
    totalItems: Swift.Int64? = nil,
    currentPage: Swift.Int64? = nil,
    itemsPerPage: Swift.Int32? = nil,
    items: [Components.Schemas.VideoModel]? = nil
)
```

Creates a new `PaginationListOfVideoModel`.

- Parameters:
  - totalItems: The total number of videos available.
  - currentPage: The current page number.
  - itemsPerPage: The number of videos per page.
  - items: The videos returned on the current page.

#### Parameters

| Name | Description |
| ---- | ----------- |
| totalItems | The total number of videos available. |
| currentPage | The current page number. |
| itemsPerPage | The number of videos per page. |
| items | The videos returned on the current page. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |