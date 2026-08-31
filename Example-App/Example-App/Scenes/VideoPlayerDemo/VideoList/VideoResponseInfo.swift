//
//  VideoResponseInfo.swift
//  Example-App
//
//  Created by Egzon Arifi on 10/11/2023.
//

import Foundation

struct VideoResponseInfo: Hashable, Identifiable {
  var id: String
  var title: String?
  var thumbnailCount: Int32
  var width: Float
  var height: Float
  var length: Int32
  var libraryId: Int64
  var encodeProgress: Int32
  /// Raw `VideoModelStatus` from the API, `nil` when the response omitted it.
  var status: Int32?
  var storageSize: Double
  var thumbnailFileName: String?
  var averageWatchTime: Int64
  var views: Int
  
  func thumbnailFileURL() -> URL? {
    // No thumbnail URL available here
    return nil
  }
  
  var formattedFileSize: String {
    let oneMB = 1000.0 * 1000.0
    let oneGB = oneMB * 1000.0
    
    if storageSize < oneGB {
      return String(format: "%.2f MB", storageSize / oneMB)
    } else {
      return String(format: "%.2f GB", storageSize / oneGB)
    }
  }
  
  /// Where the video is in Bunny's encoding pipeline.
  enum EncodingState {
    case processing, finished, failed
  }

  /// Derived from the API's `status` field: 0 Created, 1 Uploaded, 2 Processing, 3 Transcoding,
  /// 4 Finished, 5 Error, 6 UploadFailed, 7 JitSegmenting, 8 JitPlaylistsCreated.
  ///
  /// `encodeProgress` alone isn't enough: libraries with JIT encoding finish at status 8 without
  /// the progress ever reaching 100, and a failed encode would otherwise read as "Processing"
  /// forever.
  var encodingState: EncodingState {
    switch status {
    case 4, 8:
      return .finished
    case 5, 6:
      return .failed
    case .some:
      return .processing
    case .none:
      return encodeProgress == 100 ? .finished : .processing
    }
  }

  var isEncodingCompleted: Bool {
    encodingState == .finished
  }

  /// Badge text while encoding — with the percentage once the encoder reports progress.
  var processingLabel: String {
    (1..<100).contains(encodeProgress) ? "Processing \(encodeProgress)%" : "Processing"
  }
}
