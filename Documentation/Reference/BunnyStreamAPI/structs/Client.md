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

### `Collection_GetCollection(_:)`

```swift
public func Collection_GetCollection(_ input: Operations.Collection_GetCollection.Input) async throws -> Operations.Collection_GetCollection.Output
```

Get Collection

Retrieves details of a specific collection. Use the query parameter 'includeThumbnails' to include preview images if available.

- Remark: HTTP `GET /library/{libraryId}/collections/{collectionId}`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/{collectionId}/get(Collection_GetCollection)`.

### `Collection_UpdateCollection(_:)`

```swift
public func Collection_UpdateCollection(_ input: Operations.Collection_UpdateCollection.Input) async throws -> Operations.Collection_UpdateCollection.Output
```

Update Collection

Updates an existing collection. Provide the new collection details in the request body using the UpdateCollectionModel.

- Remark: HTTP `POST /library/{libraryId}/collections/{collectionId}`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/{collectionId}/post(Collection_UpdateCollection)`.

### `Collection_DeleteCollection(_:)`

```swift
public func Collection_DeleteCollection(_ input: Operations.Collection_DeleteCollection.Input) async throws -> Operations.Collection_DeleteCollection.Output
```

Delete Collection

Deletes the specified collection permanently from the video library.

- Remark: HTTP `DELETE /library/{libraryId}/collections/{collectionId}`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/{collectionId}/delete(Collection_DeleteCollection)`.

### `Collection_List(_:)`

```swift
public func Collection_List(_ input: Operations.Collection_List.Input) async throws -> Operations.Collection_List.Output
```

Get Collection List

Retrieves a paginated list of collections for the specified video library. Optional query parameters allow for filtering, pagination, and ordering the results.

- Remark: HTTP `GET /library/{libraryId}/collections`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/get(Collection_List)`.

### `Collection_CreateCollection(_:)`

```swift
public func Collection_CreateCollection(_ input: Operations.Collection_CreateCollection.Input) async throws -> Operations.Collection_CreateCollection.Output
```

Create Collection

Creates a new collection in the specified video library using the provided collection details.

- Remark: HTTP `POST /library/{libraryId}/collections`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/post(Collection_CreateCollection)`.

### `Video_GetVideo(_:)`

```swift
public func Video_GetVideo(_ input: Operations.Video_GetVideo.Input) async throws -> Operations.Video_GetVideo.Output
```

Get Video

Retrieves detailed metadata for the specified video, including status, dimensions, encoding progress, and more.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/get(Video_GetVideo)`.

### `Video_UpdateVideo(_:)`

```swift
public func Video_UpdateVideo(_ input: Operations.Video_UpdateVideo.Input) async throws -> Operations.Video_UpdateVideo.Output
```

Update Video

Updates metadata and other details for the specified video. Provide updated fields in the request body using the UpdateVideoModel.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/post(Video_UpdateVideo)`.

### `Video_UploadVideo(_:)`

```swift
public func Video_UploadVideo(_ input: Operations.Video_UploadVideo.Input) async throws -> Operations.Video_UploadVideo.Output
```

Upload Video

Uploads a new video file to the specified video library. Additional query parameters allow customization of encoding options such as JIT encoding, enabled resolutions, and output codecs.

- Remark: HTTP `PUT /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/put(Video_UploadVideo)`.

### `Video_DeleteVideo(_:)`

```swift
public func Video_DeleteVideo(_ input: Operations.Video_DeleteVideo.Input) async throws -> Operations.Video_DeleteVideo.Output
```

Delete Video

Deletes the specified video permanently from the video library.

- Remark: HTTP `DELETE /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/delete(Video_DeleteVideo)`.

### `Video_GetVideoHeatmap(_:)`

```swift
public func Video_GetVideoHeatmap(_ input: Operations.Video_GetVideoHeatmap.Input) async throws -> Operations.Video_GetVideoHeatmap.Output
```

Get Video Heatmap

Retrieves the heatmap data for the specified video, indicating the percentage of watch time across the video's duration.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}/heatmap`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/heatmap/get(Video_GetVideoHeatmap)`.

### `Video_GetVideoPlayData(_:)`

```swift
public func Video_GetVideoPlayData(_ input: Operations.Video_GetVideoPlayData.Input) async throws -> Operations.Video_GetVideoPlayData.Output
```

Get Video Play Data

Retrieves playback data for the specified video including video URLs, captions path, authentication tokens, and player settings.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}/play`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/play/get(Video_GetVideoPlayData)`.

### `Video_GetVideoStatistics(_:)`

```swift
public func Video_GetVideoStatistics(_ input: Operations.Video_GetVideoStatistics.Input) async throws -> Operations.Video_GetVideoStatistics.Output
```

Get Video Statistics

Retrieves statistical data for videos in the specified library. Supports filtering by date range, hourly grouping, and filtering by video GUID.

- Remark: HTTP `GET /library/{libraryId}/statistics`.
- Remark: Generated from `#/paths//library/{libraryId}/statistics/get(Video_GetVideoStatistics)`.

### `Video_ReencodeVideo(_:)`

```swift
public func Video_ReencodeVideo(_ input: Operations.Video_ReencodeVideo.Input) async throws -> Operations.Video_ReencodeVideo.Output
```

Reencode Video

Initiates a re-encoding process for the specified video. This operation can be used to adjust encoding settings or to fix issues with the original encoding.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/reencode`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/reencode/post(Video_ReencodeVideo)`.

### `Video_ReencodeUsingCodec(_:)`

```swift
public func Video_ReencodeUsingCodec(_ input: Operations.Video_ReencodeUsingCodec.Input) async throws -> Operations.Video_ReencodeUsingCodec.Output
```

Add output codec to video

Adds a specified output codec to the video. This enables additional encoding options for the video file.

- Remark: HTTP `PUT /library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)`.

### `Video_Repackage(_:)`

```swift
public func Video_Repackage(_ input: Operations.Video_Repackage.Input) async throws -> Operations.Video_Repackage.Output
```

Repackage Video

Repackages the video, with an option to retain original files for faster future operations. This process may adjust resolution outputs and file formats.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/repackage`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/repackage/post(Video_Repackage)`.

### `Video_List(_:)`

```swift
public func Video_List(_ input: Operations.Video_List.Input) async throws -> Operations.Video_List.Output
```

List Videos

Retrieves a paginated list of videos from the specified video library. Supports filtering by search term, collection, and ordering by date.

- Remark: HTTP `GET /library/{libraryId}/videos`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/get(Video_List)`.

### `Video_CreateVideo(_:)`

```swift
public func Video_CreateVideo(_ input: Operations.Video_CreateVideo.Input) async throws -> Operations.Video_CreateVideo.Output
```

Create Video

Creates a new video entry in the specified library. Provide the video details, such as title and optional thumbnail extraction time, in the request body.

- Remark: HTTP `POST /library/{libraryId}/videos`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/post(Video_CreateVideo)`.

### `Video_SetThumbnail(_:)`

```swift
public func Video_SetThumbnail(_ input: Operations.Video_SetThumbnail.Input) async throws -> Operations.Video_SetThumbnail.Output
```

Set Thumbnail

Sets or updates the thumbnail image for the specified video using the provided thumbnail URL.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/thumbnail`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)`.

### `Video_FetchNewVideo(_:)`

```swift
public func Video_FetchNewVideo(_ input: Operations.Video_FetchNewVideo.Input) async throws -> Operations.Video_FetchNewVideo.Output
```

Fetch Video

Fetches a video from a remote URL and adds it to the specified library. Optional parameters allow you to specify a collection and the time (in ms) to extract a thumbnail.

- Remark: HTTP `POST /library/{libraryId}/videos/fetch`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/fetch/post(Video_FetchNewVideo)`.

### `Video_AddCaption(_:)`

```swift
public func Video_AddCaption(_ input: Operations.Video_AddCaption.Input) async throws -> Operations.Video_AddCaption.Output
```

Add Caption

Adds caption data to the specified video for the given language. The caption file should be provided as a base64 encoded string.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/captions/{srclang}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/captions/{srclang}/post(Video_AddCaption)`.

### `Video_DeleteCaption(_:)`

```swift
public func Video_DeleteCaption(_ input: Operations.Video_DeleteCaption.Input) async throws -> Operations.Video_DeleteCaption.Output
```

Delete Caption

Deletes the caption for the specified language from the video.

- Remark: HTTP `DELETE /library/{libraryId}/videos/{videoId}/captions/{srclang}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/captions/{srclang}/delete(Video_DeleteCaption)`.

### `Video_TranscribeVideo(_:)`

```swift
public func Video_TranscribeVideo(_ input: Operations.Video_TranscribeVideo.Input) async throws -> Operations.Video_TranscribeVideo.Output
```

Transcribe Video

Initiates the transcription process for the specified video. You can optionally override the video library transcription settings using the provided request body.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/transcribe`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/transcribe/post(Video_TranscribeVideo)`.

### `Video_GetVideoResolutions(_:)`

```swift
public func Video_GetVideoResolutions(_ input: Operations.Video_GetVideoResolutions.Input) async throws -> Operations.Video_GetVideoResolutions.Output
```

Video Resolutions Info

Retrieves information about the available and configured resolutions for the specified video. This includes data on storage resolutions and MP4 fallback files if available.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}/resolutions`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/resolutions/get(Video_GetVideoResolutions)`.

### `Video_DeleteResolutions(_:)`

```swift
public func Video_DeleteResolutions(_ input: Operations.Video_DeleteResolutions.Input) async throws -> Operations.Video_DeleteResolutions.Output
```

Cleanup Unconfigured Resolutions

Cleans up unconfigured resolutions for the specified video. Query parameters allow you to specify which resolutions to delete and whether to perform a dry run without actual file deletion.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/resolutions/cleanup`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/resolutions/cleanup/post(Video_DeleteResolutions)`.

### `OEmbed_GetOEmbed(_:)`

```swift
public func OEmbed_GetOEmbed(_ input: Operations.OEmbed_GetOEmbed.Input) async throws -> Operations.OEmbed_GetOEmbed.Output
```

Get OEmbed Data

Retrieves OEmbed information for a given video URL. This includes embed HTML, thumbnail URL, and metadata such as title and provider details.

- Remark: HTTP `GET /OEmbed`.
- Remark: Generated from `#/paths//OEmbed/get(OEmbed_GetOEmbed)`.
