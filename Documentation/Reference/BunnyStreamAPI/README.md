# BunnyStreamAPI

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://www.swift.org)
[![License](https://img.shields.io/badge/Licence-MIT-green.svg)](LICENSE)

## Overview

BunnyStreamAPI is the core package of the Bunny Stream iOS SDK, providing a comprehensive Swift interface to Bunny's REST Stream API. This package handles all API communication, request authentication, and response parsing, enabling seamless video content management.

### Features

- Complete Bunny REST Stream API integration
- Comprehensive video management capabilities
- Collection organization and management
- Thumbnail generation and management
- Analytics and CDN settings control
- Type-safe Swift API interface
- Detailed error handling and recovery options

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 13.0+

### Installation

```swift
dependencies: [
    .package(url: "https://github.com/BunnyWay/bunny-stream-ios.git", .upToNextMajor(from: "1.0.0"))
]
```

### Usage example

The example below demonstrates how to initialize the API client and retrieve video details:

```swift
import BunnyStreamAPI

// Initialize the BunnyStreamAPI client with your access key
let bunnyStreamAPI = BunnyStreamAPI(accessKey: "your_access_key")

// Fetch video details using the client
let videoInfo = try await bunnyStreamAPI.client.getVideo(
    path: .init(
        libraryId: 12345,
        videoId: "abcd-e9bb-4b96-wxyz-c17bc6a5292b"
    )
)
```

### Error Handling

BunnyStreamAPI provides detailed error information via custom error types. The example below shows how to handle errors gracefully:

```swift
do {
    let output = try await bunnyStreamAPI.client.deleteVideo(
        path: .init(
          libraryId: 123,
          videoId: "videoId"
        )
    )
} catch let error as BunnyStreamError {
    switch error {
    case .unauthorized:
        print("Invalid access key")
    case .notFound:
        print("Video not found")
    case .networkError(let underlying):
        print("Network error: \(underlying)")
    case .apiError(let status, let message):
        print("API error (\(status)): \(message)")
    }
}
```

---

# Reference Documentation

## Protocols
-   [APIProtocol](protocols/APIProtocol.md)
## Structs
-   [Client](structs/Client.md)
-   [FetchVideoRequest.HeadersPayload](structs/FetchVideoRequest.HeadersPayload.md)
-   [Input.Headers](structs/Input.Headers.md)
-   [Input.Path](structs/Input.Path.md)
-   [Input.Query](structs/Input.Query.md)
-   [Output.BadRequest](structs/Output.BadRequest.md)
-   [Output.InternalServerError](structs/Output.InternalServerError.md)
-   [Output.NotFound](structs/Output.NotFound.md)
-   [Output.Ok](structs/Output.Ok.md)
-   [Output.Unauthorized](structs/Output.Unauthorized.md)
-   [Schemas.CaptionModel](structs/Schemas.CaptionModel.md)
-   [Schemas.CaptionModelAdd](structs/Schemas.CaptionModelAdd.md)
-   [Schemas.ChapterModel](structs/Schemas.ChapterModel.md)
-   [Schemas.CollectionModel](structs/Schemas.CollectionModel.md)
-   [Schemas.CreateVideoModel](structs/Schemas.CreateVideoModel.md)
-   [Schemas.FetchVideoRequest](structs/Schemas.FetchVideoRequest.md)
-   [Schemas.MetaTagModel](structs/Schemas.MetaTagModel.md)
-   [Schemas.MomentModel](structs/Schemas.MomentModel.md)
-   [Schemas.PaginationListOfCollectionModel](structs/Schemas.PaginationListOfCollectionModel.md)
-   [Schemas.PaginationListOfVideoModel](structs/Schemas.PaginationListOfVideoModel.md)
-   [Schemas.ResolutionReference](structs/Schemas.ResolutionReference.md)
-   [Schemas.StatusModel](structs/Schemas.StatusModel.md)
-   [Schemas.StatusModelOfVideoResolutionsInfoModel](structs/Schemas.StatusModelOfVideoResolutionsInfoModel.md)
-   [Schemas.StorageObjectModel](structs/Schemas.StorageObjectModel.md)
-   [Schemas.TranscodingMessageModel](structs/Schemas.TranscodingMessageModel.md)
-   [Schemas.TranscribeSettings](structs/Schemas.TranscribeSettings.md)
-   [Schemas.UpdateCollectionModel](structs/Schemas.UpdateCollectionModel.md)
-   [Schemas.UpdateVideoModel](structs/Schemas.UpdateVideoModel.md)
-   [Schemas.VideoHeatmapModel](structs/Schemas.VideoHeatmapModel.md)
-   [Schemas.VideoModel](structs/Schemas.VideoModel.md)
-   [Schemas.VideoOEmbedModel](structs/Schemas.VideoOEmbedModel.md)
-   [Schemas.VideoPlayDataModel](structs/Schemas.VideoPlayDataModel.md)
-   [Schemas.VideoResolutionsInfoModel](structs/Schemas.VideoResolutionsInfoModel.md)
-   [Schemas.VideoStatisticsModel](structs/Schemas.VideoStatisticsModel.md)
-   [StatusModelOfVideoResolutionsInfoModel.Value2Payload](structs/StatusModelOfVideoResolutionsInfoModel.Value2Payload.md)
-   [VideoHeatmapModel.HeatmapPayload](structs/VideoHeatmapModel.HeatmapPayload.md)
-   [VideoStatisticsModel.CountryViewCountsPayload](structs/VideoStatisticsModel.CountryViewCountsPayload.md)
-   [VideoStatisticsModel.CountryWatchTimePayload](structs/VideoStatisticsModel.CountryWatchTimePayload.md)
-   [VideoStatisticsModel.ViewsChartPayload](structs/VideoStatisticsModel.ViewsChartPayload.md)
-   [VideoStatisticsModel.WatchTimeChartPayload](structs/VideoStatisticsModel.WatchTimeChartPayload.md)
-   [addCaption.Input](structs/addCaption.Input.md)
-   [createCollection.Input](structs/createCollection.Input.md)
-   [createVideo.Input](structs/createVideo.Input.md)
-   [deleteCaption.Input](structs/deleteCaption.Input.md)
-   [deleteCollection.Input](structs/deleteCollection.Input.md)
-   [deleteResolutions.Input](structs/deleteResolutions.Input.md)
-   [deleteVideo.Input](structs/deleteVideo.Input.md)
-   [fetchVideo.Input](structs/fetchVideo.Input.md)
-   [getCollection.Input](structs/getCollection.Input.md)
-   [getOEmbed.Input](structs/getOEmbed.Input.md)
-   [getVideo.Input](structs/getVideo.Input.md)
-   [getVideoHeatmap.Input](structs/getVideoHeatmap.Input.md)
-   [getVideoPlayData.Input](structs/getVideoPlayData.Input.md)
-   [getVideoResolutions.Input](structs/getVideoResolutions.Input.md)
-   [getVideoStatistics.Input](structs/getVideoStatistics.Input.md)
-   [listCollections.Input](structs/listCollections.Input.md)
-   [listVideos.Input](structs/listVideos.Input.md)
-   [reencodeUsingCodec.Input](structs/reencodeUsingCodec.Input.md)
-   [reencodeVideo.Input](structs/reencodeVideo.Input.md)
-   [repackageVideo.Input](structs/repackageVideo.Input.md)
-   [setThumbnail.Input](structs/setThumbnail.Input.md)
-   [transcribeVideo.Input](structs/transcribeVideo.Input.md)
-   [updateCollection.Input](structs/updateCollection.Input.md)
-   [updateVideo.Input](structs/updateVideo.Input.md)
-   [uploadVideo.Input](structs/uploadVideo.Input.md)
## Classes
-   [BunnyStreamAPI](classes/BunnyStreamAPI.md)
## Enums
-   [BadRequest.Body](enums/BadRequest.Body.md)
-   [Body.JsonPayload](enums/Body.JsonPayload.md)
-   [CaptionModel.CodingKeys](enums/CaptionModel.CodingKeys.md)
-   [CaptionModelAdd.CodingKeys](enums/CaptionModelAdd.CodingKeys.md)
-   [ChapterModel.CodingKeys](enums/ChapterModel.CodingKeys.md)
-   [CollectionModel.CodingKeys](enums/CollectionModel.CodingKeys.md)
-   [Components](enums/Components.md)
-   [Components.Headers](enums/Components.Headers.md)
-   [Components.Parameters](enums/Components.Parameters.md)
-   [Components.RequestBodies](enums/Components.RequestBodies.md)
-   [Components.Responses](enums/Components.Responses.md)
-   [Components.Schemas](enums/Components.Schemas.md)
-   [CreateVideoModel.CodingKeys](enums/CreateVideoModel.CodingKeys.md)
-   [FetchVideoRequest.CodingKeys](enums/FetchVideoRequest.CodingKeys.md)
-   [Input.Body](enums/Input.Body.md)
-   [MetaTagModel.CodingKeys](enums/MetaTagModel.CodingKeys.md)
-   [MomentModel.CodingKeys](enums/MomentModel.CodingKeys.md)
-   [Ok.Body](enums/Ok.Body.md)
-   [Operations](enums/Operations.md)
-   [Operations.addCaption](enums/Operations.addCaption.md)
-   [Operations.createCollection](enums/Operations.createCollection.md)
-   [Operations.createVideo](enums/Operations.createVideo.md)
-   [Operations.deleteCaption](enums/Operations.deleteCaption.md)
-   [Operations.deleteCollection](enums/Operations.deleteCollection.md)
-   [Operations.deleteResolutions](enums/Operations.deleteResolutions.md)
-   [Operations.deleteVideo](enums/Operations.deleteVideo.md)
-   [Operations.fetchVideo](enums/Operations.fetchVideo.md)
-   [Operations.getCollection](enums/Operations.getCollection.md)
-   [Operations.getOEmbed](enums/Operations.getOEmbed.md)
-   [Operations.getVideo](enums/Operations.getVideo.md)
-   [Operations.getVideoHeatmap](enums/Operations.getVideoHeatmap.md)
-   [Operations.getVideoPlayData](enums/Operations.getVideoPlayData.md)
-   [Operations.getVideoResolutions](enums/Operations.getVideoResolutions.md)
-   [Operations.getVideoStatistics](enums/Operations.getVideoStatistics.md)
-   [Operations.listCollections](enums/Operations.listCollections.md)
-   [Operations.listVideos](enums/Operations.listVideos.md)
-   [Operations.reencodeUsingCodec](enums/Operations.reencodeUsingCodec.md)
-   [Operations.reencodeVideo](enums/Operations.reencodeVideo.md)
-   [Operations.repackageVideo](enums/Operations.repackageVideo.md)
-   [Operations.setThumbnail](enums/Operations.setThumbnail.md)
-   [Operations.transcribeVideo](enums/Operations.transcribeVideo.md)
-   [Operations.updateCollection](enums/Operations.updateCollection.md)
-   [Operations.updateVideo](enums/Operations.updateVideo.md)
-   [Operations.uploadVideo](enums/Operations.uploadVideo.md)
-   [PaginationListOfCollectionModel.CodingKeys](enums/PaginationListOfCollectionModel.CodingKeys.md)
-   [PaginationListOfVideoModel.CodingKeys](enums/PaginationListOfVideoModel.CodingKeys.md)
-   [ResolutionReference.CodingKeys](enums/ResolutionReference.CodingKeys.md)
-   [Schemas.EncoderOutputCodec](enums/Schemas.EncoderOutputCodec.md)
-   [Schemas.IssueCodes](enums/Schemas.IssueCodes.md)
-   [Schemas.Severity](enums/Schemas.Severity.md)
-   [Schemas.VideoModelStatus](enums/Schemas.VideoModelStatus.md)
-   [Servers](enums/Servers.md)
-   [Servers.Server1](enums/Servers.Server1.md)
-   [StatusModel.CodingKeys](enums/StatusModel.CodingKeys.md)
-   [StorageObjectModel.CodingKeys](enums/StorageObjectModel.CodingKeys.md)
-   [TranscodingMessageModel.CodingKeys](enums/TranscodingMessageModel.CodingKeys.md)
-   [TranscribeSettings.CodingKeys](enums/TranscribeSettings.CodingKeys.md)
-   [UpdateCollectionModel.CodingKeys](enums/UpdateCollectionModel.CodingKeys.md)
-   [UpdateVideoModel.CodingKeys](enums/UpdateVideoModel.CodingKeys.md)
-   [Value2Payload.CodingKeys](enums/Value2Payload.CodingKeys.md)
-   [Value2Payload.DataPayload](enums/Value2Payload.DataPayload.md)
-   [VideoHeatmapModel.CodingKeys](enums/VideoHeatmapModel.CodingKeys.md)
-   [VideoModel.CodingKeys](enums/VideoModel.CodingKeys.md)
-   [VideoModel.StatusPayload](enums/VideoModel.StatusPayload.md)
-   [VideoOEmbedModel.CodingKeys](enums/VideoOEmbedModel.CodingKeys.md)
-   [VideoPlayDataModel.CodingKeys](enums/VideoPlayDataModel.CodingKeys.md)
-   [VideoPlayDataModel.VideoPayload](enums/VideoPlayDataModel.VideoPayload.md)
-   [VideoResolutionsInfoModel.CodingKeys](enums/VideoResolutionsInfoModel.CodingKeys.md)
-   [VideoStatisticsModel.CodingKeys](enums/VideoStatisticsModel.CodingKeys.md)
-   [addCaption.AcceptableContentType](enums/addCaption.AcceptableContentType.md)
-   [addCaption.Output](enums/addCaption.Output.md)
-   [createCollection.AcceptableContentType](enums/createCollection.AcceptableContentType.md)
-   [createCollection.Output](enums/createCollection.Output.md)
-   [createVideo.AcceptableContentType](enums/createVideo.AcceptableContentType.md)
-   [createVideo.Output](enums/createVideo.Output.md)
-   [deleteCaption.AcceptableContentType](enums/deleteCaption.AcceptableContentType.md)
-   [deleteCaption.Output](enums/deleteCaption.Output.md)
-   [deleteCollection.AcceptableContentType](enums/deleteCollection.AcceptableContentType.md)
-   [deleteCollection.Output](enums/deleteCollection.Output.md)
-   [deleteResolutions.AcceptableContentType](enums/deleteResolutions.AcceptableContentType.md)
-   [deleteResolutions.Output](enums/deleteResolutions.Output.md)
-   [deleteVideo.AcceptableContentType](enums/deleteVideo.AcceptableContentType.md)
-   [deleteVideo.Output](enums/deleteVideo.Output.md)
-   [fetchVideo.AcceptableContentType](enums/fetchVideo.AcceptableContentType.md)
-   [fetchVideo.Output](enums/fetchVideo.Output.md)
-   [getCollection.AcceptableContentType](enums/getCollection.AcceptableContentType.md)
-   [getCollection.Output](enums/getCollection.Output.md)
-   [getOEmbed.AcceptableContentType](enums/getOEmbed.AcceptableContentType.md)
-   [getOEmbed.Output](enums/getOEmbed.Output.md)
-   [getVideo.AcceptableContentType](enums/getVideo.AcceptableContentType.md)
-   [getVideo.Output](enums/getVideo.Output.md)
-   [getVideoHeatmap.AcceptableContentType](enums/getVideoHeatmap.AcceptableContentType.md)
-   [getVideoHeatmap.Output](enums/getVideoHeatmap.Output.md)
-   [getVideoPlayData.AcceptableContentType](enums/getVideoPlayData.AcceptableContentType.md)
-   [getVideoPlayData.Output](enums/getVideoPlayData.Output.md)
-   [getVideoResolutions.AcceptableContentType](enums/getVideoResolutions.AcceptableContentType.md)
-   [getVideoResolutions.Output](enums/getVideoResolutions.Output.md)
-   [getVideoStatistics.AcceptableContentType](enums/getVideoStatistics.AcceptableContentType.md)
-   [getVideoStatistics.Output](enums/getVideoStatistics.Output.md)
-   [listCollections.AcceptableContentType](enums/listCollections.AcceptableContentType.md)
-   [listCollections.Output](enums/listCollections.Output.md)
-   [listVideos.AcceptableContentType](enums/listVideos.AcceptableContentType.md)
-   [listVideos.Output](enums/listVideos.Output.md)
-   [reencodeUsingCodec.AcceptableContentType](enums/reencodeUsingCodec.AcceptableContentType.md)
-   [reencodeUsingCodec.Output](enums/reencodeUsingCodec.Output.md)
-   [reencodeVideo.AcceptableContentType](enums/reencodeVideo.AcceptableContentType.md)
-   [reencodeVideo.Output](enums/reencodeVideo.Output.md)
-   [repackageVideo.AcceptableContentType](enums/repackageVideo.AcceptableContentType.md)
-   [repackageVideo.Output](enums/repackageVideo.Output.md)
-   [setThumbnail.AcceptableContentType](enums/setThumbnail.AcceptableContentType.md)
-   [setThumbnail.Output](enums/setThumbnail.Output.md)
-   [transcribeVideo.AcceptableContentType](enums/transcribeVideo.AcceptableContentType.md)
-   [transcribeVideo.Output](enums/transcribeVideo.Output.md)
-   [updateCollection.AcceptableContentType](enums/updateCollection.AcceptableContentType.md)
-   [updateCollection.Output](enums/updateCollection.Output.md)
-   [updateVideo.AcceptableContentType](enums/updateVideo.AcceptableContentType.md)
-   [updateVideo.Output](enums/updateVideo.Output.md)
-   [uploadVideo.AcceptableContentType](enums/uploadVideo.AcceptableContentType.md)
-   [uploadVideo.Output](enums/uploadVideo.Output.md)
## Extensions
-   [APIProtocol](extensions/APIProtocol.md)

Copyright (c) 2019 BunnyWay d.o.o.
