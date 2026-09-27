import AVFoundation
import XCTest
@testable import BunnyStreamPlayer

@MainActor
final class BunnyStreamPlayerControllerTests: XCTestCase {
  func testCommandsBeforeAttachAreAppliedInOrder() {
    let controller = BunnyStreamPlayerController()
    controller.setVolume(0.35)
    controller.mute()
    controller.unmute()

    let player = MediaPlayer()
    controller.attach(to: player)

    XCTAssertEqual(player.volume, 0.35, accuracy: 0.001)
    XCTAssertFalse(player.isMuted)
  }

  func testSeekPreservesPausedState() {
    let controller = BunnyStreamPlayerController()
    let player = MediaPlayer()
    controller.attach(to: player)
    player.pause()

    controller.seek(to: 10)

    XCTAssertFalse(player.isPlaying)
  }

  func testDisposeIsIdempotentAndIgnoresCommands() {
    let controller = BunnyStreamPlayerController()
    let player = MediaPlayer()
    controller.attach(to: player)

    controller.dispose()
    controller.dispose()
    controller.setVolume(0.2)

    XCTAssertEqual(player.volume, 1, accuracy: 0.001)
    XCTAssertEqual(controller.snapshot.state, .idle)
  }
}
