**STRUCT**

# `Schemas.VideoModel`

```swift
public struct VideoModel: Codable, Hashable, Sendable
```

Represents a video and its metadata including title, upload date, dimensions, encoding status, and more.

- Remark: Generated from `#/components/schemas/VideoModel`.

## Properties
### `videoLibraryId`

```swift
public var videoLibraryId: Swift.Int64?
```

The ID of the video library that the video belongs to.

- Remark: Generated from `#/components/schemas/VideoModel/videoLibraryId`.

### `guid`

```swift
public var guid: Swift.String?
```

The unique identifier of the video.

- Remark: Generated from `#/components/schemas/VideoModel/guid`.

### `title`

```swift
public var title: Swift.String?
```

The title of the video.

- Remark: Generated from `#/components/schemas/VideoModel/title`.

### `dateUploaded`

```swift
public var dateUploaded: Foundation.Date?
```

The date and time when the video was uploaded.

- Remark: Generated from `#/components/schemas/VideoModel/dateUploaded`.

### `views`

```swift
public var views: Swift.Int64?
```

The number of views the video has received.

- Remark: Generated from `#/components/schemas/VideoModel/views`.

### `isPublic`

```swift
public var isPublic: Swift.Bool?
```

Determines if the video is publicly accessible.

- Remark: Generated from `#/components/schemas/VideoModel/isPublic`.

### `length`

```swift
public var length: Swift.Int32?
```

The duration of the video in seconds.

- Remark: Generated from `#/components/schemas/VideoModel/length`.

### `status`

```swift
public var status: Components.Schemas.VideoModel.statusPayload?
```

The current status of the video (e.g., processing, finished, error).

- Remark: Generated from `#/components/schemas/VideoModel/status`.

### `framerate`

```swift
public var framerate: Swift.Double?
```

The framerate of the video.

- Remark: Generated from `#/components/schemas/VideoModel/framerate`.

### `rotation`

```swift
public var rotation: Swift.Int?
```

The rotation (in degrees) of the video if applicable.

- Remark: Generated from `#/components/schemas/VideoModel/rotation`.

### `width`

```swift
public var width: Swift.Int32?
```

The width of the original video in pixels.

- Remark: Generated from `#/components/schemas/VideoModel/width`.

### `height`

```swift
public var height: Swift.Int32?
```

The height of the original video in pixels.

- Remark: Generated from `#/components/schemas/VideoModel/height`.

### `availableResolutions`

```swift
public var availableResolutions: Swift.String?
```

A comma-separated list of resolutions available for the video.

- Remark: Generated from `#/components/schemas/VideoModel/availableResolutions`.

### `outputCodecs`

```swift
public var outputCodecs: Swift.String?
```

A comma-separated list of output codecs used for video encoding.

- Remark: Generated from `#/components/schemas/VideoModel/outputCodecs`.

### `thumbnailCount`

```swift
public var thumbnailCount: Swift.Int32?
```

The number of thumbnails generated for the video.

- Remark: Generated from `#/components/schemas/VideoModel/thumbnailCount`.

### `encodeProgress`

```swift
public var encodeProgress: Swift.Int32?
```

The current encoding progress of the video as a percentage.

- Remark: Generated from `#/components/schemas/VideoModel/encodeProgress`.

### `storageSize`

```swift
public var storageSize: Swift.Int64?
```

The total storage size of the video file in bytes.

- Remark: Generated from `#/components/schemas/VideoModel/storageSize`.

### `captions`

```swift
public var captions: [Components.Schemas.CaptionModel]?
```

A list of captions available for the video.

- Remark: Generated from `#/components/schemas/VideoModel/captions`.

### `hasMP4Fallback`

```swift
public var hasMP4Fallback: Swift.Bool?
```

Indicates if MP4 fallback files are available for the video.

- Remark: Generated from `#/components/schemas/VideoModel/hasMP4Fallback`.

### `collectionId`

```swift
public var collectionId: Swift.String?
```

The identifier of the collection that the video belongs to.

- Remark: Generated from `#/components/schemas/VideoModel/collectionId`.

### `thumbnailFileName`

```swift
public var thumbnailFileName: Swift.String?
```

The file name of the thumbnail stored on the server.

- Remark: Generated from `#/components/schemas/VideoModel/thumbnailFileName`.

### `averageWatchTime`

```swift
public var averageWatchTime: Swift.Int64?
```

The average watch time of the video in seconds.

- Remark: Generated from `#/components/schemas/VideoModel/averageWatchTime`.

### `totalWatchTime`

```swift
public var totalWatchTime: Swift.Int64?
```

The total accumulated watch time of the video in seconds.

- Remark: Generated from `#/components/schemas/VideoModel/totalWatchTime`.

### `category`

```swift
public var category: Swift.String?
```

The automatically detected category of the video.

- Remark: Generated from `#/components/schemas/VideoModel/category`.

### `chapters`

```swift
public var chapters: [Components.Schemas.ChapterModel]?
```

A list of chapters within the video.

- Remark: Generated from `#/components/schemas/VideoModel/chapters`.

### `moments`

```swift
public var moments: [Components.Schemas.MomentModel]?
```

A list of significant moments or events in the video.

- Remark: Generated from `#/components/schemas/VideoModel/moments`.

### `metaTags`

```swift
public var metaTags: [Components.Schemas.MetaTagModel]?
```

A list of metadata tags associated with the video.

- Remark: Generated from `#/components/schemas/VideoModel/metaTags`.

### `transcodingMessages`

```swift
public var transcodingMessages: [Components.Schemas.TranscodingMessageModel]?
```

Messages generated during transcoding that indicate warnings or errors.

- Remark: Generated from `#/components/schemas/VideoModel/transcodingMessages`.

## Methods
### `init(videoLibraryId:guid:title:dateUploaded:views:isPublic:length:status:framerate:rotation:width:height:availableResolutions:outputCodecs:thumbnailCount:encodeProgress:storageSize:captions:hasMP4Fallback:collectionId:thumbnailFileName:averageWatchTime:totalWatchTime:category:chapters:moments:metaTags:transcodingMessages:)`

```swift
public init(
    videoLibraryId: Swift.Int64? = nil,
    guid: Swift.String? = nil,
    title: Swift.String? = nil,
    dateUploaded: Foundation.Date? = nil,
    views: Swift.Int64? = nil,
    isPublic: Swift.Bool? = nil,
    length: Swift.Int32? = nil,
    status: Components.Schemas.VideoModel.statusPayload? = nil,
    framerate: Swift.Double? = nil,
    rotation: Swift.Int? = nil,
    width: Swift.Int32? = nil,
    height: Swift.Int32? = nil,
    availableResolutions: Swift.String? = nil,
    outputCodecs: Swift.String? = nil,
    thumbnailCount: Swift.Int32? = nil,
    encodeProgress: Swift.Int32? = nil,
    storageSize: Swift.Int64? = nil,
    captions: [Components.Schemas.CaptionModel]? = nil,
    hasMP4Fallback: Swift.Bool? = nil,
    collectionId: Swift.String? = nil,
    thumbnailFileName: Swift.String? = nil,
    averageWatchTime: Swift.Int64? = nil,
    totalWatchTime: Swift.Int64? = nil,
    category: Swift.String? = nil,
    chapters: [Components.Schemas.ChapterModel]? = nil,
    moments: [Components.Schemas.MomentModel]? = nil,
    metaTags: [Components.Schemas.MetaTagModel]? = nil,
    transcodingMessages: [Components.Schemas.TranscodingMessageModel]? = nil
)
```

Creates a new `VideoModel`.

- Parameters:
  - videoLibraryId: The ID of the video library that the video belongs to.
  - guid: The unique identifier of the video.
  - title: The title of the video.
  - dateUploaded: The date and time when the video was uploaded.
  - views: The number of views the video has received.
  - isPublic: Determines if the video is publicly accessible.
  - length: The duration of the video in seconds.
  - status: The current status of the video (e.g., processing, finished, error).
  - framerate: The framerate of the video.
  - rotation: The rotation (in degrees) of the video if applicable.
  - width: The width of the original video in pixels.
  - height: The height of the original video in pixels.
  - availableResolutions: A comma-separated list of resolutions available for the video.
  - outputCodecs: A comma-separated list of output codecs used for video encoding.
  - thumbnailCount: The number of thumbnails generated for the video.
  - encodeProgress: The current encoding progress of the video as a percentage.
  - storageSize: The total storage size of the video file in bytes.
  - captions: A list of captions available for the video.
  - hasMP4Fallback: Indicates if MP4 fallback files are available for the video.
  - collectionId: The identifier of the collection that the video belongs to.
  - thumbnailFileName: The file name of the thumbnail stored on the server.
  - averageWatchTime: The average watch time of the video in seconds.
  - totalWatchTime: The total accumulated watch time of the video in seconds.
  - category: The automatically detected category of the video.
  - chapters: A list of chapters within the video.
  - moments: A list of significant moments or events in the video.
  - metaTags: A list of metadata tags associated with the video.
  - transcodingMessages: Messages generated during transcoding that indicate warnings or errors.

#### Parameters

| Name | Description |
| ---- | ----------- |
| videoLibraryId | The ID of the video library that the video belongs to. |
| guid | The unique identifier of the video. |
| title | The title of the video. |
| dateUploaded | The date and time when the video was uploaded. |
| views | The number of views the video has received. |
| isPublic | Determines if the video is publicly accessible. |
| length | The duration of the video in seconds. |
| status | The current status of the video (e.g., processing, finished, error). |
| framerate | The framerate of the video. |
| rotation | The rotation (in degrees) of the video if applicable. |
| width | The width of the original video in pixels. |
| height | The height of the original video in pixels. |
| availableResolutions | A comma-separated list of resolutions available for the video. |
| outputCodecs | A comma-separated list of output codecs used for video encoding. |
| thumbnailCount | The number of thumbnails generated for the video. |
| encodeProgress | The current encoding progress of the video as a percentage. |
| storageSize | The total storage size of the video file in bytes. |
| captions | A list of captions available for the video. |
| hasMP4Fallback | Indicates if MP4 fallback files are available for the video. |
| collectionId | The identifier of the collection that the video belongs to. |
| thumbnailFileName | The file name of the thumbnail stored on the server. |
| averageWatchTime | The average watch time of the video in seconds. |
| totalWatchTime | The total accumulated watch time of the video in seconds. |
| category | The automatically detected category of the video. |
| chapters | A list of chapters within the video. |
| moments | A list of significant moments or events in the video. |
| metaTags | A list of metadata tags associated with the video. |
| transcodingMessages | Messages generated during transcoding that indicate warnings or errors. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |