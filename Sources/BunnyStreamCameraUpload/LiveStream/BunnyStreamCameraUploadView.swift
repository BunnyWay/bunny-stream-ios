import BunnyStreamAPI
import HaishinKit
import SwiftUI

/// A SwiftUI view that provides camera streaming functionality for Bunny Stream uploads.
///
/// This view handles:
/// - Camera stream configuration and display
/// - Permission management for camera and microphone
/// - User controls for streaming
/// - Status messages via snackbar
///
/// Example usage:
/// ```swift
/// BunnyStreamCameraUploadView(
///   accessKey: "<access_key>",
///   libraryId: <library_id>
///  )
/// ```
public struct BunnyStreamCameraUploadView: View {
  /// The visual theme applied to the view.
  @State var theme: Theme = .defaultTheme

  /// The view model that manages the streaming functionality.
  @ObservedObject var streamViewModel: BunnyStreamCameraUploadViewModel

  /// The view model that manages camera and microphone permissions.
  @ObservedObject var permissionsViewModel = PermissionsViewModel()

  /// The presentation mode used to dismiss the view.
  @Environment(\.presentationMode) var presentationMode

  /// The live stream view that displays the camera feed.
  private var lfView: MTHKSwiftUiView!

  /// The view containing stream control buttons and UI elements.
  private var controlsView: ControlsView!

  /// Creates a new camera upload view with the specified stream view model.
  /// - Parameter streamViewModel: The view model that manages streaming functionality.
  init(
    streamViewModel: BunnyStreamCameraUploadViewModel,
    controller: BunnyBroadcastController? = nil
  ) {
    self.streamViewModel = streamViewModel
    // Link both ways: the controller drives the view model, the view model reports back.
    streamViewModel.broadcastController = controller
    controller?.viewModel = streamViewModel
    streamViewModel.configureStream()
    lfView = MTHKSwiftUiView(rtmpStream: $streamViewModel.rtmpStream)
    controlsView = ControlsView(viewModel: streamViewModel)
  }

  /// Initializes a new instance of the BunnyStreamCameraUploadView.
  ///
  /// This initializer sets up the video stream view with the necessary configurations
  /// such as access key,  library ID
  ///
  /// - Parameters:
  ///   - accessKey: The access key for authentication.
  ///   - libraryId: The ID of the video library.
  ///   - quality: The encoder configuration (resolution, frame rate, bitrates). Defaults to `.default` (1080p30).
  ///   - controller: An optional handle for starting/stopping the broadcast and observing it
  ///     from outside the view. The view works without one, using its built-in controls.
  ///
  /// Usage Example:
  /// ```
  /// struct VideoStreamDemoView: View {
  ///  var body: some View {
  ///    Group { }
  ///     .fullScreenCover(isPresented: $isStreamingPresented,
  ///                      content: {
  ///      BunnyStreamCameraUploadView(
  ///       accessKey: "<access_key>",
  ///       libraryId: <library_id>,
  ///       quality: .fullHd1080
  ///      )
  ///   })
  ///  }
  /// }
  /// ```
  public init(
    accessKey: String,
    libraryId: Int,
    quality: BroadcastQuality = .default,
    controller: BunnyBroadcastController? = nil
  ) {
    let config = StreamConfig(accessKey: accessKey, libraryId: libraryId, quality: quality)
    let videoCreator = VideoCreator(bunnyStreamAPI: .init(accessKey: accessKey), libraryId: libraryId)
    let streamViewModel = BunnyStreamCameraUploadViewModel(streamConfig: config, videoCreator: videoCreator)
    self.init(streamViewModel: streamViewModel, controller: controller)
  }

  /// Initializes the broadcaster directly from an existing live stream.
  /// Uses the primary RTMP ingest endpoint and `streamKey` from the stream — no video creation step needed.
  /// - Parameters:
  ///   - liveStream: The live stream to publish to. Build it from an API response with
  ///     `BunnyLiveStream(from:)`.
  ///   - quality: The encoder configuration (resolution, frame rate, bitrates). Defaults to `.default` (1080p30).
  ///   - controller: An optional handle for starting/stopping the broadcast and observing it
  ///     from outside the view.
  public init(
    liveStream: BunnyLiveStream,
    accessKey: String,
    libraryId: Int,
    quality: BroadcastQuality = .default,
    controller: BunnyBroadcastController? = nil
  ) {
    let config = StreamConfig(
      rtmpUrl: liveStream.primaryIngestUrl ?? BunnyStreamCameraUploadView.bunnyFallbackRtmpUrl,
      streamKey: liveStream.streamKey ?? "",
      backupRtmpUrl: liveStream.backupIngestUrl,
      accessKey: accessKey,
      libraryId: libraryId,
      streamId: liveStream.id,
      quality: quality
    )
    let streamViewModel = BunnyStreamCameraUploadViewModel(streamConfig: config)
    self.init(streamViewModel: streamViewModel, controller: controller)
  }

  /// Bunny global RTMP ingest URL — used when the stream model doesn't include an ingest endpoint.
  static let bunnyFallbackRtmpUrl = "rtmp://global.rtmp.mediadelivery.net/live"

  /// The body of the view that handles different states:
  /// - Loading state while checking permissions
  /// - Permission request view if permissions aren't granted
  /// - Live stream view if all permissions are granted
  public var body: some View {
    Group {
      if permissionsViewModel.arePermissionsNotDetermined {
        ProgressView()
          .frame(maxWidth: .infinity)
      } else if permissionsViewModel.arePermissionsGranted {
        liveStreamView()
      } else {
        permissionsView()
      }
    }
    .overlay(alignment: .bottom) {
      if let message = streamViewModel.snackbarMessage  {
        SnackbarView(message: message) {
          streamViewModel.snackbarMessage = nil
        }
        .transition(.move(edge: .bottom))
      }
    }
    .onAppear {
      streamViewModel.registerForPublishEvent()
    }
    .onDisappear {
      streamViewModel.unregisterForPublishEvent()
    }
  }
}

private extension BunnyStreamCameraUploadView {
  /// Creates the live streaming view with camera feed and controls.
  /// - Returns: A view containing the camera feed and streaming controls.
  func liveStreamView() -> some View {
    ZStack {
      lfView
        .ignoresSafeArea()
        .onTapGesture { location in
          self.streamViewModel.tapScreen(touchPoint: location)
        }

      controlsView
        .environment(\.theme, theme)
    }
  }

  /// Creates a view that handles permission-related UI.
  /// - Returns: A view displaying permission status and settings access button.
  func permissionsView() -> some View {
    VStack {
      HStack {
        Spacer()

        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          theme.icons.close
            .resizable()
            .scaledToFill()
        }
        .frame(width: 20, height: 20)
      }

      Spacer()

      Text(Lingua.LiveStream.cameraMicPermissionsError)

      Button(Lingua.LiveStream.openSettingsButton) {
#if os(iOS)
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
          return
        }

        UIApplication.shared.open(settingsUrl)
#endif
      }

      Spacer()
    }
    .padding()
  }
}
