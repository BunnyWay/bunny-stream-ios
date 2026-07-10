import BunnyStreamAPI
import BunnyStreamPlayer
import SwiftUI

struct LiveStreamRowView: View {
    let stream: Components.Schemas.LiveStreamModel
    /// Resolves the row's thumbnail URL for a stream (its offline thumbnail, else trailer preview).
    var resolveThumbnail: ((Components.Schemas.LiveStreamModel) async -> URL?)? = nil
    /// Resolves the live ingest status (primary/backup) for a running stream, for the badges.
    var resolveIngestStatus: ((Components.Schemas.LiveStreamModel) async -> LiveStreamListViewModel.IngestLiveStatus?)? = nil

    @State private var resolvedThumbnail: URL?
    @State private var ingestStatus: LiveStreamListViewModel.IngestLiveStatus?

    var body: some View {
        HStack(spacing: 12) {
            thumbnailView
            VStack(alignment: .leading, spacing: 4) {
                Text(stream.title ?? stream.name ?? "Unnamed Stream")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                HStack(spacing: 6) {
                    statusBadge
                    ingestBadges
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .task(id: ingestTaskID) {
            ingestStatus = await resolveIngestStatus?(stream)
        }
    }
}

private extension LiveStreamRowView {
    var thumbnailView: some View {
        Group {
            if let url = resolvedThumbnail {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        placeholderThumbnail
                    }
                }
            } else {
                placeholderThumbnail
            }
        }
        .frame(width: 80, height: 45)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        // Re-resolve when the stream's thumbnail changes (e.g. after it's set/updated).
        .task(id: stream.thumbnailFileName) {
            resolvedThumbnail = await resolveThumbnail?(stream)
        }
    }

    var placeholderThumbnail: some View {
        ZStack {
            Color.secondary.opacity(0.15)
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var statusBadge: some View {
        Text(statusLabel)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    /// Re-fetch ingest status when the stream's live status changes (e.g. scheduled → running).
    var ingestTaskID: String { "\(stream.guid ?? "")|\(statusLabel)" }

    @ViewBuilder
    var ingestBadges: some View {
        if let status = ingestStatus {
            ingestDot("Primary", live: status.primaryLive)
            ingestDot("Backup", live: status.backupLive)
        }
    }

    func ingestDot(_ label: String, live: Bool) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(live ? Color.green : Color.secondary.opacity(0.5))
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.secondary.opacity(0.12))
        .clipShape(Capsule())
    }

    var statusValue: Components.Schemas.LiveStreamStatus? {
        guard case .LiveStreamStatus(let s) = stream.status else { return nil }
        return s
    }

    var statusLabel: String {
        switch statusValue {
        case .running:       return "LIVE"
        case .scheduled:     return "Upcoming"
        case .created:       return "Idle"
        case .ended:         return "Ended"
        case .vodProcessing: return "Processing"
        case .error:         return "Error"
        default:             return "Unknown"
        }
    }

    var statusColor: Color {
        switch statusValue {
        case .running:       return .red
        case .scheduled:     return .blue
        case .vodProcessing: return .orange
        case .error:         return .red
        default:             return .secondary
        }
    }
}
