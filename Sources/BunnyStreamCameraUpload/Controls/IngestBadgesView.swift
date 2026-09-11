import SwiftUI

struct IngestBadgesView: View {
  let primaryLive: Bool?
  let backupLive: Bool?

  var body: some View {
    HStack(spacing: 6) {
      if let primaryLive {
        badge(label: "Primary", isLive: primaryLive)
      }
      if let backupLive {
        badge(label: "Backup", isLive: backupLive)
      }
    }
  }

  private func badge(label: String, isLive: Bool) -> some View {
    HStack(spacing: 4) {
      Circle()
        .fill(isLive ? Color.green : Color(white: 0.5))
        .frame(width: 6, height: 6)
      Text(label)
        .font(.system(size: 10, weight: .medium))
        .foregroundColor(.white)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 3)
    .background(Color.black.opacity(0.45))
    .clipShape(Capsule())
  }
}
