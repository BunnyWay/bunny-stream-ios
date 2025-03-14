**STRUCT**

# `Input.Query`

```swift
public struct Query: Sendable, Hashable
```

## Properties
### `url`

```swift
public var url: Swift.String?
```

The URL for which to retrieve OEmbed information.

### `maxWidth`

```swift
public var maxWidth: Swift.Int32?
```

Optional maximum width of the embed.

### `maxHeight`

```swift
public var maxHeight: Swift.Int32?
```

Optional maximum height of the embed.

### `token`

```swift
public var token: Swift.String?
```

Authentication token if required.

### `expires`

```swift
public var expires: Swift.Int64?
```

Expiration timestamp for the provided token.

## Methods
### `init(url:maxWidth:maxHeight:token:expires:)`

```swift
public init(
    url: Swift.String? = nil,
    maxWidth: Swift.Int32? = nil,
    maxHeight: Swift.Int32? = nil,
    token: Swift.String? = nil,
    expires: Swift.Int64? = nil
)
```

Creates a new `Query`.

- Parameters:
  - url: The URL for which to retrieve OEmbed information.
  - maxWidth: Optional maximum width of the embed.
  - maxHeight: Optional maximum height of the embed.
  - token: Authentication token if required.
  - expires: Expiration timestamp for the provided token.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL for which to retrieve OEmbed information. |
| maxWidth | Optional maximum width of the embed. |
| maxHeight | Optional maximum height of the embed. |
| token | Authentication token if required. |
| expires | Expiration timestamp for the provided token. |