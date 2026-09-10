import XCTest
@testable import BunnyStreamPlayer

/// Covers the two dashboard settings that used to arrive from `/play` and get dropped on the
/// floor: `uiLanguage` and `enableCompactControls`.
final class LiveStreamMessageLocalizationTests: XCTestCase {

  func test_usesDeviceLanguageWhenNoCodeGiven() {
    let message = LiveStreamMessage.notActive.localized()

    XCTAssertFalse(message.isEmpty)
    XCTAssertNotEqual(message, "stream_not_active", "the key must not leak through untranslated")
  }

  /// NOTE: the assertions below check bundle *resolution*, not wording, because
  /// `LiveStream.strings` currently ships the English text in every locale. The moment those
  /// files are actually translated, a pinned language starts changing what viewers read with no
  /// further code change. `Settings.strings` in the same bundles *are* translated, which is what
  /// makes this a content gap rather than a wiring bug.
  func test_knownLanguageResolvesToThatLanguagesBundle() throws {
    let bundle = LiveStreamLocalization.bundle(for: "de")

    XCTAssertTrue(bundle.bundlePath.hasSuffix("de.lproj"), "expected the de bundle, got \(bundle.bundlePath)")
    // Proves the resolved bundle really is German, using a table that is translated.
    XCTAssertEqual(bundle.localizedString(forKey: "caption_menu_title", value: nil, table: "Settings"), "Untertitel")
  }

  func test_regionQualifiedCodeFallsBackToBareLanguage() {
    let qualified = LiveStreamLocalization.bundle(for: "de-AT")
    let bare = LiveStreamLocalization.bundle(for: "de")

    XCTAssertEqual(qualified.bundlePath, bare.bundlePath, "de-AT has no bundle, so it resolves as de")
  }

  func test_unknownLanguageFallsBackInsteadOfFailing() {
    let unknown = LiveStreamMessage.error.localized(languageCode: "zz")
    let fallback = LiveStreamMessage.error.localized()

    XCTAssertEqual(unknown, fallback)
    XCTAssertFalse(unknown.isEmpty)
  }

  func test_emptyCodeIsTreatedAsUnset() {
    XCTAssertEqual(
      LiveStreamMessage.ended.localized(languageCode: ""),
      LiveStreamMessage.ended.localized()
    )
  }

  func test_distinctMessagesHaveDistinctWording() {
    let messages: [LiveStreamMessage] = [.notActive, .ended, .error, .startingSoon, .notAvailable]
    let wordings = Set(messages.map { $0.localized(languageCode: "en") })

    XCTAssertEqual(wordings.count, messages.count, "each state needs its own wording")
  }

  /// A 403 must read exactly like VOD's, and — unlike the rest of `LiveStream.strings` — it is
  /// translated, because it borrows VOD's `Player.strings` entry.
  func test_notAvailableSharesVodWordingAndTranslations() {
    XCTAssertEqual(LiveStreamMessage.notAvailable.localized(languageCode: "en"), "Video is not available")
    XCTAssertEqual(LiveStreamMessage.notAvailable.localized(languageCode: "de"), "Video ist nicht verfügbar")
    XCTAssertEqual(LiveStreamMessage.notAvailable.localized(), Lingua.Player.videoNotAvailable)
  }
}

final class CompactControlsTests: XCTestCase {

  func test_compactHidesSecondaryControls() {
    var config = VideoPlayerConfig()
    config.compactControls = true

    XCTAssertFalse(config.shows(.settings))
    XCTAssertFalse(config.shows(.captions))
    XCTAssertFalse(config.shows(.currentTime))
    XCTAssertFalse(config.shows(.duration))
  }

  func test_compactKeepsTransportControls() {
    var config = VideoPlayerConfig()
    config.compactControls = true

    XCTAssertTrue(config.shows(.play))
    XCTAssertTrue(config.shows(.progress))
    XCTAssertTrue(config.shows(.fullScreen))
  }

  func test_nonCompactShowsEverythingAllowed() {
    let config = VideoPlayerConfig()

    XCTAssertTrue(config.shows(.settings))
    XCTAssertTrue(config.shows(.captions))
    XCTAssertTrue(config.shows(.play))
  }

  /// Compact mode narrows the dashboard's control list; it never widens it.
  func test_compactCannotReviveAControlTheDashboardDisabled() {
    var config = VideoPlayerConfig()
    config.controls = [.play]
    config.compactControls = true

    XCTAssertTrue(config.shows(.play))
    XCTAssertFalse(config.shows(.progress), "not in the dashboard's list, so still hidden")
  }

  func test_dashboardListStillAppliesWithoutCompact() {
    var config = VideoPlayerConfig()
    config.controls = [.play, .settings]

    XCTAssertTrue(config.shows(.settings))
    XCTAssertFalse(config.shows(.captions))
  }
}
