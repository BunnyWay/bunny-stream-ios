// swiftlint:disable all
// This file was generated with Lingua command line tool. Please do not change it!
// Source: https://github.com/poviolabs/Lingua

import Foundation

public enum Lingua {
	public enum Error {
		/// There was a problem setting up the audio. Please check your settings and try again.
		public static let audioError = tr("Error", "audio_error")
	}

	public enum Player {
		/// Video not found!
		public static let videoNotFound = tr("Player", "video_not_found")
	}

	public enum Settings {
		/// Settings
		public static let actionsTitle = tr("Settings", "actions_title")
		/// Audio Track
		public static let audioTrackMenuTitle = tr("Settings", "audio_track_menu_title")
		/// Cancel
		public static let cancelAction = tr("Settings", "cancel_action")
		/// Disabled
		public static let captionDisabled = tr("Settings", "caption_disabled")
		/// Captions
		public static let captionMenuTitle = tr("Settings", "caption_menu_title")
		/// Speed
		public static let playbackSpeedMenuTitle = tr("Settings", "playback_speed_menu_title")
		/// Normal
		public static let playbackSpeedNormal = tr("Settings", "playback_speed_normal")
		/// Auto
		public static let qualityAuto = tr("Settings", "quality_auto")
		/// Quality
		public static let qualityMenuTitle = tr("Settings", "quality_menu_title")
	}
    
	private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
		let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
		return String(format: format, locale: Locale.current, arguments: args)
	}
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}

// swiftlint:enable all
