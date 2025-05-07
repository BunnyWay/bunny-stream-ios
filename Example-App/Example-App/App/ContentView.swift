//
//  ContentView.swift
//  Example-App
//
//  Created by Egzon Arifi on 06/10/2023.
//

import SwiftUI
import BunnyStreamUploader
import BunnyStreamCameraUpload

struct ContentView: View {
  @EnvironmentObject var dependenciesManager: DependenciesManager
  @State private var isShowingSheet = false
  @State private var tempAccessKey: String = ""
  @State private var libraryId: String = ""
  @State private var isStreamingPresented: Bool = false
  @State private var isShowingVideoIdAlert = false
  @State private var videoId: String = ""
  @State private var showPublicVideoPlayer = false
  
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
            Button {
              isStreamingPresented.toggle()
            } label: {
              Image(systemName: "dot.radiowaves.left.and.right")
              Text("Start uploading")
            }
          }
          Button {
            videoId = ""
            isShowingVideoIdAlert = true
          } label: {
            Text("Direct Video Play")
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
        libraryId: dependenciesManager.libraryId
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
