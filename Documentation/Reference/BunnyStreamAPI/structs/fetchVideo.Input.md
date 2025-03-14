**STRUCT**

# `fetchVideo.Input`

```swift
public struct Input: Sendable, Hashable
```

## Properties
### `path`

```swift
public var path: Operations.fetchVideo.Input.Path
```

### `query`

```swift
public var query: Operations.fetchVideo.Input.Query
```

### `headers`

```swift
public var headers: Operations.fetchVideo.Input.Headers
```

### `body`

```swift
public var body: Operations.fetchVideo.Input.Body
```

## Methods
### `init(path:query:headers:body:)`

```swift
public init(
    path: Operations.fetchVideo.Input.Path,
    query: Operations.fetchVideo.Input.Query = .init(),
    headers: Operations.fetchVideo.Input.Headers = .init(),
    body: Operations.fetchVideo.Input.Body
)
```

Creates a new `Input`.

- Parameters:
  - path:
  - query:
  - headers:
  - body:

#### Parameters

| Name | Description |
| ---- | ----------- |
| path |  |
| query |  |
| headers |  |
| body |  |