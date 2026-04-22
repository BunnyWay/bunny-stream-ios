import AVFoundation
import SwiftUI

/// A SwiftUI view that provides an integrated video player experience
/// using BunnyStream.
///
/// `BunnyStreamPlayer` handles video loading, configuration, and playback.
/// It supports customizable themes and icons, as well as automatic
/// error handling and retry mechanisms.
public struct BunnyStreamPlayer: View {

  /// The video configuration loader.
  let videoPlayerConfigLoader = VideoPlayerConfigLoader()
  /// The access key for authentication. Can be `nil` for public videos.
  var accessKey: String?
  /// The heatmap data loader. Will be `nil` if no `accessKey` is provided.
  var heatmapLoader: HeatmapLoader?
  /// The unique ID of the video to be played.
  let videoId: String
  /// The ID of the video library.
  let libraryId: Int
  /// The embed view token. Required when token authentication is enabled for the video library.
  let token: String?
  /// The expiration timestamp for the embed view token.
  let expires: Int64?
  /// Optional HTTP headers to be passed to the underlying video player's network requests.
  /// Useful for bypassing CDN restrictions, such as passing a `Referer`
  let headers: [String: String]?

  /// The loading state of the video player.
  @State private var loadingState: VideoLoadingState = .loading
  /// The media player instance.
  @State var player: MediaPlayer?
  /// The theme configuration for the video player.
  @State var theme: VideoPlayerTheme = .defaultTheme
  /// The video player configuration.
  @State var videoConfig = VideoPlayerConfig()
  /// The set of custom player icons.
  internal var playerIcons: PlayerIcons?

  /// The different states of video loading.
  enum VideoLoadingState {
    /// Indicates that the video is currently loading.
    case loading
    /// Indicates that the video has loaded successfully with its metadata.
    case loaded(MediaPlayer, Video, Heatmap)
    /// Indicates that video loading has failed.
    case failed
    /// Indicates that loading has failed due to a specific error.
    case loaderFailed(VideoPlayerError)
  }

  /// Initializes a new instance of the `BunnyStreamPlayer`.
  ///
  /// This initializer sets up the video player with the necessary configurations
  /// such as access key, video ID, library ID. Optionally, custom player
  /// icons can be provided. If no accessKey is provided, only Public videos will be playable.
  ///
  /// - Parameters:
  ///   - accessKey: The access key for authentication. Can be `nil` for public videos.
  ///   - videoId: The unique ID of the video to be played.
  ///   - libraryId: The ID of the video library.
  ///   - token: The embed view token. Required when token authentication is enabled for the video library.
  ///   - expires: The expiration timestamp for the embed view token.
  ///   - playerIcons: Optional custom icons for the video player.
  ///
  /// ### Usage Example:
  /// ```swift
  /// struct VideoPlayerDemoView: View {
  ///     var body: some View {
  ///         BunnyStreamPlayer(accessKey: "your_access_key",
  ///                          videoId: "your_video_id",
  ///                          libraryId: 123,
  ///                          token: "cdn_token",
  ///                          expires: 1234567890)
  ///         .navigationBarTitle(Text("Video Player"), displayMode: .inline)
  ///     }
  /// }
  /// ```
  public init(
    accessKey: String?,
    videoId: String,
    libraryId: Int,
    token: String? = nil,
    expires: Int64? = nil,
    playerIcons: PlayerIcons? = nil,
    headers: [String: String]? = nil
  ) {
    self.accessKey = accessKey
    self.videoId = videoId
    self.libraryId = libraryId
    self.token = token
    self.expires = expires
    self.headers = headers
    if let accessKey {
      self.heatmapLoader = HeatmapLoader(bunnyStreamAPI: .init(accessKey: accessKey))
    }
    if let playerIcons {
      self.playerIcons = playerIcons
      self.theme.images = playerIcons
    }
    FontManager.registerFonts()
  }

  /// The main body of the `BunnyStreamPlayer`.
  public var body: some View {
    VStack(alignment: .center) {
      switch loadingState {
      case .loading:
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      case .loaded(let mediaPlayer, let video, let heatmap):
        BunnyStreamPlayerContainerView(player: mediaPlayer, video: video, heatmap: heatmap)
          .environment(\.videoPlayerTheme, theme)
          .environment(\.videoPlayerConfig, videoConfig)
          .onAppear {
            setupAudioSession()
            mediaPlayer.play()
          }
      case .failed:
        reloadButton()
      case .loaderFailed(let error):
        errorView(for: error)
      }
    }
    .task {
      await loadVideo()
    }
    .onDisappear {
      player?.pause()
    }
  }

  /// Loads the video and its configuration asynchronously.
  @MainActor
  func loadVideo() async {
    loadingState = .loading
    do {
      let videoConfigResponse = try await videoPlayerConfigLoader.load(libraryId: libraryId, videoId: videoId, token: token, expires: expires)
      var video = Video(response: videoConfigResponse)
      // If Public Video (no access key), heatmap is not loaded - heatmapLoader is nil
      let heatmap = try? await heatmapLoader?.loadHeatmap(videoId: videoId, libraryId: libraryId)
      
      VideoPlayerConfig(response: videoConfigResponse).map { self.videoConfig = $0 }
      let player = MediaPlayer.make(video: video, headers: self.headers)
      self.player = player
      video.adjustLength(player.duration)
      self.theme = VideoPlayerTheme(config: videoConfigResponse) ?? theme
      if let playerIcons {
        self.theme.images = playerIcons
      }
      
      loadingState = .loaded(player, video, heatmap ?? Heatmap(data: [:]))
    } catch let error as VideoPlayerError {
      print("[BunnyStreamPlayer Error]: \(error)")
      loadingState = .loaderFailed(error)
    } catch {
      print("[BunnyStreamPlayer Error]: \(error)")
      loadingState = .failed
    }
  }

  /// Returns a reload button view for retrying video loading.
  private func reloadButton() -> some View {
    Button {
      Task { await loadVideo() }
    } label: {
      theme.images.reload
        .resizable()
        .scaledToFill()
        .frame(width: 40, height: 40)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  /// Returns an error view based on the specific `VideoPlayerError` encountered.
  private func errorView(for error: VideoPlayerError) -> some View {
    VStack(spacing: 8) {
      switch error {
      case .notFound:
        theme.images.videoNotFound
          .resizable()
          .scaledToFill()
          .frame(width: 40, height: 40)
        Text(Lingua.Player.videoNotFound)
          .font(theme.font.size(11))
      case .audioError:
        Text(Lingua.Error.audioError)
          .font(theme.font.size(13))
        reloadButton()
      default:
        reloadButton()
      }
    }
  }

  /// Configures the audio session for video playback.
  private func setupAudioSession() {
#if os(iOS)
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .moviePlayback, options: [])
      try session.setActive(true)
    } catch {
      player?.stop()
      loadingState = .loaderFailed(.audioError)
    }
#endif
  }
}
