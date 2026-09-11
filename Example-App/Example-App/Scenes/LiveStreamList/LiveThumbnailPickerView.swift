import BunnyStreamAPI
import SwiftUI

/// Browses the thumbnails Bunny automatically generates while a live stream is running
/// (`GET /library/{libraryId}/live/{streamId}/thumbnails`). Tapping one sets it as the
/// offline thumbnail URL via the `onSelect` callback.
struct LiveThumbnailPickerView: View {
    let viewModel: LiveStreamListViewModel
    let stream: BunnyLiveStream
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var items: [BunnyLiveStreamThumbnail] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    emptyState(
                        title: "Couldn't load thumbnails",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle"
                    )
                } else if items.isEmpty {
                    emptyState(
                        title: "No generated thumbnails",
                        message: "Bunny generates thumbnails while the stream is live. Go live once, then check back.",
                        systemImage: "photo.on.rectangle.angled"
                    )
                } else {
                    grid
                }
            }
            .navigationTitle("Generated Thumbnails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task { await load() }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    Button {
                        guard let url = item.url else { return }
                        onSelect(resolvedURL(url)?.absoluteString ?? url)
                        dismiss()
                    } label: {
                        tile(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private func tile(_ item: BunnyLiveStreamThumbnail) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            RefererAsyncImage(url: item.url.flatMap(resolvedURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(16 / 9, contentMode: .fill)
                case .failure:
                    placeholder
                case .empty:
                    ZStack { placeholder; ProgressView() }
                @unknown default:
                    placeholder
                }
            }
            .frame(height: 92)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            if let timestamp = item.timestamp {
                Text(timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.secondary.opacity(0.15)
            Image(systemName: "photo").foregroundStyle(.secondary)
        }
    }

    private func emptyState(title: String, message: String, systemImage: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Generated thumbnail URLs may be absolute or storage-relative; resolve relative ones against
    /// the stream's playback host (same host as the HLS playlist), mirroring the SDK's
    /// `BunnyLiveStream.offlineThumbnailUrl`.
    private func resolvedURL(_ raw: String) -> URL? {
        if let url = URL(string: raw), url.scheme != nil { return url }
        guard let playbackUrl = stream.playbackUrl, let host = URL(string: playbackUrl)?.host else {
            return URL(string: raw)
        }
        let path = raw.hasPrefix("/") ? String(raw.dropFirst()) : raw
        return URL(string: "https://\(host)/\(path)")
    }

    private func load() async {
        guard let guid = stream.id, !guid.isEmpty else {
            errorMessage = "Missing stream ID."
            isLoading = false
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            items = try await viewModel.liveThumbnails(streamId: guid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
