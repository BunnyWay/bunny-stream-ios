**STRUCT**

# `getCollection.Input`

```swift
public struct Input: Sendable, Hashable
```

## Properties
### `path`

```swift
public var path: Operations.getCollection.Input.Path
```

### `query`

```swift
public var query: Operations.getCollection.Input.Query
```

### `headers`

```swift
public var headers: Operations.getCollection.Input.Headers
```

## Methods
### `init(path:query:headers:)`

```swift
public init(
    path: Operations.getCollection.Input.Path,
    query: Operations.getCollection.Input.Query = .init(),
    headers: Operations.getCollection.Input.Headers = .init()
)
```

Creates a new `Input`.

- Parameters:
  - path:
  - query:
  - headers:

#### Parameters

| Name | Description |
| ---- | ----------- |
| path |  |
| query |  |
| headers |  |