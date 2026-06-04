import BunnyStreamAPI
import BunnyStreamPlayer
import SwiftUI

struct LiveStreamRowView: View {
    let stream: Components.Schemas.LiveStreamModel

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
            if let urlString = stream.thumbnailUrl, let url = URL(string: urlString) {
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
        case .scheduled:     return "Scheduled"
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
