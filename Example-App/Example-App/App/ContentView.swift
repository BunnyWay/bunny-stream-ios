//
//  ContentView.swift
//  Example-App
//
//  Created by Egzon Arifi on 06/10/2023.
//

import SwiftUI
import BunnyStreamUploader
import BunnyStreamCameraUpload

/// Broadcast quality options exposed in the Example App UI, each mapping to a `BroadcastQuality` preset.
/// The selection is shared (via `@AppStorage`) between the Camera Upload and Live Streams screens.
enum BroadcastQualityOption: String, CaseIterable, Identifiable {
  case sd480
  case hd720
  case fullHd1080
  case fullHd1080p60

  var id: String { rawValue }

  var label: String {
    switch self {
    case .sd480: return "480p · 30fps"
    case .hd720: return "720p · 30fps"
    case .fullHd1080: return "1080p · 30fps"
    case .fullHd1080p60: return "1080p · 60fps"
    }
  }

  var quality: BroadcastQuality {
    switch self {
    case .sd480: return .sd480
    case .hd720: return .hd720
    case .fullHd1080: return .fullHd1080
    case .fullHd1080p60: return .fullHd1080p60
    }
  }
}

/// Shared AppStorage key for the selected broadcast quality across Example App screens.
let broadcastQualityStorageKey = "broadcastQuality"

struct ContentView: View {
  @EnvironmentObject var dependenciesManager: DependenciesManager
  @State private var isShowingSheet = false
  @State private var tempAccessKey: String = ""
  @State private var libraryId: String = ""
  @State private var isStreamingPresented: Bool = false
  @State private var isShowingVideoIdAlert = false
  @State private var videoId: String = ""
  @State private var showPublicVideoPlayer = false
  @AppStorage(broadcastQualityStorageKey) private var broadcastQualityRaw = BroadcastQualityOption.fullHd1080.rawValue

  private var broadcastQuality: BroadcastQualityOption {
    BroadcastQualityOption(rawValue: broadcastQualityRaw) ?? .fullHd1080
  }
  
  var body: some View {
    NavigationStack {
      List {
        Section("Actions") {
          NavigationLink("Video Player") {
            VideoListView(viewModel: .init(bunnyStreamAPI: dependenciesManager.bunnyStreamAPI))
              .environmentObject(dependenciesManager)
          }
          NavigationLink("Video Uploader") {
            VideoUploaderTypesView()
              .environmentObject(dependenciesManager)
          }
          NavigationLink("Camera Upload") {
            Form {
              Section("Broadcast Quality") {
                Picker("Quality", selection: $broadcastQualityRaw) {
                  ForEach(BroadcastQualityOption.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                  }
                }
                .pickerStyle(.inline)
                .labelsHidden()
              }
              Section {
                Button {
                  isStreamingPresented.toggle()
                } label: {
                  Label("Start uploading", systemImage: "dot.radiowaves.left.and.right")
                }
              }
            }
            .navigationTitle("Camera Upload")
          }
          Button {
            videoId = ""
            isShowingVideoIdAlert = true
          } label: {
            Text("Direct Video Play")
          }
          NavigationLink("Live Streams") {
            LiveStreamListView(
              viewModel: .init(api: dependenciesManager.bunnyStreamAPI, libraryId: dependenciesManager.libraryId, accessKey: dependenciesManager.accessKey),
              dependenciesManager: dependenciesManager
            )
          }
        }
        
        Section("Configuration") {
          configurationView
        }
      }
      .navigationTitle("BunnyStream Demo")
      .alert("Enter Video ID", isPresented: $isShowingVideoIdAlert) {
        TextField("Video ID", text: $videoId)
        Button("Cancel", role: .cancel) {
          videoId = ""
        }
        Button("Play") {
          showPublicVideoPlayer = true
        }
        .disabled(videoId.isEmpty)
      } message: {
        Text("Please enter the ID of the video you want to play.")
      }
      .sheet(isPresented: $showPublicVideoPlayer) {
        PublicVideoDemoView(dependenciesManager: dependenciesManager, videoId: videoId)
      }

    }
    .fullScreenCover(isPresented: $isStreamingPresented,
                     content: {
      BunnyStreamCameraUploadView(
        accessKey: dependenciesManager.accessKey,
        libraryId: dependenciesManager.libraryId,
        quality: broadcastQuality.quality
      )
    })
    .onAppear {
      tempAccessKey = dependenciesManager.accessKey
      libraryId = String(dependenciesManager.libraryId)
    }
  }
}

private extension ContentView {
  var configurationView: some View {
    Button("BunnyStream Configuration") {
      isShowingSheet = true
    }
    .sheet(isPresented: $isShowingSheet) {
      NavigationStack {
        Form {
          Section("Video Library ID") {
            TextField("Enter your Library ID", text: $libraryId)
              .keyboardType(.numberPad)
              .autocapitalization(.none)
              .disableAutocorrection(true)
          }
          Section("Video Library API Key") {
            TextField("Enter your Library API Key", text: $tempAccessKey)
              .autocapitalization(.none)
              .disableAutocorrection(true)
            
          }
        }
        .formStyle(.grouped)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
              saveConfig()
            }
            .bold()
          }
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
              isShowingSheet = false
            }
          }
        }
      }
    }
  }

  private func saveConfig() {
    dependenciesManager.storedAccessKey = tempAccessKey
    dependenciesManager.libraryId = Int(libraryId) ?? .zero
    isShowingSheet = false
  }
}
