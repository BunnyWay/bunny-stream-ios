import BunnyStreamUploader
import SwiftUI

struct TrailerPickerView: View {
    let viewModel: LiveStreamListViewModel
    @Binding var selectedId: String
    @Environment(\.dismiss) private var dismiss

    @State private var videos: [(id: String, title: String)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var search = ""
    @State private var isPickingVideo = false
    @State private var pickerVideos: [VideoPicker.Video] = []
    @State private var uploadingTitle: String? = nil
    @State private var uploadError: String? = nil

    private var filtered: [(id: String, title: String)] {
        guard !search.isEmpty else { return videos }
        return videos.filter { $0.title.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    list
                }
            }
            .navigationTitle("Select Trailer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPickingVideo = true
                    } label: {
                        Label("Upload", systemImage: "arrow.up.circle")
                    }
                    .disabled(uploadingTitle != nil)
                }
            }
            .sheet(isPresented: $isPickingVideo) {
                VideoPicker(selectedVideos: $pickerVideos, selectionLimit: 1) { picked in
                    guard let video = picked.first else { return }
                    Task { await uploadTrailer(video) }
                }
            }
        }
        .task { await load() }
    }

    private var list: some View {
        List {
            if let title = uploadingTitle {
                Section {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Uploading \"\(title)\"…")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
            }

            if let error = uploadError {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            if filtered.isEmpty && uploadingTitle == nil {
                Text(search.isEmpty ? "No videos in this library.\nTap ↑ to upload one." : "No results.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(filtered, id: \.id) { video in
                    Button {
                        selectedId = video.id
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(video.title)
                                    .foregroundStyle(.primary)
                                Text(video.id)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if video.id == selectedId {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $search, prompt: "Search videos")
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            videos = try await viewModel.videosForTrailerPicker()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func uploadTrailer(_ video: VideoPicker.Video) async {
        uploadError = nil
        uploadingTitle = video.name

        do {
            let entry = try await viewModel.createTrailerEntry(name: video.name)

            // Start upload in background — the GUID is usable immediately
            let uploader = URLSessionVideoUploader.make(accessKey: viewModel.accessKey)
            let info = VideoInfo(
                content: .data(video.data),
                title: video.name,
                fileType: video.type,
                videoId: entry.id,
                libraryId: viewModel.libraryId
            )
            try await uploader.uploadVideos(with: [info])

            // Add to top of list and auto-select
            videos.insert(entry, at: 0)
            selectedId = entry.id
        } catch {
            uploadError = error.localizedDescription
        }

        uploadingTitle = nil
    }
}
