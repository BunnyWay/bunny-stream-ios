**ENUM**

# `Collection_CreateCollection.Output`

```swift
@frozen public enum Output: Sendable, Hashable
```

## Cases
### `ok(_:)`

```swift
case ok(Operations.Collection_CreateCollection.Output.Ok)
```

The collection was successfully created.

- Remark: Generated from `#/paths//library/{libraryId}/collections/post(Collection_CreateCollection)/responses/200`.

HTTP response code: `200 ok`.

### `unauthorized(_:)`

```swift
case unauthorized(Operations.Collection_CreateCollection.Output.Unauthorized)
```

The request authorization failed.

- Remark: Generated from `#/paths//library/{libraryId}/collections/post(Collection_CreateCollection)/responses/401`.

HTTP response code: `401 unauthorized`.

### `internalServerError(_:)`

```swift
case internalServerError(Operations.Collection_CreateCollection.Output.InternalServerError)
```

Internal Server Error.

- Remark: Generated from `#/paths//library/{libraryId}/collections/post(Collection_CreateCollection)/responses/500`.

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
public var ok: Operations.Collection_CreateCollection.Output.Ok
```

The associated value of the enum case if `self` is `.ok`.

- Throws: An error if `self` is not `.ok`.
- SeeAlso: `.ok`.

### `unauthorized`

```swift
public static var unauthorized: Self
```

The request authorization failed.

- Remark: Generated from `#/paths//library/{libraryId}/collections/post(Collection_CreateCollection)/responses/401`.

HTTP response code: `401 unauthorized`.

### `unauthorized`

```swift
public var unauthorized: Operations.Collection_CreateCollection.Output.Unauthorized
```

The associated value of the enum case if `self` is `.unauthorized`.

- Throws: An error if `self` is not `.unauthorized`.
- SeeAlso: `.unauthorized`.

### `internalServerError`

```swift
public static var internalServerError: Self
```

Internal Server Error.

- Remark: Generated from `#/paths//library/{libraryId}/collections/post(Collection_CreateCollection)/responses/500`.

HTTP response code: `500 internalServerError`.

### `internalServerError`

```swift
public var internalServerError: Operations.Collection_CreateCollection.Output.InternalServerError
```

The associated value of the enum case if `self` is `.internalServerError`.

- Throws: An error if `self` is not `.internalServerError`.
- SeeAlso: `.internalServerError`.
