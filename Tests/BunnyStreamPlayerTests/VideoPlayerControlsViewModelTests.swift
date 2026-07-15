import XCTest
import AVFoundation
@testable import BunnyStreamPlayer

/// Verifies the DVR-aware gating flag that hides the VOD-style scrubber and skip buttons for a
/// live stream without a seekable (DVR) window — parity with Android's `liveControlsFor(dvrEnabled:)`.
final class VideoPlayerControlsViewModelTests: XCTestCase {

    private let liveURL = URL(string: "https://example.com/live.m3u8")!

    // Non-DVR live edge (`.live`): the timeline slides, so scrubber + rewind/fast-forward must hide.
    func test_isLiveWithoutDVR_trueForNonDvrLive() {
        let player = MediaPlayer.makeLive(url: liveURL, seekableWindowSeconds: 0, contentId: "stream")
        XCTAssertTrue(player.kind == .live)
        XCTAssertTrue(makeViewModel(player).isLiveWithoutDVR)
    }

    // DVR live (`.event`): the seekable window is real, so those controls stay.
    func test_isLiveWithoutDVR_falseForDvrLive() {
        let player = MediaPlayer.makeLive(url: liveURL, seekableWindowSeconds: 30, contentId: "stream")
        XCTAssertTrue(player.kind == .event)
        XCTAssertFalse(makeViewModel(player).isLiveWithoutDVR)
    }

    // Ended-stream recording (`.vod`): a fully seekable VOD keeps every control.
    func test_isLiveWithoutDVR_falseForVodRecording() {
        let player = MediaPlayer(url: liveURL)
        XCTAssertTrue(player.kind == .vod)
        XCTAssertFalse(makeViewModel(player).isLiveWithoutDVR)
    }

    // MARK: - Helpers

    private func makeViewModel(_ player: MediaPlayer) -> VideoPlayerControlsViewModel {
        VideoPlayerControlsViewModel(player: player, video: Self.stubVideo, heatmap: Heatmap(data: [:]))
    }

    private static let stubVideo = Video(
        guid: "stream",
        chaptersList: nil,
        moments: [],
        thumbnailCount: 0,
        width: 0,
        height: 0,
        length: 0,
        captions: [],
        libraryId: 1,
        resolutions: [.auto],
        seekPath: nil,
        playlistUrl: nil
    )
}
