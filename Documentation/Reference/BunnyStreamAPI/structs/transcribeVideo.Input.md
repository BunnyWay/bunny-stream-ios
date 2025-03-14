**STRUCT**

# `transcribeVideo.Input`

```swift
public struct Input: Sendable, Hashable
```

## Properties
### `path`

```swift
public var path: Operations.transcribeVideo.Input.Path
```

### `query`

```swift
public var query: Operations.transcribeVideo.Input.Query
```

### `headers`

```swift
public var headers: Operations.transcribeVideo.Input.Headers
```

### `body`

```swift
public var body: Operations.transcribeVideo.Input.Body?
```

## Methods
### `init(path:query:headers:body:)`

```swift
public init(
    path: Operations.transcribeVideo.Input.Path,
    query: Operations.transcribeVideo.Input.Query = .init(),
    headers: Operations.transcribeVideo.Input.Headers = .init(),
    body: Operations.transcribeVideo.Input.Body? = nil
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