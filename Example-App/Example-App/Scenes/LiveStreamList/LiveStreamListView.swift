import BunnyStreamAPI
import BunnyStreamCameraUpload
import BunnyStreamPlayer
import SwiftUI

struct LiveStreamListView: View {
    @ObservedObject private var viewModel: LiveStreamListViewModel
    private let dependenciesManager: DependenciesManager

    private struct BroadcastSelection: Identifiable {
        let id: String
        let stream: Components.Schemas.LiveStreamModel
    }

    @State private var broadcasterStream: BroadcastSelection?
    @State private var ingestDetailsStream: BroadcastSelection?
    @State private var streamPendingDeletion: BroadcastSelection?
    @State private var editingStream: BroadcastSelection?
    @State private var isShowingCreate = false

    init(viewModel: LiveStreamListViewModel, dependenciesManager: DependenciesManager) {
        self.viewModel = viewModel
        self.dependenciesManager = dependenciesManager
    }

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded:
                listView
            case .failed(let message):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") { Task { await viewModel.load() } }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Live Streams")
        .onAppear {
            // Reload on every appearance (incl. returning from the player) so statuses refresh.
            // Silent refresh when data already exists to avoid the full-screen spinner flash.
            Task { await viewModel.load(showLoadingState: viewModel.streams.isEmpty) }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { isShowingCreate = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingCreate) {
            CreateLiveStreamView(viewModel: viewModel) {
                await viewModel.load()
            }
        }
        .fullScreenCover(item: $broadcasterStream, onDismiss: {
            // .onAppear doesn't re-fire when a fullScreenCover dismisses, so reload here to pick
            // up the new status after broadcasting ends.
            Task { await viewModel.load(showLoadingState: false) }
        }) { selection in
            BunnyStreamCameraUploadView(
                liveStream: selection.stream,
                accessKey: dependenciesManager.accessKey,
                libraryId: dependenciesManager.libraryId
            )
        }
        .sheet(item: $ingestDetailsStream) { selection in
            LiveStreamIngestDetailsView(stream: selection.stream)
        }
        .sheet(item: $editingStream) { selection in
            CreateLiveStreamView(viewModel: viewModel, editingStream: selection.stream) {
                await viewModel.load()
            }
        }
        .alert("Delete live stream?", isPresented: deleteAlertBinding, presenting: streamPendingDeletion) { selection in
            Button("Delete", role: .destructive) {
                Task { await viewModel.delete(stream: selection.stream) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { selection in
            Text("\"\(selection.stream.title ?? selection.stream.name ?? "This stream")\" will be permanently deleted.")
        }
        .alert("Error", isPresented: actionErrorBinding, presenting: viewModel.actionError) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }
}

private extension LiveStreamListView {
    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { streamPendingDeletion != nil },
            set: { if !$0 { streamPendingDeletion = nil } }
        )
    }

    var actionErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.actionError != nil },
            set: { if !$0 { viewModel.actionError = nil } }
        )
    }

    var listView: some View {
        Group {
            if viewModel.streams.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No live streams yet.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                streamList
            }
        }
    }

    var streamList: some View {
        List {
            ForEach(viewModel.streams, id: \.guid) { stream in
                NavigationLink {
                    BunnyStreamLivePlayer(
                        accessKey: dependenciesManager.accessKey,
                        libraryId: dependenciesManager.libraryId,
                        streamId: stream.guid ?? ""
                    )
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea()
                } label: {
                    LiveStreamRowView(
                        stream: stream,
                        resolveThumbnail: { stream in await viewModel.liveThumbnailURL(for: stream) },
                        resolveIngestStatus: { stream in await viewModel.liveIngestStatus(for: stream) }
                    )
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if canBroadcast(stream) {
                        Button {
                            guard let guid = stream.guid else { return }
                            broadcasterStream = BroadcastSelection(id: guid, stream: stream)
                        } label: {
                            Label("Go Live", systemImage: "dot.radiowaves.left.and.right")
                        }
                        .tint(.red)
                    }
                    Button {
                        guard let guid = stream.guid else { return }
                        ingestDetailsStream = BroadcastSelection(id: guid, stream: stream)
                    } label: {
                        Label("RTMP", systemImage: "info.circle")
                    }
                    .tint(.indigo)
                    Button {
                        guard let guid = stream.guid else { return }
                        editingStream = BroadcastSelection(id: guid, stream: stream)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                    Button(role: .destructive) {
                        guard let guid = stream.guid else { return }
                        streamPendingDeletion = BroadcastSelection(id: guid, stream: stream)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .refreshable { await viewModel.load(showLoadingState: false) }
    }

    func canBroadcast(_ stream: Components.Schemas.LiveStreamModel) -> Bool {
        guard case .LiveStreamStatus(let status) = stream.status else { return false }
        return status == .created || status == .scheduled || status == .running
    }
}
