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
-   [Collection_CreateCollection.Input](structs/Collection_CreateCollection.Input.md)
-   [Collection_DeleteCollection.Input](structs/Collection_DeleteCollection.Input.md)
-   [Collection_GetCollection.Input](structs/Collection_GetCollection.Input.md)
-   [Collection_List.Input](structs/Collection_List.Input.md)
-   [Collection_UpdateCollection.Input](structs/Collection_UpdateCollection.Input.md)
-   [FetchVideoRequest.headersPayload](structs/FetchVideoRequest.headersPayload.md)
-   [Input.Headers](structs/Input.Headers.md)
-   [Input.Path](structs/Input.Path.md)
-   [Input.Query](structs/Input.Query.md)
-   [OEmbed_GetOEmbed.Input](structs/OEmbed_GetOEmbed.Input.md)
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
-   [VideoHeatmapModel.heatmapPayload](structs/VideoHeatmapModel.heatmapPayload.md)
-   [VideoStatisticsModel.countryViewCountsPayload](structs/VideoStatisticsModel.countryViewCountsPayload.md)
-   [VideoStatisticsModel.countryWatchTimePayload](structs/VideoStatisticsModel.countryWatchTimePayload.md)
-   [VideoStatisticsModel.viewsChartPayload](structs/VideoStatisticsModel.viewsChartPayload.md)
-   [VideoStatisticsModel.watchTimeChartPayload](structs/VideoStatisticsModel.watchTimeChartPayload.md)
-   [Video_AddCaption.Input](structs/Video_AddCaption.Input.md)
-   [Video_CreateVideo.Input](structs/Video_CreateVideo.Input.md)
-   [Video_DeleteCaption.Input](structs/Video_DeleteCaption.Input.md)
-   [Video_DeleteResolutions.Input](structs/Video_DeleteResolutions.Input.md)
-   [Video_DeleteVideo.Input](structs/Video_DeleteVideo.Input.md)
-   [Video_FetchNewVideo.Input](structs/Video_FetchNewVideo.Input.md)
-   [Video_GetVideo.Input](structs/Video_GetVideo.Input.md)
-   [Video_GetVideoHeatmap.Input](structs/Video_GetVideoHeatmap.Input.md)
-   [Video_GetVideoPlayData.Input](structs/Video_GetVideoPlayData.Input.md)
-   [Video_GetVideoResolutions.Input](structs/Video_GetVideoResolutions.Input.md)
-   [Video_GetVideoStatistics.Input](structs/Video_GetVideoStatistics.Input.md)
-   [Video_List.Input](structs/Video_List.Input.md)
-   [Video_ReencodeUsingCodec.Input](structs/Video_ReencodeUsingCodec.Input.md)
-   [Video_ReencodeVideo.Input](structs/Video_ReencodeVideo.Input.md)
-   [Video_Repackage.Input](structs/Video_Repackage.Input.md)
-   [Video_SetThumbnail.Input](structs/Video_SetThumbnail.Input.md)
-   [Video_TranscribeVideo.Input](structs/Video_TranscribeVideo.Input.md)
-   [Video_UpdateVideo.Input](structs/Video_UpdateVideo.Input.md)
-   [Video_UploadVideo.Input](structs/Video_UploadVideo.Input.md)
## Classes
-   [BunnyStreamAPI](classes/BunnyStreamAPI.md)
## Enums
-   [BadRequest.Body](enums/BadRequest.Body.md)
-   [Body.jsonPayload](enums/Body.jsonPayload.md)
-   [CaptionModel.CodingKeys](enums/CaptionModel.CodingKeys.md)
-   [CaptionModelAdd.CodingKeys](enums/CaptionModelAdd.CodingKeys.md)
-   [ChapterModel.CodingKeys](enums/ChapterModel.CodingKeys.md)
-   [CollectionModel.CodingKeys](enums/CollectionModel.CodingKeys.md)
-   [Collection_CreateCollection.AcceptableContentType](enums/Collection_CreateCollection.AcceptableContentType.md)
-   [Collection_CreateCollection.Output](enums/Collection_CreateCollection.Output.md)
-   [Collection_DeleteCollection.AcceptableContentType](enums/Collection_DeleteCollection.AcceptableContentType.md)
-   [Collection_DeleteCollection.Output](enums/Collection_DeleteCollection.Output.md)
-   [Collection_GetCollection.AcceptableContentType](enums/Collection_GetCollection.AcceptableContentType.md)
-   [Collection_GetCollection.Output](enums/Collection_GetCollection.Output.md)
-   [Collection_List.AcceptableContentType](enums/Collection_List.AcceptableContentType.md)
-   [Collection_List.Output](enums/Collection_List.Output.md)
-   [Collection_UpdateCollection.AcceptableContentType](enums/Collection_UpdateCollection.AcceptableContentType.md)
-   [Collection_UpdateCollection.Output](enums/Collection_UpdateCollection.Output.md)
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
-   [OEmbed_GetOEmbed.AcceptableContentType](enums/OEmbed_GetOEmbed.AcceptableContentType.md)
-   [OEmbed_GetOEmbed.Output](enums/OEmbed_GetOEmbed.Output.md)
-   [Ok.Body](enums/Ok.Body.md)
-   [Operations](enums/Operations.md)
-   [Operations.Collection_CreateCollection](enums/Operations.Collection_CreateCollection.md)
-   [Operations.Collection_DeleteCollection](enums/Operations.Collection_DeleteCollection.md)
-   [Operations.Collection_GetCollection](enums/Operations.Collection_GetCollection.md)
-   [Operations.Collection_List](enums/Operations.Collection_List.md)
-   [Operations.Collection_UpdateCollection](enums/Operations.Collection_UpdateCollection.md)
-   [Operations.OEmbed_GetOEmbed](enums/Operations.OEmbed_GetOEmbed.md)
-   [Operations.Video_AddCaption](enums/Operations.Video_AddCaption.md)
-   [Operations.Video_CreateVideo](enums/Operations.Video_CreateVideo.md)
-   [Operations.Video_DeleteCaption](enums/Operations.Video_DeleteCaption.md)
-   [Operations.Video_DeleteResolutions](enums/Operations.Video_DeleteResolutions.md)
-   [Operations.Video_DeleteVideo](enums/Operations.Video_DeleteVideo.md)
-   [Operations.Video_FetchNewVideo](enums/Operations.Video_FetchNewVideo.md)
-   [Operations.Video_GetVideo](enums/Operations.Video_GetVideo.md)
-   [Operations.Video_GetVideoHeatmap](enums/Operations.Video_GetVideoHeatmap.md)
-   [Operations.Video_GetVideoPlayData](enums/Operations.Video_GetVideoPlayData.md)
-   [Operations.Video_GetVideoResolutions](enums/Operations.Video_GetVideoResolutions.md)
-   [Operations.Video_GetVideoStatistics](enums/Operations.Video_GetVideoStatistics.md)
-   [Operations.Video_List](enums/Operations.Video_List.md)
-   [Operations.Video_ReencodeUsingCodec](enums/Operations.Video_ReencodeUsingCodec.md)
-   [Operations.Video_ReencodeVideo](enums/Operations.Video_ReencodeVideo.md)
-   [Operations.Video_Repackage](enums/Operations.Video_Repackage.md)
-   [Operations.Video_SetThumbnail](enums/Operations.Video_SetThumbnail.md)
-   [Operations.Video_TranscribeVideo](enums/Operations.Video_TranscribeVideo.md)
-   [Operations.Video_UpdateVideo](enums/Operations.Video_UpdateVideo.md)
-   [Operations.Video_UploadVideo](enums/Operations.Video_UploadVideo.md)
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
-   [Value2Payload.dataPayload](enums/Value2Payload.dataPayload.md)
-   [VideoHeatmapModel.CodingKeys](enums/VideoHeatmapModel.CodingKeys.md)
-   [VideoModel.CodingKeys](enums/VideoModel.CodingKeys.md)
-   [VideoModel.statusPayload](enums/VideoModel.statusPayload.md)
-   [VideoOEmbedModel.CodingKeys](enums/VideoOEmbedModel.CodingKeys.md)
-   [VideoPlayDataModel.CodingKeys](enums/VideoPlayDataModel.CodingKeys.md)
-   [VideoPlayDataModel.videoPayload](enums/VideoPlayDataModel.videoPayload.md)
-   [VideoResolutionsInfoModel.CodingKeys](enums/VideoResolutionsInfoModel.CodingKeys.md)
-   [VideoStatisticsModel.CodingKeys](enums/VideoStatisticsModel.CodingKeys.md)
-   [Video_AddCaption.AcceptableContentType](enums/Video_AddCaption.AcceptableContentType.md)
-   [Video_AddCaption.Output](enums/Video_AddCaption.Output.md)
-   [Video_CreateVideo.AcceptableContentType](enums/Video_CreateVideo.AcceptableContentType.md)
-   [Video_CreateVideo.Output](enums/Video_CreateVideo.Output.md)
-   [Video_DeleteCaption.AcceptableContentType](enums/Video_DeleteCaption.AcceptableContentType.md)
-   [Video_DeleteCaption.Output](enums/Video_DeleteCaption.Output.md)
-   [Video_DeleteResolutions.AcceptableContentType](enums/Video_DeleteResolutions.AcceptableContentType.md)
-   [Video_DeleteResolutions.Output](enums/Video_DeleteResolutions.Output.md)
-   [Video_DeleteVideo.AcceptableContentType](enums/Video_DeleteVideo.AcceptableContentType.md)
-   [Video_DeleteVideo.Output](enums/Video_DeleteVideo.Output.md)
-   [Video_FetchNewVideo.AcceptableContentType](enums/Video_FetchNewVideo.AcceptableContentType.md)
-   [Video_FetchNewVideo.Output](enums/Video_FetchNewVideo.Output.md)
-   [Video_GetVideo.AcceptableContentType](enums/Video_GetVideo.AcceptableContentType.md)
-   [Video_GetVideo.Output](enums/Video_GetVideo.Output.md)
-   [Video_GetVideoHeatmap.AcceptableContentType](enums/Video_GetVideoHeatmap.AcceptableContentType.md)
-   [Video_GetVideoHeatmap.Output](enums/Video_GetVideoHeatmap.Output.md)
-   [Video_GetVideoPlayData.AcceptableContentType](enums/Video_GetVideoPlayData.AcceptableContentType.md)
-   [Video_GetVideoPlayData.Output](enums/Video_GetVideoPlayData.Output.md)
-   [Video_GetVideoResolutions.AcceptableContentType](enums/Video_GetVideoResolutions.AcceptableContentType.md)
-   [Video_GetVideoResolutions.Output](enums/Video_GetVideoResolutions.Output.md)
-   [Video_GetVideoStatistics.AcceptableContentType](enums/Video_GetVideoStatistics.AcceptableContentType.md)
-   [Video_GetVideoStatistics.Output](enums/Video_GetVideoStatistics.Output.md)
-   [Video_List.AcceptableContentType](enums/Video_List.AcceptableContentType.md)
-   [Video_List.Output](enums/Video_List.Output.md)
-   [Video_ReencodeUsingCodec.AcceptableContentType](enums/Video_ReencodeUsingCodec.AcceptableContentType.md)
-   [Video_ReencodeUsingCodec.Output](enums/Video_ReencodeUsingCodec.Output.md)
-   [Video_ReencodeVideo.AcceptableContentType](enums/Video_ReencodeVideo.AcceptableContentType.md)
-   [Video_ReencodeVideo.Output](enums/Video_ReencodeVideo.Output.md)
-   [Video_Repackage.AcceptableContentType](enums/Video_Repackage.AcceptableContentType.md)
-   [Video_Repackage.Output](enums/Video_Repackage.Output.md)
-   [Video_SetThumbnail.AcceptableContentType](enums/Video_SetThumbnail.AcceptableContentType.md)
-   [Video_SetThumbnail.Output](enums/Video_SetThumbnail.Output.md)
-   [Video_TranscribeVideo.AcceptableContentType](enums/Video_TranscribeVideo.AcceptableContentType.md)
-   [Video_TranscribeVideo.Output](enums/Video_TranscribeVideo.Output.md)
-   [Video_UpdateVideo.AcceptableContentType](enums/Video_UpdateVideo.AcceptableContentType.md)
-   [Video_UpdateVideo.Output](enums/Video_UpdateVideo.Output.md)
-   [Video_UploadVideo.AcceptableContentType](enums/Video_UploadVideo.AcceptableContentType.md)
-   [Video_UploadVideo.Output](enums/Video_UploadVideo.Output.md)
## Extensions
-   [APIProtocol](extensions/APIProtocol.md)

Copyright (c) 2019 BunnyWay d.o.o.
