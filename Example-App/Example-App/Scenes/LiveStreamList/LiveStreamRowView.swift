import BunnyStreamAPI
import BunnyStreamPlayer
import SwiftUI

struct LiveStreamRowView: View {
    let stream: Components.Schemas.LiveStreamModel
    /// Optional fallback resolver used when the stream has no `thumbnailUrl`.
    var resolveThumbnail: ((String) async -> URL?)? = nil

    @State private var resolvedThumbnail: URL?

    var body: some View {
        HStack(spacing: 12) {
            thumbnailView
            VStack(alignment: .leading, spacing: 4) {
                Text(stream.title ?? stream.name ?? "Unnamed Stream")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                statusBadge
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private extension LiveStreamRowView {
    var thumbnailView: some View {
        Group {
            if let url = effectiveThumbnailURL {
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
        .task { await loadThumbnailIfNeeded() }
    }

    var effectiveThumbnailURL: URL? {
        if let urlString = stream.thumbnailUrl, let url = URL(string: urlString) {
            return url
        }
        return resolvedThumbnail
    }

    func loadThumbnailIfNeeded() async {
        guard stream.thumbnailUrl == nil || stream.thumbnailUrl?.isEmpty == true,
              resolvedThumbnail == nil,
              let resolveThumbnail,
              let guid = stream.guid, !guid.isEmpty
        else { return }
        resolvedThumbnail = await resolveThumbnail(guid)
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
