**STRUCT**

# `Input.Query`

```swift
public struct Query: Sendable, Hashable
```

- Remark: Generated from `#/paths/OEmbed/GET/query`.

## Properties
### `url`

```swift
public var url: Swift.String?
```

The URL for which to retrieve OEmbed information.

- Remark: Generated from `#/paths/OEmbed/GET/query/url`.

### `maxWidth`

```swift
public var maxWidth: Swift.Int32?
```

Optional maximum width of the embed.

- Remark: Generated from `#/paths/OEmbed/GET/query/maxWidth`.

### `maxHeight`

```swift
public var maxHeight: Swift.Int32?
```

Optional maximum height of the embed.

- Remark: Generated from `#/paths/OEmbed/GET/query/maxHeight`.

### `token`

```swift
public var token: Swift.String?
```

Authentication token if required.

- Remark: Generated from `#/paths/OEmbed/GET/query/token`.

### `expires`

```swift
public var expires: Swift.Int64?
```

Expiration timestamp for the provided token.

- Remark: Generated from `#/paths/OEmbed/GET/query/expires`.

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