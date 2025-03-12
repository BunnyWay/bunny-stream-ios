**ENUM**

# `Video_SetThumbnail.Output`

```swift
@frozen public enum Output: Sendable, Hashable
```

## Cases
### `ok(_:)`

```swift
case ok(Operations.Video_SetThumbnail.Output.Ok)
```

The thumbnail was successfully set.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)/responses/200`.

HTTP response code: `200 ok`.

### `unauthorized(_:)`

```swift
case unauthorized(Operations.Video_SetThumbnail.Output.Unauthorized)
```

The request authorization failed.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)/responses/401`.

HTTP response code: `401 unauthorized`.

### `notFound(_:)`

```swift
case notFound(Operations.Video_SetThumbnail.Output.NotFound)
```

The requested video was not found.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)/responses/404`.

HTTP response code: `404 notFound`.

### `internalServerError(_:)`

```swift
case internalServerError(Operations.Video_SetThumbnail.Output.InternalServerError)
```

Internal Server Error.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)/responses/500`.

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
public var ok: Operations.Video_SetThumbnail.Output.Ok
```

The associated value of the enum case if `self` is `.ok`.

- Throws: An error if `self` is not `.ok`.
- SeeAlso: `.ok`.

### `unauthorized`

```swift
public static var unauthorized: Self
```

The request authorization failed.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)/responses/401`.

HTTP response code: `401 unauthorized`.

### `unauthorized`

```swift
public var unauthorized: Operations.Video_SetThumbnail.Output.Unauthorized
```

The associated value of the enum case if `self` is `.unauthorized`.

- Throws: An error if `self` is not `.unauthorized`.
- SeeAlso: `.unauthorized`.

### `notFound`

```swift
public static var notFound: Self
```

The requested video was not found.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)/responses/404`.

HTTP response code: `404 notFound`.

### `notFound`

```swift
public var notFound: Operations.Video_SetThumbnail.Output.NotFound
```

The associated value of the enum case if `self` is `.notFound`.

- Throws: An error if `self` is not `.notFound`.
- SeeAlso: `.notFound`.

### `internalServerError`

```swift
public static var internalServerError: Self
```

Internal Server Error.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)/responses/500`.

HTTP response code: `500 internalServerError`.

### `internalServerError`

```swift
public var internalServerError: Operations.Video_SetThumbnail.Output.InternalServerError
```

The associated value of the enum case if `self` is `.internalServerError`.

- Throws: An error if `self` is not `.internalServerError`.
- SeeAlso: `.internalServerError`.
