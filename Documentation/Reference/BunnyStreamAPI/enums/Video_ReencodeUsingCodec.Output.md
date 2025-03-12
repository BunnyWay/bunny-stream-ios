**ENUM**

# `Video_ReencodeUsingCodec.Output`

```swift
@frozen public enum Output: Sendable, Hashable
```

## Cases
### `ok(_:)`

```swift
case ok(Operations.Video_ReencodeUsingCodec.Output.Ok)
```

The output codec was successfully added and the updated video details are returned.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/200`.

HTTP response code: `200 ok`.

### `badRequest(_:)`

```swift
case badRequest(Operations.Video_ReencodeUsingCodec.Output.BadRequest)
```

Invalid request or validation failed. Check the response for details.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/400`.

HTTP response code: `400 badRequest`.

### `unauthorized(_:)`

```swift
case unauthorized(Operations.Video_ReencodeUsingCodec.Output.Unauthorized)
```

The request authorization failed.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/401`.

HTTP response code: `401 unauthorized`.

### `notFound(_:)`

```swift
case notFound(Operations.Video_ReencodeUsingCodec.Output.NotFound)
```

The requested video was not found.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/404`.

HTTP response code: `404 notFound`.

### `internalServerError(_:)`

```swift
case internalServerError(Operations.Video_ReencodeUsingCodec.Output.InternalServerError)
```

Internal Server Error.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/500`.

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
public var ok: Operations.Video_ReencodeUsingCodec.Output.Ok
```

The associated value of the enum case if `self` is `.ok`.

- Throws: An error if `self` is not `.ok`.
- SeeAlso: `.ok`.

### `badRequest`

```swift
public var badRequest: Operations.Video_ReencodeUsingCodec.Output.BadRequest
```

The associated value of the enum case if `self` is `.badRequest`.

- Throws: An error if `self` is not `.badRequest`.
- SeeAlso: `.badRequest`.

### `unauthorized`

```swift
public static var unauthorized: Self
```

The request authorization failed.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/401`.

HTTP response code: `401 unauthorized`.

### `unauthorized`

```swift
public var unauthorized: Operations.Video_ReencodeUsingCodec.Output.Unauthorized
```

The associated value of the enum case if `self` is `.unauthorized`.

- Throws: An error if `self` is not `.unauthorized`.
- SeeAlso: `.unauthorized`.

### `notFound`

```swift
public static var notFound: Self
```

The requested video was not found.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/404`.

HTTP response code: `404 notFound`.

### `notFound`

```swift
public var notFound: Operations.Video_ReencodeUsingCodec.Output.NotFound
```

The associated value of the enum case if `self` is `.notFound`.

- Throws: An error if `self` is not `.notFound`.
- SeeAlso: `.notFound`.

### `internalServerError`

```swift
public static var internalServerError: Self
```

Internal Server Error.

- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)/responses/500`.

HTTP response code: `500 internalServerError`.

### `internalServerError`

```swift
public var internalServerError: Operations.Video_ReencodeUsingCodec.Output.InternalServerError
```

The associated value of the enum case if `self` is `.internalServerError`.

- Throws: An error if `self` is not `.internalServerError`.
- SeeAlso: `.internalServerError`.
