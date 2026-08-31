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
  ///
  /// - Returns: A `MediaPlayer` instance.
  ///
  /// Example Usage:
  /// ```
  /// let player = MediaPlayer.make(video: video)
  /// ```
  static func make(video: Video, token: String? = nil, expires: Int64? = nil) -> MediaPlayer {
    let url = URL(string: video.playlistUrl ?? "")!
    let fairPlayHandler = FairPlayStreamHandler(videoId: video.guid, libraryId: video.libraryId, token: token, expires: expires)
    let subtitlesProvider = MediaPlayerSubtitlesProvider(video: video)
    let cmcdHeaders = CMCDHeaderBuilder.staticSessionHeaders(for: CMCDSession(contentId: video.guid, streamType: .vod))
    let mediaPlayer = MediaPlayer(
      url: url,
      fairPlayHandler: fairPlayHandler,
      subtitlesProvider: subtitlesProvider,
      httpHeaders: cmcdHeaders
    )

    Task { try? await subtitlesProvider.loadSubtitles() }

    return mediaPlayer
  }
}
