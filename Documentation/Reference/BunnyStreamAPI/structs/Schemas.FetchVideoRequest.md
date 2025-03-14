**STRUCT**

# `Schemas.FetchVideoRequest`

```swift
public struct FetchVideoRequest: Codable, Hashable, Sendable
```

Schema for fetching a video from a remote URL. The 'url' field is required.

## Properties
### `url`

```swift
public var url: Swift.String
```

The URL from which to fetch the video.

### `headers`

```swift
public var headers: Components.Schemas.FetchVideoRequest.HeadersPayload?
```

Optional headers to include with the fetch request.

### `title`

```swift
public var title: Swift.String?
```

Optional title to assign to the fetched video.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(url:headers:title:additionalProperties:)`

```swift
public init(
    url: Swift.String,
    headers: Components.Schemas.FetchVideoRequest.HeadersPayload? = nil,
    title: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `FetchVideoRequest`.

- Parameters:
  - url: The URL from which to fetch the video.
  - headers: Optional headers to include with the fetch request.
  - title: Optional title to assign to the fetched video.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL from which to fetch the video. |
| headers | Optional headers to include with the fetch request. |
| title | Optional title to assign to the fetched video. |
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