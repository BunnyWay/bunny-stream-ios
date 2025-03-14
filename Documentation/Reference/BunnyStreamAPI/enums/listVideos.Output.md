**ENUM**

# `listVideos.Output`

```swift
@frozen public enum Output: Sendable, Hashable
```

## Cases
### `ok(_:)`

```swift
case ok(Operations.listVideos.Output.Ok)
```

A paginated list of videos matching the query parameters.

HTTP response code: `200 ok`.

### `unauthorized(_:)`

```swift
case unauthorized(Operations.listVideos.Output.Unauthorized)
```

The request authorization failed.

HTTP response code: `401 unauthorized`.

### `internalServerError(_:)`

```swift
case internalServerError(Operations.listVideos.Output.InternalServerError)
```

Internal Server Error.

HTTP response code: `500 internalServerError`.

### `undocumented(statusCode:_:)`

```swift
case undocumented(statusCode: Swift.Int, OpenAPIRuntime.UndocumentedPayload)
```

Undocumented response.

A response with a code that is not documented in the OpenAPI document.

## Properties
### `ok`

```swift
public var ok: Operations.listVideos.Output.Ok
```

The associated value of the enum case if `self` is `.ok`.

- Throws: An error if `self` is not `.ok`.
- SeeAlso: `.ok`.

### `unauthorized`

```swift
public static var unauthorized: Self
```

The request authorization failed.

HTTP response code: `401 unauthorized`.

### `unauthorized`

```swift
public var unauthorized: Operations.listVideos.Output.Unauthorized
```

The associated value of the enum case if `self` is `.unauthorized`.

- Throws: An error if `self` is not `.unauthorized`.
- SeeAlso: `.unauthorized`.

### `internalServerError`

```swift
public static var internalServerError: Self
```

Internal Server Error.

HTTP response code: `500 internalServerError`.

### `internalServerError`

```swift
public var internalServerError: Operations.listVideos.Output.InternalServerError
```

The associated value of the enum case if `self` is `.internalServerError`.

- Throws: An error if `self` is not `.internalServerError`.
- SeeAlso: `.internalServerError`.
