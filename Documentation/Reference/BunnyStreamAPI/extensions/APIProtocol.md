**EXTENSION**

# `APIProtocol`
```swift
extension APIProtocol
```

## Methods
### `getCollection(path:query:headers:)`

```swift
public func getCollection(
    path: Operations.getCollection.Input.Path,
    query: Operations.getCollection.Input.Query = .init(),
    headers: Operations.getCollection.Input.Headers = .init()
) async throws -> Operations.getCollection.Output
```

Get Collection

Retrieves details of a specific collection. Use the query parameter 'includeThumbnails' to include preview images if available.

### `updateCollection(path:headers:body:)`

```swift
public func updateCollection(
    path: Operations.updateCollection.Input.Path,
    headers: Operations.updateCollection.Input.Headers = .init(),
    body: Operations.updateCollection.Input.Body
) async throws -> Operations.updateCollection.Output
```

Update Collection

Updates an existing collection. Provide the new collection details in the request body using the UpdateCollectionModel.

### `deleteCollection(path:headers:)`

```swift
public func deleteCollection(
    path: Operations.deleteCollection.Input.Path,
    headers: Operations.deleteCollection.Input.Headers = .init()
) async throws -> Operations.deleteCollection.Output
```

Delete Collection

Deletes the specified collection permanently from the video library.

### `listCollections(path:query:headers:)`

```swift
public func listCollections(
    path: Operations.listCollections.Input.Path,
    query: Operations.listCollections.Input.Query = .init(),
    headers: Operations.listCollections.Input.Headers = .init()
) async throws -> Operations.listCollections.Output
```

Get Collection List

Retrieves a paginated list of collections for the specified video library. Optional query parameters allow for filtering, pagination, and ordering the results.

### `createCollection(path:headers:body:)`

```swift
public func createCollection(
    path: Operations.createCollection.Input.Path,
    headers: Operations.createCollection.Input.Headers = .init(),
    body: Operations.createCollection.Input.Body
) async throws -> Operations.createCollection.Output
```

Create Collection

Creates a new collection in the specified video library using the provided collection details.

### `getVideo(path:headers:)`

```swift
public func getVideo(
    path: Operations.getVideo.Input.Path,
    headers: Operations.getVideo.Input.Headers = .init()
) async throws -> Operations.getVideo.Output
```

Get Video

Retrieves detailed metadata for the specified video, including status, dimensions, encoding progress, and more.

### `updateVideo(path:headers:body:)`

```swift
public func updateVideo(
    path: Operations.updateVideo.Input.Path,
    headers: Operations.updateVideo.Input.Headers = .init(),
    body: Operations.updateVideo.Input.Body
) async throws -> Operations.updateVideo.Output
```

Update Video

Updates metadata and other details for the specified video. Provide updated fields in the request body using the UpdateVideoModel.

### `uploadVideo(path:query:headers:)`

```swift
public func uploadVideo(
    path: Operations.uploadVideo.Input.Path,
    query: Operations.uploadVideo.Input.Query = .init(),
    headers: Operations.uploadVideo.Input.Headers = .init()
) async throws -> Operations.uploadVideo.Output
```

Upload Video

Uploads a new video file to the specified video library. Additional query parameters allow customization of encoding options such as JIT encoding, enabled resolutions, and output codecs.

### `deleteVideo(path:headers:)`

```swift
public func deleteVideo(
    path: Operations.deleteVideo.Input.Path,
    headers: Operations.deleteVideo.Input.Headers = .init()
) async throws -> Operations.deleteVideo.Output
```

Delete Video

Deletes the specified video permanently from the video library.

### `getVideoHeatmap(path:headers:)`

```swift
public func getVideoHeatmap(
    path: Operations.getVideoHeatmap.Input.Path,
    headers: Operations.getVideoHeatmap.Input.Headers = .init()
) async throws -> Operations.getVideoHeatmap.Output
```

Get Video Heatmap

Retrieves the heatmap data for the specified video, indicating the percentage of watch time across the video's duration.

### `getVideoPlayData(path:query:headers:)`

```swift
public func getVideoPlayData(
    path: Operations.getVideoPlayData.Input.Path,
    query: Operations.getVideoPlayData.Input.Query = .init(),
    headers: Operations.getVideoPlayData.Input.Headers = .init()
) async throws -> Operations.getVideoPlayData.Output
```

Get Video Play Data

Retrieves playback data for the specified video including video URLs, captions path, authentication tokens, and player settings.

### `getVideoStatistics(path:query:headers:)`

```swift
public func getVideoStatistics(
    path: Operations.getVideoStatistics.Input.Path,
    query: Operations.getVideoStatistics.Input.Query = .init(),
    headers: Operations.getVideoStatistics.Input.Headers = .init()
) async throws -> Operations.getVideoStatistics.Output
```

Get Video Statistics

Retrieves statistical data for videos in the specified library. Supports filtering by date range, hourly grouping, and filtering by video GUID.

### `reencodeVideo(path:headers:)`

```swift
public func reencodeVideo(
    path: Operations.reencodeVideo.Input.Path,
    headers: Operations.reencodeVideo.Input.Headers = .init()
) async throws -> Operations.reencodeVideo.Output
```

Reencode Video

Initiates a re-encoding process for the specified video. This operation can be used to adjust encoding settings or to fix issues with the original encoding.

### `reencodeUsingCodec(path:headers:)`

```swift
public func reencodeUsingCodec(
    path: Operations.reencodeUsingCodec.Input.Path,
    headers: Operations.reencodeUsingCodec.Input.Headers = .init()
) async throws -> Operations.reencodeUsingCodec.Output
```

Add output codec to video

Adds a specified output codec to the video. This enables additional encoding options for the video file.

### `repackageVideo(path:query:headers:)`

```swift
public func repackageVideo(
    path: Operations.repackageVideo.Input.Path,
    query: Operations.repackageVideo.Input.Query = .init(),
    headers: Operations.repackageVideo.Input.Headers = .init()
) async throws -> Operations.repackageVideo.Output
```

Repackage Video

Repackages the video, with an option to retain original files for faster future operations. This process may adjust resolution outputs and file formats.

### `listVideos(path:query:headers:)`

```swift
public func listVideos(
    path: Operations.listVideos.Input.Path,
    query: Operations.listVideos.Input.Query = .init(),
    headers: Operations.listVideos.Input.Headers = .init()
) async throws -> Operations.listVideos.Output
```

List Videos

Retrieves a paginated list of videos from the specified video library. Supports filtering by search term, collection, and ordering by date.

### `createVideo(path:headers:body:)`

```swift
public func createVideo(
    path: Operations.createVideo.Input.Path,
    headers: Operations.createVideo.Input.Headers = .init(),
    body: Operations.createVideo.Input.Body
) async throws -> Operations.createVideo.Output
```

Create Video

Creates a new video entry in the specified library. Provide the video details, such as title and optional thumbnail extraction time, in the request body.

### `setThumbnail(path:query:headers:)`

```swift
public func setThumbnail(
    path: Operations.setThumbnail.Input.Path,
    query: Operations.setThumbnail.Input.Query = .init(),
    headers: Operations.setThumbnail.Input.Headers = .init()
) async throws -> Operations.setThumbnail.Output
```

Set Thumbnail

Sets or updates the thumbnail image for the specified video using the provided thumbnail URL.

### `fetchVideo(path:query:headers:body:)`

```swift
public func fetchVideo(
    path: Operations.fetchVideo.Input.Path,
    query: Operations.fetchVideo.Input.Query = .init(),
    headers: Operations.fetchVideo.Input.Headers = .init(),
    body: Operations.fetchVideo.Input.Body
) async throws -> Operations.fetchVideo.Output
```

Fetch Video

Fetches a video from a remote URL and adds it to the specified library. Optional parameters allow you to specify a collection and the time (in ms) to extract a thumbnail.

### `addCaption(path:headers:body:)`

```swift
public func addCaption(
    path: Operations.addCaption.Input.Path,
    headers: Operations.addCaption.Input.Headers = .init(),
    body: Operations.addCaption.Input.Body
) async throws -> Operations.addCaption.Output
```

Add Caption

Adds caption data to the specified video for the given language. The caption file should be provided as a base64 encoded string.

### `deleteCaption(path:headers:)`

```swift
public func deleteCaption(
    path: Operations.deleteCaption.Input.Path,
    headers: Operations.deleteCaption.Input.Headers = .init()
) async throws -> Operations.deleteCaption.Output
```

Delete Caption

Deletes the caption for the specified language from the video.

### `transcribeVideo(path:query:headers:body:)`

```swift
public func transcribeVideo(
    path: Operations.transcribeVideo.Input.Path,
    query: Operations.transcribeVideo.Input.Query = .init(),
    headers: Operations.transcribeVideo.Input.Headers = .init(),
    body: Operations.transcribeVideo.Input.Body? = nil
) async throws -> Operations.transcribeVideo.Output
```

Transcribe Video

Initiates the transcription process for the specified video. You can optionally override the video library transcription settings using the provided request body.

### `getVideoResolutions(path:headers:)`

```swift
public func getVideoResolutions(
    path: Operations.getVideoResolutions.Input.Path,
    headers: Operations.getVideoResolutions.Input.Headers = .init()
) async throws -> Operations.getVideoResolutions.Output
```

Video Resolutions Info

Retrieves information about the available and configured resolutions for the specified video. This includes data on storage resolutions and MP4 fallback files if available.

### `deleteResolutions(path:query:headers:)`

```swift
public func deleteResolutions(
    path: Operations.deleteResolutions.Input.Path,
    query: Operations.deleteResolutions.Input.Query = .init(),
    headers: Operations.deleteResolutions.Input.Headers = .init()
) async throws -> Operations.deleteResolutions.Output
```

Cleanup Unconfigured Resolutions

Cleans up unconfigured resolutions for the specified video. Query parameters allow you to specify which resolutions to delete and whether to perform a dry run without actual file deletion.

### `getOEmbed(query:headers:)`

```swift
public func getOEmbed(
    query: Operations.getOEmbed.Input.Query = .init(),
    headers: Operations.getOEmbed.Input.Headers = .init()
) async throws -> Operations.getOEmbed.Output
```

Get OEmbed Data

Retrieves OEmbed information for a given video URL. This includes embed HTML, thumbnail URL, and metadata such as title and provider details.
