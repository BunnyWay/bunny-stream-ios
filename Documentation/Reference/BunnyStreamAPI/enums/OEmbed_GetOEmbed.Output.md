**ENUM**

# `OEmbed_GetOEmbed.Output`

```swift
@frozen public enum Output: Sendable, Hashable
```

## Cases
### `ok(_:)`

```swift
case ok(Operations.OEmbed_GetOEmbed.Output.Ok)
```

OEmbed data for the provided URL, including embed HTML and metadata.

- Remark: Generated from `#/paths//OEmbed/get(OEmbed_GetOEmbed)/responses/200`.

HTTP response code: `200 ok`.

### `undocumented(statusCode:_:)`

```swift
case undocumented(statusCode: Swift.Int, OpenAPIRuntime.UndocumentedPayload)
```

Undocumented response.

A response with a code that is not documented in the OpenAPI document.

## Properties
### `ok`

```swift
public var ok: Operations.OEmbed_GetOEmbed.Output.Ok
```

The associated value of the enum case if `self` is `.ok`.

- Throws: An error if `self` is not `.ok`.
- SeeAlso: `.ok`.
