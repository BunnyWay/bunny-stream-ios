import XCTest
@testable import BunnyStreamPlayer

@MainActor
final class BunnyStreamLivePlayerControlsTests: XCTestCase {
  func testControlsAreEnabledByDefault() {
    let player = BunnyStreamLivePlayer(accessKey: "key", libraryId: 1, streamId: "stream")

    XCTAssertEqual(controlsEnabled(in: player), true)
  }

  func testControlsCanBeDisabled() {
    let player = BunnyStreamLivePlayer(
      accessKey: "key",
      libraryId: 1,
      streamId: "stream",
      controlsEnabled: false
    )

    XCTAssertEqual(controlsEnabled(in: player), false)
  }

  private func controlsEnabled(in player: BunnyStreamLivePlayer) -> Bool? {
    Mirror(reflecting: player).children.first { $0.label == "controlsEnabled" }?.value as? Bool
  }
}
