**STRUCT**

# `Schemas.ResolutionReference`

```swift
public struct ResolutionReference: Codable, Hashable, Sendable
```

Reference to a specific video resolution including its file path.

- Remark: Generated from `#/components/schemas/ResolutionReference`.

## Properties
### `resolution`

```swift
public var resolution: Swift.String?
```

The resolution (e.g., 720p, 1080p).

- Remark: Generated from `#/components/schemas/ResolutionReference/resolution`.

### `path`

```swift
public var path: Swift.String?
```

The file path associated with this resolution.

- Remark: Generated from `#/components/schemas/ResolutionReference/path`.

## Methods
### `init(resolution:path:)`

```swift
public init(
    resolution: Swift.String? = nil,
    path: Swift.String? = nil
)
```

Creates a new `ResolutionReference`.

- Parameters:
  - resolution: The resolution (e.g., 720p, 1080p).
  - path: The file path associated with this resolution.

#### Parameters

| Name | Description |
| ---- | ----------- |
| resolution | The resolution (e.g., 720p, 1080p). |
| path | The file path associated with this resolution. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |