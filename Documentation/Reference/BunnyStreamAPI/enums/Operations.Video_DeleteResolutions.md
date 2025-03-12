**ENUM**

# `Operations.Video_DeleteResolutions`

```swift
public enum Video_DeleteResolutions
```

Cleanup Unconfigured Resolutions

Cleans up unconfigured resolutions for the specified video. Query parameters allow you to specify which resolutions to delete and whether to perform a dry run without actual file deletion.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/resolutions/cleanup`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/resolutions/cleanup/post(Video_DeleteResolutions)`.

## Properties
### `id`

```swift
public static let id: Swift.String = "Video_DeleteResolutions"
```
