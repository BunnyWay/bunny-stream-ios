import Foundation

extension Double {
  func toFormattedTime() -> String {
    guard self.isFinite else { return "--:--" }
    let total = Int(self)
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let seconds = total % 60

    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%d:%02d", minutes, seconds)
    }
  }
}
