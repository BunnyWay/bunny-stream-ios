import Foundation

extension MediaPlayer {
  /// Creates a `MediaPlayer` instance configured with the specified video and FairPlay details.
  ///
  /// This factory method attempts to create a URL using the given `videoId` and `cdn`. If successful, it initializes
  /// a `FairPlayStreamHandler` with the `videoId` and `libraryId`, sets up the `MediaPlayer`, and associates the `FairPlayStreamHandler`
  /// with the `MediaPlayer`. If any step of the process fails, it returns `nil`.
  ///
  /// - Parameters:
  ///   - video: A `Video` for the video to be played.
  ///   - token: Optional embed-view token, required when the library enforces token authentication.
  ///   - expires: Expiration timestamp that `token` was signed with.
  ///   - headers: Optional HTTP headers (such as `Referer` or `User-Agent`) to inject into the underlying asset's network requests.
  ///
  /// - Returns: A `MediaPlayer` instance.
  ///
  /// Example Usage:
  /// ```
  /// let player = MediaPlayer.make(video: video)
  /// ```
  static func make(video: Video, token: String? = nil, expires: Int64? = nil, headers: [String: String]? = nil) -> MediaPlayer {
    let url = URL(string: video.playlistUrl ?? "")!
    let fairPlayHandler = FairPlayStreamHandler(videoId: video.guid, libraryId: video.libraryId, token: token, expires: expires)
    let subtitlesProvider = MediaPlayerSubtitlesProvider(video: video)
    let cmcdHeaders = CMCDHeaderBuilder.staticSessionHeaders(for: CMCDSession(contentId: video.guid, streamType: .vod))
    let mediaPlayer = MediaPlayer(
      url: url,
      fairPlayHandler: fairPlayHandler,
      subtitlesProvider: subtitlesProvider,
      // An integrator's own headers win over the CMCD ones on a clash.
      httpHeaders: cmcdHeaders.merging(headers ?? [:]) { _, custom in custom }
    )

    Task { try? await subtitlesProvider.loadSubtitles() }

    return mediaPlayer
  }
}
