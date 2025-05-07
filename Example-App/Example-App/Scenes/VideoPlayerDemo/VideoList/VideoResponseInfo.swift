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
  
  var isEncodingCompleted: Bool {
    encodeProgress == 100
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
