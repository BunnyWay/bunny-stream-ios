**STRUCT**

# `listCollections.Input`

```swift
public struct Input: Sendable, Hashable
```

## Properties
### `path`

```swift
public var path: Operations.listCollections.Input.Path
```

### `query`

```swift
public var query: Operations.listCollections.Input.Query
```

### `headers`

```swift
public var headers: Operations.listCollections.Input.Headers
```

## Methods
### `init(path:query:headers:)`

```swift
public init(
    path: Operations.listCollections.Input.Path,
    query: Operations.listCollections.Input.Query = .init(),
    headers: Operations.listCollections.Input.Headers = .init()
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