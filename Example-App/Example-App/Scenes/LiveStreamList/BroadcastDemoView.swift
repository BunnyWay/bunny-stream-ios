import BunnyStreamAPI
import BunnyStreamCameraUpload
import SwiftUI

/// Wraps the SDK's broadcaster to exercise `BunnyBroadcastController`: the same broadcast, but
/// driven and observed from outside the view.
///
/// The overlay here is deliberately app-side — it reads the controller's published state rather
/// than anything inside the SDK, which is the point of the API.
struct BroadcastDemoView: View {
    let liveStream: BunnyLiveStream
    let accessKey: String
    let libraryId: Int
    let quality: BroadcastQuality

    @StateObject private var broadcast = BunnyBroadcastController()
    @State private var eventLog: [String] = []
    @State private var isShowingLog = false

    var body: some View {
        ZStack(alignment: .top) {
            BunnyStreamCameraUploadView(
                liveStream: liveStream,
                accessKey: accessKey,
                libraryId: libraryId,
                quality: quality,
                controller: broadcast
            )
            .ignoresSafeArea()

            statusBar
                .padding(.horizontal, 12)
                .padding(.top, 60)
        }
        .onAppear {
            broadcast.onEvent = { event in
                eventLog.insert(describe(event), at: 0)
                if eventLog.count > 40 { eventLog.removeLast() }
            }
        }
        .sheet(isPresented: $isShowingLog) { eventLogSheet }
    }

    /// Everything below reads only from `broadcast` — no access to the SDK's internals.
    private var statusBar: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(stateColor)
                .frame(width: 8, height: 8)
            Text(stateLabel)
                .font(.caption.weight(.semibold))

            if let elapsed = broadcast.elapsedTime {
                Text(elapsed)
                    .font(.caption.monospacedDigit())
            }

            ingestBadge("P", isLive: broadcast.primaryIngestLive)
            ingestBadge("B", isLive: broadcast.backupIngestLive)

            Spacer()

            Button {
                isShowingLog = true
            } label: {
                Image(systemName: "list.bullet.rectangle")
                    .overlay(alignment: .topTrailing) {
                        if !eventLog.isEmpty {
                            Circle().fill(.red).frame(width: 6, height: 6).offset(x: 4, y: -4)
                        }
                    }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.55), in: Capsule())
    }

    /// `nil` liveness means the server hasn't reported yet — shown as dimmed rather than red,
    /// so "unknown" never looks like "down".
    private func ingestBadge(_ label: String, isLive: Bool?) -> some View {
        Text(label)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(isLive == true ? Color.green : Color.white.opacity(0.15), in: Capsule())
            .opacity(isLive == nil ? 0.4 : 1)
    }

    private var eventLogSheet: some View {
        NavigationView {
            Group {
                if eventLog.isEmpty {
                    Text("No events yet").foregroundStyle(.secondary)
                } else {
                    List(Array(eventLog.enumerated()), id: \.offset) { _, entry in
                        Text(entry).font(.caption.monospaced())
                    }
                }
            }
            .navigationTitle("Broadcast events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isShowingLog = false }
                }
            }
        }
    }

    private var stateLabel: String {
        switch broadcast.state {
        case .idle:      return "IDLE"
        case .preparing: return "PREPARING"
        case .live:      return "LIVE"
        }
    }

    private var stateColor: Color {
        switch broadcast.state {
        case .idle:      return .gray
        case .preparing: return .orange
        case .live:      return .red
        }
    }

    private func describe(_ event: BunnyBroadcastEvent) -> String {
        switch event {
        case .preparing:
            return "preparing"
        case .started:
            return "started"
        case .stopped:
            return "stopped"
        case .reconnecting(let attempt, let usingBackup):
            return "reconnecting #\(attempt) → \(usingBackup ? "backup" : "primary")"
        case .reconnectFailed:
            return "reconnect gave up"
        case .ingestStatusChanged(let primary, let backup):
            return "ingest primary=\(describe(primary)) backup=\(describe(backup))"
        case .failedOver(let usingBackup):
            return "failed over → \(usingBackup ? "backup" : "primary")"
        case .failed(let message):
            return "failed: \(message)"
        }
    }

    private func describe(_ live: Bool?) -> String {
        live.map(String.init(describing:)) ?? "unknown"
    }
}
