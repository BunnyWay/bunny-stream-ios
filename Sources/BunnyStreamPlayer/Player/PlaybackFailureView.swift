import SwiftUI

/// Covers the player once playback has failed, so the viewer isn't left on a black frame with
/// controls that do nothing.
///
/// Any HTTP 403 (geo-blocking, referrer protection, token auth) shows only a generic
/// "not available" with no retry — retrying can't help, and the cause is deliberately not surfaced
/// to viewers ("not available in your region" is an invitation to use a VPN). Library owners
/// diagnose it from their Bunny logs. Every other failure offers a retry.
struct PlaybackFailureView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  let error: Error
  let onRetry: () -> Void

  var body: some View {
    ZStack {
      Color.black
      if (error as? VideoPlayerError) == .notAvailable {
        VideoNotAvailableView()
      } else {
        Button(action: onRetry) {
          theme.images.reload
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
        }
      }
    }
    .foregroundColor(.white)
  }
}

/// Generic "Video is not available" message, used for every HTTP 403 regardless of its cause.
struct VideoNotAvailableView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme

  var body: some View {
    VStack(spacing: 8) {
      theme.images.videoNotFound
        .resizable()
        .scaledToFill()
        .frame(width: 40, height: 40)
      Text(Lingua.Player.videoNotAvailable)
        .font(theme.font.size(11))
    }
  }
}
