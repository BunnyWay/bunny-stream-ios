**ENUM**

# `BadRequest.Body`

```swift
@frozen public enum Body: Sendable, Hashable
```

## Cases
### `json(_:)`

```swift
case json(Swift.String)
```

## Properties
### `json`

```swift
public var json: Swift.String
```

The associated value of the enum case if `self` is `.json`.

- Throws: An error if `self` is not `.json`.
- SeeAlso: `.json`.
