**STRUCT**

# `Schemas.FetchVideoRequest`

```swift
public struct FetchVideoRequest: Codable, Hashable, Sendable
```

Schema for fetching a video from a remote URL. The 'url' field is required.

- Remark: Generated from `#/components/schemas/FetchVideoRequest`.

## Properties
### `url`

```swift
public var url: Swift.String
```

The URL from which to fetch the video.

- Remark: Generated from `#/components/schemas/FetchVideoRequest/url`.

### `headers`

```swift
public var headers: Components.Schemas.FetchVideoRequest.headersPayload?
```

Optional headers to include with the fetch request.

- Remark: Generated from `#/components/schemas/FetchVideoRequest/headers`.

### `title`

```swift
public var title: Swift.String?
```

Optional title to assign to the fetched video.

- Remark: Generated from `#/components/schemas/FetchVideoRequest/title`.

## Methods
### `init(url:headers:title:)`

```swift
public init(
    url: Swift.String,
    headers: Components.Schemas.FetchVideoRequest.headersPayload? = nil,
    title: Swift.String? = nil
)
```

Creates a new `FetchVideoRequest`.

- Parameters:
  - url: The URL from which to fetch the video.
  - headers: Optional headers to include with the fetch request.
  - title: Optional title to assign to the fetched video.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL from which to fetch the video. |
| headers | Optional headers to include with the fetch request. |
| title | Optional title to assign to the fetched video. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |