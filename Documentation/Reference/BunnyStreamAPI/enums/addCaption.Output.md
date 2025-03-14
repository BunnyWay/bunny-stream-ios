**ENUM**

# `addCaption.Output`

```swift
@frozen public enum Output: Sendable, Hashable
```

## Cases
### `ok(_:)`

```swift
case ok(Operations.addCaption.Output.Ok)
```

The caption was successfully uploaded.

HTTP response code: `200 ok`.

### `badRequest(_:)`

```swift
case badRequest(Operations.addCaption.Output.BadRequest)
```

Failed uploading the captions.

HTTP response code: `400 badRequest`.

### `unauthorized(_:)`

```swift
case unauthorized(Operations.addCaption.Output.Unauthorized)
```

The request authorization failed.

HTTP response code: `401 unauthorized`.

### `notFound(_:)`

```swift
case notFound(Operations.addCaption.Output.NotFound)
```

The requested video was not found.

HTTP response code: `404 notFound`.

### `internalServerError(_:)`

```swift
case internalServerError(Operations.addCaption.Output.InternalServerError)
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
public var ok: Operations.addCaption.Output.Ok
```

The associated value of the enum case if `self` is `.ok`.

- Throws: An error if `self` is not `.ok`.
- SeeAlso: `.ok`.

### `badRequest`

```swift
public static var badRequest: Self
```

Failed uploading the captions.

HTTP response code: `400 badRequest`.

### `badRequest`

```swift
public var badRequest: Operations.addCaption.Output.BadRequest
```

The associated value of the enum case if `self` is `.badRequest`.

- Throws: An error if `self` is not `.badRequest`.
- SeeAlso: `.badRequest`.

### `unauthorized`

```swift
public static var unauthorized: Self
```

The request authorization failed.

HTTP response code: `401 unauthorized`.

### `unauthorized`

```swift
public var unauthorized: Operations.addCaption.Output.Unauthorized
```

The associated value of the enum case if `self` is `.unauthorized`.

- Throws: An error if `self` is not `.unauthorized`.
- SeeAlso: `.unauthorized`.

### `notFound`

```swift
public static var notFound: Self
```

The requested video was not found.

HTTP response code: `404 notFound`.

### `notFound`

```swift
public var notFound: Operations.addCaption.Output.NotFound
```

The associated value of the enum case if `self` is `.notFound`.

- Throws: An error if `self` is not `.notFound`.
- SeeAlso: `.notFound`.

### `internalServerError`

```swift
public static var internalServerError: Self
```

Internal Server Error.

HTTP response code: `500 internalServerError`.

### `internalServerError`

```swift
public var internalServerError: Operations.addCaption.Output.InternalServerError
```

The associated value of the enum case if `self` is `.internalServerError`.

- Throws: An error if `self` is not `.internalServerError`.
- SeeAlso: `.internalServerError`.
