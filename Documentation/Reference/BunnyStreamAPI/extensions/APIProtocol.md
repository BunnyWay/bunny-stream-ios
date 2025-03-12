**EXTENSION**

# `APIProtocol`
```swift
extension APIProtocol
```

## Methods
### `Collection_GetCollection(path:query:headers:)`

```swift
public func Collection_GetCollection(
    path: Operations.Collection_GetCollection.Input.Path,
    query: Operations.Collection_GetCollection.Input.Query = .init(),
    headers: Operations.Collection_GetCollection.Input.Headers = .init()
) async throws -> Operations.Collection_GetCollection.Output
```

Get Collection

Retrieves details of a specific collection. Use the query parameter 'includeThumbnails' to include preview images if available.

- Remark: HTTP `GET /library/{libraryId}/collections/{collectionId}`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/{collectionId}/get(Collection_GetCollection)`.

### `Collection_UpdateCollection(path:headers:body:)`

```swift
public func Collection_UpdateCollection(
    path: Operations.Collection_UpdateCollection.Input.Path,
    headers: Operations.Collection_UpdateCollection.Input.Headers = .init(),
    body: Operations.Collection_UpdateCollection.Input.Body
) async throws -> Operations.Collection_UpdateCollection.Output
```

Update Collection

Updates an existing collection. Provide the new collection details in the request body using the UpdateCollectionModel.

- Remark: HTTP `POST /library/{libraryId}/collections/{collectionId}`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/{collectionId}/post(Collection_UpdateCollection)`.

### `Collection_DeleteCollection(path:headers:)`

```swift
public func Collection_DeleteCollection(
    path: Operations.Collection_DeleteCollection.Input.Path,
    headers: Operations.Collection_DeleteCollection.Input.Headers = .init()
) async throws -> Operations.Collection_DeleteCollection.Output
```

Delete Collection

Deletes the specified collection permanently from the video library.

- Remark: HTTP `DELETE /library/{libraryId}/collections/{collectionId}`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/{collectionId}/delete(Collection_DeleteCollection)`.

### `Collection_List(path:query:headers:)`

```swift
public func Collection_List(
    path: Operations.Collection_List.Input.Path,
    query: Operations.Collection_List.Input.Query = .init(),
    headers: Operations.Collection_List.Input.Headers = .init()
) async throws -> Operations.Collection_List.Output
```

Get Collection List

Retrieves a paginated list of collections for the specified video library. Optional query parameters allow for filtering, pagination, and ordering the results.

- Remark: HTTP `GET /library/{libraryId}/collections`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/get(Collection_List)`.

### `Collection_CreateCollection(path:headers:body:)`

```swift
public func Collection_CreateCollection(
    path: Operations.Collection_CreateCollection.Input.Path,
    headers: Operations.Collection_CreateCollection.Input.Headers = .init(),
    body: Operations.Collection_CreateCollection.Input.Body
) async throws -> Operations.Collection_CreateCollection.Output
```

Create Collection

Creates a new collection in the specified video library using the provided collection details.

- Remark: HTTP `POST /library/{libraryId}/collections`.
- Remark: Generated from `#/paths//library/{libraryId}/collections/post(Collection_CreateCollection)`.

### `Video_GetVideo(path:headers:)`

```swift
public func Video_GetVideo(
    path: Operations.Video_GetVideo.Input.Path,
    headers: Operations.Video_GetVideo.Input.Headers = .init()
) async throws -> Operations.Video_GetVideo.Output
```

Get Video

Retrieves detailed metadata for the specified video, including status, dimensions, encoding progress, and more.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/get(Video_GetVideo)`.

### `Video_UpdateVideo(path:headers:body:)`

```swift
public func Video_UpdateVideo(
    path: Operations.Video_UpdateVideo.Input.Path,
    headers: Operations.Video_UpdateVideo.Input.Headers = .init(),
    body: Operations.Video_UpdateVideo.Input.Body
) async throws -> Operations.Video_UpdateVideo.Output
```

Update Video

Updates metadata and other details for the specified video. Provide updated fields in the request body using the UpdateVideoModel.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/post(Video_UpdateVideo)`.

### `Video_UploadVideo(path:query:headers:)`

```swift
public func Video_UploadVideo(
    path: Operations.Video_UploadVideo.Input.Path,
    query: Operations.Video_UploadVideo.Input.Query = .init(),
    headers: Operations.Video_UploadVideo.Input.Headers = .init()
) async throws -> Operations.Video_UploadVideo.Output
```

Upload Video

Uploads a new video file to the specified video library. Additional query parameters allow customization of encoding options such as JIT encoding, enabled resolutions, and output codecs.

- Remark: HTTP `PUT /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/put(Video_UploadVideo)`.

### `Video_DeleteVideo(path:headers:)`

```swift
public func Video_DeleteVideo(
    path: Operations.Video_DeleteVideo.Input.Path,
    headers: Operations.Video_DeleteVideo.Input.Headers = .init()
) async throws -> Operations.Video_DeleteVideo.Output
```

Delete Video

Deletes the specified video permanently from the video library.

- Remark: HTTP `DELETE /library/{libraryId}/videos/{videoId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/delete(Video_DeleteVideo)`.

### `Video_GetVideoHeatmap(path:headers:)`

```swift
public func Video_GetVideoHeatmap(
    path: Operations.Video_GetVideoHeatmap.Input.Path,
    headers: Operations.Video_GetVideoHeatmap.Input.Headers = .init()
) async throws -> Operations.Video_GetVideoHeatmap.Output
```

Get Video Heatmap

Retrieves the heatmap data for the specified video, indicating the percentage of watch time across the video's duration.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}/heatmap`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/heatmap/get(Video_GetVideoHeatmap)`.

### `Video_GetVideoPlayData(path:query:headers:)`

```swift
public func Video_GetVideoPlayData(
    path: Operations.Video_GetVideoPlayData.Input.Path,
    query: Operations.Video_GetVideoPlayData.Input.Query = .init(),
    headers: Operations.Video_GetVideoPlayData.Input.Headers = .init()
) async throws -> Operations.Video_GetVideoPlayData.Output
```

Get Video Play Data

Retrieves playback data for the specified video including video URLs, captions path, authentication tokens, and player settings.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}/play`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/play/get(Video_GetVideoPlayData)`.

### `Video_GetVideoStatistics(path:query:headers:)`

```swift
public func Video_GetVideoStatistics(
    path: Operations.Video_GetVideoStatistics.Input.Path,
    query: Operations.Video_GetVideoStatistics.Input.Query = .init(),
    headers: Operations.Video_GetVideoStatistics.Input.Headers = .init()
) async throws -> Operations.Video_GetVideoStatistics.Output
```

Get Video Statistics

Retrieves statistical data for videos in the specified library. Supports filtering by date range, hourly grouping, and filtering by video GUID.

- Remark: HTTP `GET /library/{libraryId}/statistics`.
- Remark: Generated from `#/paths//library/{libraryId}/statistics/get(Video_GetVideoStatistics)`.

### `Video_ReencodeVideo(path:headers:)`

```swift
public func Video_ReencodeVideo(
    path: Operations.Video_ReencodeVideo.Input.Path,
    headers: Operations.Video_ReencodeVideo.Input.Headers = .init()
) async throws -> Operations.Video_ReencodeVideo.Output
```

Reencode Video

Initiates a re-encoding process for the specified video. This operation can be used to adjust encoding settings or to fix issues with the original encoding.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/reencode`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/reencode/post(Video_ReencodeVideo)`.

### `Video_ReencodeUsingCodec(path:headers:)`

```swift
public func Video_ReencodeUsingCodec(
    path: Operations.Video_ReencodeUsingCodec.Input.Path,
    headers: Operations.Video_ReencodeUsingCodec.Input.Headers = .init()
) async throws -> Operations.Video_ReencodeUsingCodec.Output
```

Add output codec to video

Adds a specified output codec to the video. This enables additional encoding options for the video file.

- Remark: HTTP `PUT /library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}/put(Video_ReencodeUsingCodec)`.

### `Video_Repackage(path:query:headers:)`

```swift
public func Video_Repackage(
    path: Operations.Video_Repackage.Input.Path,
    query: Operations.Video_Repackage.Input.Query = .init(),
    headers: Operations.Video_Repackage.Input.Headers = .init()
) async throws -> Operations.Video_Repackage.Output
```

Repackage Video

Repackages the video, with an option to retain original files for faster future operations. This process may adjust resolution outputs and file formats.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/repackage`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/repackage/post(Video_Repackage)`.

### `Video_List(path:query:headers:)`

```swift
public func Video_List(
    path: Operations.Video_List.Input.Path,
    query: Operations.Video_List.Input.Query = .init(),
    headers: Operations.Video_List.Input.Headers = .init()
) async throws -> Operations.Video_List.Output
```

List Videos

Retrieves a paginated list of videos from the specified video library. Supports filtering by search term, collection, and ordering by date.

- Remark: HTTP `GET /library/{libraryId}/videos`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/get(Video_List)`.

### `Video_CreateVideo(path:headers:body:)`

```swift
public func Video_CreateVideo(
    path: Operations.Video_CreateVideo.Input.Path,
    headers: Operations.Video_CreateVideo.Input.Headers = .init(),
    body: Operations.Video_CreateVideo.Input.Body
) async throws -> Operations.Video_CreateVideo.Output
```

Create Video

Creates a new video entry in the specified library. Provide the video details, such as title and optional thumbnail extraction time, in the request body.

- Remark: HTTP `POST /library/{libraryId}/videos`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/post(Video_CreateVideo)`.

### `Video_SetThumbnail(path:query:headers:)`

```swift
public func Video_SetThumbnail(
    path: Operations.Video_SetThumbnail.Input.Path,
    query: Operations.Video_SetThumbnail.Input.Query = .init(),
    headers: Operations.Video_SetThumbnail.Input.Headers = .init()
) async throws -> Operations.Video_SetThumbnail.Output
```

Set Thumbnail

Sets or updates the thumbnail image for the specified video using the provided thumbnail URL.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/thumbnail`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/thumbnail/post(Video_SetThumbnail)`.

### `Video_FetchNewVideo(path:query:headers:body:)`

```swift
public func Video_FetchNewVideo(
    path: Operations.Video_FetchNewVideo.Input.Path,
    query: Operations.Video_FetchNewVideo.Input.Query = .init(),
    headers: Operations.Video_FetchNewVideo.Input.Headers = .init(),
    body: Operations.Video_FetchNewVideo.Input.Body
) async throws -> Operations.Video_FetchNewVideo.Output
```

Fetch Video

Fetches a video from a remote URL and adds it to the specified library. Optional parameters allow you to specify a collection and the time (in ms) to extract a thumbnail.

- Remark: HTTP `POST /library/{libraryId}/videos/fetch`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/fetch/post(Video_FetchNewVideo)`.

### `Video_AddCaption(path:headers:body:)`

```swift
public func Video_AddCaption(
    path: Operations.Video_AddCaption.Input.Path,
    headers: Operations.Video_AddCaption.Input.Headers = .init(),
    body: Operations.Video_AddCaption.Input.Body
) async throws -> Operations.Video_AddCaption.Output
```

Add Caption

Adds caption data to the specified video for the given language. The caption file should be provided as a base64 encoded string.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/captions/{srclang}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/captions/{srclang}/post(Video_AddCaption)`.

### `Video_DeleteCaption(path:headers:)`

```swift
public func Video_DeleteCaption(
    path: Operations.Video_DeleteCaption.Input.Path,
    headers: Operations.Video_DeleteCaption.Input.Headers = .init()
) async throws -> Operations.Video_DeleteCaption.Output
```

Delete Caption

Deletes the caption for the specified language from the video.

- Remark: HTTP `DELETE /library/{libraryId}/videos/{videoId}/captions/{srclang}`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/captions/{srclang}/delete(Video_DeleteCaption)`.

### `Video_TranscribeVideo(path:query:headers:body:)`

```swift
public func Video_TranscribeVideo(
    path: Operations.Video_TranscribeVideo.Input.Path,
    query: Operations.Video_TranscribeVideo.Input.Query = .init(),
    headers: Operations.Video_TranscribeVideo.Input.Headers = .init(),
    body: Operations.Video_TranscribeVideo.Input.Body? = nil
) async throws -> Operations.Video_TranscribeVideo.Output
```

Transcribe Video

Initiates the transcription process for the specified video. You can optionally override the video library transcription settings using the provided request body.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/transcribe`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/transcribe/post(Video_TranscribeVideo)`.

### `Video_GetVideoResolutions(path:headers:)`

```swift
public func Video_GetVideoResolutions(
    path: Operations.Video_GetVideoResolutions.Input.Path,
    headers: Operations.Video_GetVideoResolutions.Input.Headers = .init()
) async throws -> Operations.Video_GetVideoResolutions.Output
```

Video Resolutions Info

Retrieves information about the available and configured resolutions for the specified video. This includes data on storage resolutions and MP4 fallback files if available.

- Remark: HTTP `GET /library/{libraryId}/videos/{videoId}/resolutions`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/resolutions/get(Video_GetVideoResolutions)`.

### `Video_DeleteResolutions(path:query:headers:)`

```swift
public func Video_DeleteResolutions(
    path: Operations.Video_DeleteResolutions.Input.Path,
    query: Operations.Video_DeleteResolutions.Input.Query = .init(),
    headers: Operations.Video_DeleteResolutions.Input.Headers = .init()
) async throws -> Operations.Video_DeleteResolutions.Output
```

Cleanup Unconfigured Resolutions

Cleans up unconfigured resolutions for the specified video. Query parameters allow you to specify which resolutions to delete and whether to perform a dry run without actual file deletion.

- Remark: HTTP `POST /library/{libraryId}/videos/{videoId}/resolutions/cleanup`.
- Remark: Generated from `#/paths//library/{libraryId}/videos/{videoId}/resolutions/cleanup/post(Video_DeleteResolutions)`.

### `OEmbed_GetOEmbed(query:headers:)`

```swift
public func OEmbed_GetOEmbed(
    query: Operations.OEmbed_GetOEmbed.Input.Query = .init(),
    headers: Operations.OEmbed_GetOEmbed.Input.Headers = .init()
) async throws -> Operations.OEmbed_GetOEmbed.Output
```

Get OEmbed Data

Retrieves OEmbed information for a given video URL. This includes embed HTML, thumbnail URL, and metadata such as title and provider details.

- Remark: HTTP `GET /OEmbed`.
- Remark: Generated from `#/paths//OEmbed/get(OEmbed_GetOEmbed)`.
