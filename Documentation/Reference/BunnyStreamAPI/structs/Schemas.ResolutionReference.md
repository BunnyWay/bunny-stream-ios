**STRUCT**

# `Schemas.ResolutionReference`

```swift
public struct ResolutionReference: Codable, Hashable, Sendable
```

Reference to a specific video resolution including its file path.

## Properties
### `resolution`

```swift
public var resolution: Swift.String?
```

The resolution (e.g., 720p, 1080p).

### `path`

```swift
public var path: Swift.String?
```

The file path associated with this resolution.

### `additionalProperties`

```swift
public var additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer
```

A container of undocumented properties.

## Methods
### `init(resolution:path:additionalProperties:)`

```swift
public init(
    resolution: Swift.String? = nil,
    path: Swift.String? = nil,
    additionalProperties: OpenAPIRuntime.OpenAPIObjectContainer = .init()
)
```

Creates a new `ResolutionReference`.

- Parameters:
  - resolution: The resolution (e.g., 720p, 1080p).
  - path: The file path associated with this resolution.
  - additionalProperties: A container of undocumented properties.

#### Parameters

| Name | Description |
| ---- | ----------- |
| resolution | The resolution (e.g., 720p, 1080p). |
| path | The file path associated with this resolution. |
| additionalProperties | A container of undocumented properties. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |

### `encode(to:)`

```swift
public func encode(to encoder: any Encoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| encoder | The encoder to write data to. |