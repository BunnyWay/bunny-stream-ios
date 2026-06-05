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
        .task { await viewModel.load() }
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
        .fullScreenCover(item: $broadcasterStream) { selection in
            BunnyStreamCameraUploadView(
                liveStream: selection.stream,
                accessKey: dependenciesManager.accessKey,
                libraryId: dependenciesManager.libraryId
            )
        }
    }
}

private extension LiveStreamListView {
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
                    .navigationTitle(stream.title ?? stream.name ?? "Live Stream")
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea()
                } label: {
                    LiveStreamRowView(stream: stream)
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
                }
            }
        }
        .refreshable { await viewModel.load() }
    }

    func canBroadcast(_ stream: Components.Schemas.LiveStreamModel) -> Bool {
        guard case .LiveStreamStatus(let status) = stream.status else { return false }
        return status == .created || status == .scheduled || status == .running
    }
}
