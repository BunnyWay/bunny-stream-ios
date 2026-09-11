import Combine
import Foundation

/// What the broadcaster is doing.
public enum BunnyBroadcastState: Equatable, Sendable {
  /// Not broadcasting. The camera preview may still be running.
  case idle
  /// Connecting to the ingest, or counting down before publishing starts.
  case preparing
  /// Publishing to Bunny.
  case live
}

/// Which camera the broadcast is using.
public enum BunnyCameraPosition: Equatable, Sendable {
  case front
  case back
}

/// A one-off thing that happened during a broadcast.
///
/// Use these for logging and analytics; for "what is true right now" read the controller's
/// published properties instead.
public enum BunnyBroadcastEvent: Equatable, Sendable {
  /// The countdown before publishing has started.
  case preparing
  /// Publishing has begun and Bunny accepted the connection.
  case started
  /// The broadcast was stopped, either by ``BunnyBroadcastController/stopBroadcast()`` or
  /// because reconnection gave up.
  case stopped
  /// The connection dropped and a retry is scheduled.
  /// - Parameters:
  ///   - attempt: 1-based attempt number.
  ///   - usingBackup: Whether this attempt targets the backup ingest.
  case reconnecting(attempt: Int, usingBackup: Bool)
  /// Reconnection exhausted its attempts; the broadcast has ended.
  case reconnectFailed
  /// The `/status` endpoint reported which ingests are receiving data.
  /// `nil` means the server didn't say — not that the ingest is down.
  case ingestStatusChanged(primaryLive: Bool?, backupLive: Bool?)
  /// The ingest being published to went silent, so the broadcaster switched to the other one.
  case failedOver(usingBackup: Bool)
  /// Something went wrong and was surfaced to the user.
  case failed(message: String)
}

/// Drives and observes ``BunnyStreamCameraUploadView`` from outside.
///
/// Create one, hand it to the view, and use it to start or stop the broadcast, flip the camera,
/// or mute — plus observe what's happening. Without one the view still works on its own using
/// its built-in controls.
///
/// ```swift
/// @StateObject private var broadcast = BunnyBroadcastController()
///
/// var body: some View {
///   VStack {
///     BunnyStreamCameraUploadView(
///       liveStream: stream, accessKey: key, libraryId: id, controller: broadcast
///     )
///     Text(broadcast.elapsedTime ?? "")
///     Button("Stop") { broadcast.stopBroadcast() }
///       .disabled(broadcast.state != .live)
///   }
/// }
/// ```
@MainActor
public final class BunnyBroadcastController: ObservableObject {
  /// What the broadcaster is doing right now.
  @Published public private(set) var state: BunnyBroadcastState = .idle
  /// Time since publishing began, formatted `HH:MM:SS`. `nil` when not broadcasting.
  @Published public private(set) var elapsedTime: String?
  /// Whether Bunny is receiving data on the primary ingest. `nil` until the first status
  /// answer arrives, or when the server doesn't report it.
  @Published public private(set) var primaryIngestLive: Bool?
  /// Whether Bunny is receiving data on the backup ingest.
  @Published public private(set) var backupIngestLive: Bool?
  /// Whether the microphone is muted.
  @Published public private(set) var isMuted = false
  /// Which camera is active.
  @Published public private(set) var cameraPosition: BunnyCameraPosition = .back

  /// Called for each ``BunnyBroadcastEvent``, on the main actor.
  public var onEvent: ((BunnyBroadcastEvent) -> Void)?

  public init() {}

  /// The view's internals. Set when the controller is handed to a view; the controller does
  /// nothing until then.
  weak var viewModel: BunnyStreamCameraUploadViewModel?

  /// Whether the controller is attached to a live view and its methods will do anything.
  public var isAttached: Bool { viewModel != nil }

  // MARK: - Controls

  /// Starts the countdown and then publishing. Does nothing if already broadcasting.
  ///
  /// The guard reads the view model rather than ``state``, which is updated asynchronously —
  /// otherwise a restart issued right after ``stopBroadcast()`` could be dropped.
  public func startBroadcast() {
    guard let viewModel, viewModel.state == .notStreaming else { return }
    viewModel.startStreamingCountdown()
  }

  /// Stops publishing and completes the stream on the Bunny backend.
  public func stopBroadcast() {
    guard let viewModel, viewModel.state != .notStreaming else { return }
    viewModel.stopPublish()
  }

  /// Switches between the front and back camera.
  public func rotateCamera() {
    viewModel?.rotateCamera()
  }

  /// Mutes or unmutes the microphone.
  public func toggleMute() {
    viewModel?.toggleMute()
  }

  // MARK: - Updates from the view model
  //
  // The view model isn't actor-isolated, so these are `nonisolated` and hop to the main actor.
  // Hops enqueued from the same thread run in order, which keeps event sequences such as
  // preparing → started → stopped intact.

  nonisolated func update(state: BunnyBroadcastState) {
    Task { @MainActor in
      guard self.state != state else { return }
      self.state = state
    }
  }

  nonisolated func update(elapsedTime: String?) {
    Task { @MainActor in
      guard self.elapsedTime != elapsedTime else { return }
      self.elapsedTime = elapsedTime
    }
  }

  nonisolated func update(isMuted: Bool) {
    Task { @MainActor in
      guard self.isMuted != isMuted else { return }
      self.isMuted = isMuted
    }
  }

  nonisolated func update(cameraPosition: BunnyCameraPosition) {
    Task { @MainActor in
      guard self.cameraPosition != cameraPosition else { return }
      self.cameraPosition = cameraPosition
    }
  }

  nonisolated func update(primaryLive: Bool?, backupLive: Bool?) {
    Task { @MainActor in
      guard self.primaryIngestLive != primaryLive || self.backupIngestLive != backupLive else {
        return
      }
      self.primaryIngestLive = primaryLive
      self.backupIngestLive = backupLive
      self.onEvent?(.ingestStatusChanged(primaryLive: primaryLive, backupLive: backupLive))
    }
  }

  nonisolated func emit(_ event: BunnyBroadcastEvent) {
    Task { @MainActor in self.onEvent?(event) }
  }
}
