**ENUM**

# `BadRequest.Body`

```swift
@frozen public enum Body: Sendable, Hashable
```

- Remark: Generated from `#/paths/library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/PUT/responses/400/content`.

## Cases
### `json(_:)`

```swift
case json(Swift.String)
```

- Remark: Generated from `#/paths/library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/PUT/responses/400/content/application\/json`.

## Properties
### `json`

```swift
public var json: Swift.String
```

The associated value of the enum case if `self` is `.json`.

- Throws: An error if `self` is not `.json`.
- SeeAlso: `.json`.
