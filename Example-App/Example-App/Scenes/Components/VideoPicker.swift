//
//  VideoPicker.swift
//  Example-App
//
//  Created by Egzon Arifi on 12/10/2023.
//

import SwiftUI
import UIKit
import PhotosUI
import AVFoundation

struct VideoPicker: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode
  @Binding var selectedVideos: [Video]
  var selectionLimit: Int = 5
  var onCompletion: ([Video]) -> Void

  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    configuration.selectionLimit = selectionLimit
    configuration.filter = .videos
    
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

extension VideoPicker {
  class Coordinator: PHPickerViewControllerDelegate {
    private let parent: VideoPicker
    
    init(_ parent: VideoPicker) {
      self.parent = parent
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      if results.isEmpty {
        DispatchQueue.main.async { [weak self] in
          self?.parent.presentationMode.wrappedValue.dismiss()
        }
        return
      }
      
      var videos = [Video]()
      
      for result in results {
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { (url, error) in
          if let url = url, let videoData = try? Data(contentsOf: url) {
            let videoName = url.lastPathComponent
            let videoType = url.pathExtension
            videos.append(Video(data: videoData, name: videoName, type: videoType))
          } else {
            if let error = error {
              print("Error loading video: \(error)")
            }
          }
          
          if results.count == videos.count {
            DispatchQueue.main.async { [weak self] in
              self?.parent.selectedVideos = videos
              self?.parent.onCompletion(videos)
              self?.parent.presentationMode.wrappedValue.dismiss()
            }
          }
        }
      }
    }
  }
  
  struct Video {
    var data: Data
    var name: String
    var type: String
  }
}
