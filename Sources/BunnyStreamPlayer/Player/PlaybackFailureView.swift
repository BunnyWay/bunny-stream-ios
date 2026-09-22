import SwiftUI

/// Covers the player once playback has failed, so the viewer isn't left on a black frame with
/// controls that do nothing.
///
/// A blocked stream — an HTTP 403 (geo-blocking, referrer protection, token auth) or a CDN host
/// sinkholed in DNS by Bunny's "Blocked countries" — shows only a generic "not available" with no
/// retry. Retrying can't help, and the cause is deliberately not surfaced to viewers ("not
/// available in your region" is an invitation to use a VPN). Library owners diagnose it from their
/// Bunny logs.
///
/// A device with no connection says so and keeps the retry, because nothing about that failure is
/// a verdict on the video. Every other failure keeps the bare retry it always had.
struct PlaybackFailureView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  let error: Error
  let onRetry: () -> Void

  var body: some View {
    ZStack {
      Color.black
      switch error as? VideoPlayerError {
      case .notAvailable:
        VideoNotAvailableView()
      case .noInternetConnection:
        NoInternetConnectionView(onRetry: onRetry)
      default:
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

/// Generic "Video is not available" message, used for every blocked stream regardless of cause.
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

/// "No internet connection", with the retry kept — the video is fine, the connection isn't.
struct NoInternetConnectionView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  let onRetry: () -> Void

  var body: some View {
    VStack(spacing: 8) {
      Button(action: onRetry) {
        theme.images.reload
          .resizable()
          .scaledToFill()
          .frame(width: 40, height: 40)
      }
      Text(Lingua.Player.noInternetConnection)
        .font(theme.font.size(11))
    }
  }
}
