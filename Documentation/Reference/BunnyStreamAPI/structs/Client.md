**STRUCT**

# `Client`

```swift
public struct Client: APIProtocol
```

This API allows you to manage video collections and videos on the Bunny Stream platform. It supports operations such as retrieval, creation, updating, deletion, fetching, and transcoding of collections and videos. For further details, please refer to the external documentation.

## Methods
### `init(serverURL:configuration:transport:middlewares:)`

```swift
public init(
    serverURL: Foundation.URL,
    configuration: Configuration = .init(),
    transport: any ClientTransport,
    middlewares: [any ClientMiddleware] = []
)
```

Creates a new client.
- Parameters:
  - serverURL: The server URL that the client connects to. Any server
  URLs defined in the OpenAPI document are available as static methods
  on the ``Servers`` type.
  - configuration: A set of configuration values for the client.
  - transport: A transport that performs HTTP operations.
  - middlewares: A list of middlewares to call before the transport.

#### Parameters

| Name | Description |
| ---- | ----------- |
| serverURL | The server URL that the client connects to. Any server URLs defined in the OpenAPI document are available as static methods on the `Servers` type. |
| configuration | A set of configuration values for the client. |
| transport | A transport that performs HTTP operations. |
| middlewares | A list of middlewares to call before the transport. |

### `getCollection(_:)`

```swift
public func getCollection(_ input: Operations.getCollection.Input) async throws -> Operations.getCollection.Output
```

Get Collection

Retrieves details of a specific collection. Use the query parameter 'includeThumbnails' to include preview images if available.

### `updateCollection(_:)`

```swift
public func updateCollection(_ input: Operations.updateCollection.Input) async throws -> Operations.updateCollection.Output
```

Update Collection

Updates an existing collection. Provide the new collection details in the request body using the UpdateCollectionModel.

### `deleteCollection(_:)`

```swift
public func deleteCollection(_ input: Operations.deleteCollection.Input) async throws -> Operations.deleteCollection.Output
```

Delete Collection

Deletes the specified collection permanently from the video library.

### `listCollections(_:)`

```swift
public func listCollections(_ input: Operations.listCollections.Input) async throws -> Operations.listCollections.Output
```

Get Collection List

Retrieves a paginated list of collections for the specified video library. Optional query parameters allow for filtering, pagination, and ordering the results.

### `createCollection(_:)`

```swift
public func createCollection(_ input: Operations.createCollection.Input) async throws -> Operations.createCollection.Output
```

Create Collection

Creates a new collection in the specified video library using the provided collection details.

### `getVideo(_:)`

```swift
public func getVideo(_ input: Operations.getVideo.Input) async throws -> Operations.getVideo.Output
```

Get Video

Retrieves detailed metadata for the specified video, including status, dimensions, encoding progress, and more.

### `updateVideo(_:)`

```swift
public func updateVideo(_ input: Operations.updateVideo.Input) async throws -> Operations.updateVideo.Output
```

Update Video

Updates metadata and other details for the specified video. Provide updated fields in the request body using the UpdateVideoModel.

### `uploadVideo(_:)`

```swift
public func uploadVideo(_ input: Operations.uploadVideo.Input) async throws -> Operations.uploadVideo.Output
```

Upload Video

Uploads a new video file to the specified video library. Additional query parameters allow customization of encoding options such as JIT encoding, enabled resolutions, and output codecs.

### `deleteVideo(_:)`

```swift
public func deleteVideo(_ input: Operations.deleteVideo.Input) async throws -> Operations.deleteVideo.Output
```

Delete Video

Deletes the specified video permanently from the video library.

### `getVideoHeatmap(_:)`

```swift
public func getVideoHeatmap(_ input: Operations.getVideoHeatmap.Input) async throws -> Operations.getVideoHeatmap.Output
```

Get Video Heatmap

Retrieves the heatmap data for the specified video, indicating the percentage of watch time across the video's duration.

### `getVideoPlayData(_:)`

```swift
public func getVideoPlayData(_ input: Operations.getVideoPlayData.Input) async throws -> Operations.getVideoPlayData.Output
```

Get Video Play Data

Retrieves playback data for the specified video including video URLs, captions path, authentication tokens, and player settings.

### `getVideoStatistics(_:)`

```swift
public func getVideoStatistics(_ input: Operations.getVideoStatistics.Input) async throws -> Operations.getVideoStatistics.Output
```

Get Video Statistics

Retrieves statistical data for videos in the specified library. Supports filtering by date range, hourly grouping, and filtering by video GUID.

### `reencodeVideo(_:)`

```swift
public func reencodeVideo(_ input: Operations.reencodeVideo.Input) async throws -> Operations.reencodeVideo.Output
```

Reencode Video

Initiates a re-encoding process for the specified video. This operation can be used to adjust encoding settings or to fix issues with the original encoding.

### `reencodeUsingCodec(_:)`

```swift
public func reencodeUsingCodec(_ input: Operations.reencodeUsingCodec.Input) async throws -> Operations.reencodeUsingCodec.Output
```

Add output codec to video

Adds a specified output codec to the video. This enables additional encoding options for the video file.

### `repackageVideo(_:)`

```swift
public func repackageVideo(_ input: Operations.repackageVideo.Input) async throws -> Operations.repackageVideo.Output
```

Repackage Video

Repackages the video, with an option to retain original files for faster future operations. This process may adjust resolution outputs and file formats.

### `listVideos(_:)`

```swift
public func listVideos(_ input: Operations.listVideos.Input) async throws -> Operations.listVideos.Output
```

List Videos

Retrieves a paginated list of videos from the specified video library. Supports filtering by search term, collection, and ordering by date.

### `createVideo(_:)`

```swift
public func createVideo(_ input: Operations.createVideo.Input) async throws -> Operations.createVideo.Output
```

Create Video

Creates a new video entry in the specified library. Provide the video details, such as title and optional thumbnail extraction time, in the request body.

### `setThumbnail(_:)`

```swift
public func setThumbnail(_ input: Operations.setThumbnail.Input) async throws -> Operations.setThumbnail.Output
```

Set Thumbnail

Sets or updates the thumbnail image for the specified video using the provided thumbnail URL.

### `fetchVideo(_:)`

```swift
public func fetchVideo(_ input: Operations.fetchVideo.Input) async throws -> Operations.fetchVideo.Output
```

Fetch Video

Fetches a video from a remote URL and adds it to the specified library. Optional parameters allow you to specify a collection and the time (in ms) to extract a thumbnail.

### `addCaption(_:)`

```swift
public func addCaption(_ input: Operations.addCaption.Input) async throws -> Operations.addCaption.Output
```

Add Caption

Adds caption data to the specified video for the given language. The caption file should be provided as a base64 encoded string.

### `deleteCaption(_:)`

```swift
public func deleteCaption(_ input: Operations.deleteCaption.Input) async throws -> Operations.deleteCaption.Output
```

Delete Caption

Deletes the caption for the specified language from the video.

### `transcribeVideo(_:)`

```swift
public func transcribeVideo(_ input: Operations.transcribeVideo.Input) async throws -> Operations.transcribeVideo.Output
```

Transcribe Video

Initiates the transcription process for the specified video. You can optionally override the video library transcription settings using the provided request body.

### `getVideoResolutions(_:)`

```swift
public func getVideoResolutions(_ input: Operations.getVideoResolutions.Input) async throws -> Operations.getVideoResolutions.Output
```

Video Resolutions Info

Retrieves information about the available and configured resolutions for the specified video. This includes data on storage resolutions and MP4 fallback files if available.

### `deleteResolutions(_:)`

```swift
public func deleteResolutions(_ input: Operations.deleteResolutions.Input) async throws -> Operations.deleteResolutions.Output
```

Cleanup Unconfigured Resolutions

Cleans up unconfigured resolutions for the specified video. Query parameters allow you to specify which resolutions to delete and whether to perform a dry run without actual file deletion.

### `getOEmbed(_:)`

```swift
public func getOEmbed(_ input: Operations.getOEmbed.Input) async throws -> Operations.getOEmbed.Output
```

Get OEmbed Data

Retrieves OEmbed information for a given video URL. This includes embed HTML, thumbnail URL, and metadata such as title and provider details.
