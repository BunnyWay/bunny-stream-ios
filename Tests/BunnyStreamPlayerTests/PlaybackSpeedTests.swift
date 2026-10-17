import XCTest
@testable import BunnyStreamPlayer

/// Verifies the speed menu follows the library's Player > Playback speed setting returned by
/// `/play`, as the web embed does, instead of a hardcoded 0.5x–2x list.
final class PlaybackSpeedTests: XCTestCase {

    // The exact format `/play` returns for a library with 4x enabled.
    func test_librarySetting_parsesPlayResponseValue() {
        let speeds = [PlaybackSpeed](librarySetting: "0.5,0.75,1,1.25,1.5,1.75,2,4")
        XCTAssertEqual(speeds.map(\.speed), [0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 4])
    }

    func test_librarySetting_sortsDeduplicatesAndSkipsInvalidEntries() {
        let speeds = [PlaybackSpeed](librarySetting: " 2, 1 ,abc,0.5,,1,-1,0")
        XCTAssertEqual(speeds.map(\.speed), [0.5, 1, 2])
    }

    func test_librarySetting_fallsBackToDefaultsWhenMissingOrUnusable() {
        let defaults = [PlaybackSpeed].playbackSpeeds
        XCTAssertEqual([PlaybackSpeed](librarySetting: nil), defaults)
        XCTAssertEqual([PlaybackSpeed](librarySetting: ""), defaults)
        XCTAssertEqual([PlaybackSpeed](librarySetting: "abc,0"), defaults)
    }

    func test_video_usesPlaybackSpeedsFromPlayResponse() throws {
        let response = try decodeResponse(playbackSpeeds: "\"1,1.5,4\"")
        XCTAssertEqual(Video(response: response).playbackSpeeds.map(\.speed), [1, 1.5, 4])
    }

    func test_video_fallsBackToDefaultsWhenPlayResponseOmitsSpeeds() throws {
        let response = try decodeResponse(playbackSpeeds: nil)
        XCTAssertEqual(Video(response: response).playbackSpeeds, .playbackSpeeds)
    }

    func test_controlsMenu_offersVideoPlaybackSpeeds() throws {
        let response = try decodeResponse(playbackSpeeds: "\"0.5,1,4\"")
        let player = MediaPlayer(url: URL(string: "https://example.com/video.m3u8")!)
        let viewModel = VideoPlayerControlsViewModel(player: player, video: Video(response: response), heatmap: Heatmap(data: [:]))
        XCTAssertEqual(viewModel.playbackSpeedViewModel.playbackSpeeds.map(\.speed), [0.5, 1, 4])
    }

    // MARK: - Helpers

    /// Minimal `/play` body; `playbackSpeeds` is a raw JSON value, or `nil` to omit the key.
    private func decodeResponse(playbackSpeeds: String?) throws -> VideoConfigResponse {
        let speedsField = playbackSpeeds.map { "\"playbackSpeeds\": \($0)," } ?? ""
        let json = """
        {
          \(speedsField)
          "video": {
            "guid": "guid", "videoLibraryId": 1, "chapters": [], "moments": [],
            "thumbnailCount": 0, "width": 1920, "height": 1080, "length": 10,
            "captions": [], "availableResolutions": "720p,1080p"
          },
          "captionsFontSize": 20, "captionsFontColor": "#fff", "captionsBackground": "#000",
          "playerKeyColor": "#ff7755", "fontFamily": "rubik", "showHeatmap": false,
          "controls": "play,settings", "enableDRM": false,
          "thumbnailUrl": "https://example.com/thumb.jpg",
          "videoPlaylistUrl": "https://example.com/playlist.m3u8"
        }
        """
        return try JSONDecoder().decode(VideoConfigResponse.self, from: Data(json.utf8))
    }
}
