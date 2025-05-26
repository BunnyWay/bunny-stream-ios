// swiftlint:disable all
// This file was generated with Lingua command line tool. Please do not change it!
// Source: https://github.com/poviolabs/Lingua

import Foundation

public enum Lingua {
	public enum Error {
		/// There was a problem setting up the audio. Please check your settings and try again.
		public static let audioError = tr("Error", "audio_error")
	}

	public enum LiveStream {
		/// Camera and Microphone access is required.
		public static let cameraMicPermissionsError = tr("LiveStream", "camera_mic_permissions_error")
		/// End Stream
		public static let endStreamAlertConfirmAction = tr("LiveStream", "end_stream_alert_confirm_action")
		/// Are you sure you want to end the stream?
		public static let endStreamAlertMessage = tr("LiveStream", "end_stream_alert_message")
		/// End Stream
		public static let endStreamAlertTitle = tr("LiveStream", "end_stream_alert_title")
		/// LIVE
		public static let indicatorLive = tr("LiveStream", "indicator_live")
		/// OFFLINE
		public static let indicatorOffline = tr("LiveStream", "indicator_offline")
		/// Open Settings
		public static let openSettingsButton = tr("LiveStream", "open_settings_button")
		/// Failed to stream!
		public static let streamFailedMessage = tr("LiveStream", "stream_failed_message")
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
