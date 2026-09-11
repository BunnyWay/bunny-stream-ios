//
//  LiveStreamPlayData.swift
//  Bunny
//
//  Created by Damian Kieltyka on 17/05/2026.
//

import Foundation

public struct LiveStreamPlayData: Identifiable {
  public let id = UUID()
  public let playbackURL: URL
  public let seekableWindow: Double
  public let isLive: Bool
  /// Player UI customization returned by the /play endpoint (font, primary color, controls, …).
  public let customization: PlayerCustomization

  public init(
    playbackURL: URL,
    seekableWindow: Double,
    isLive: Bool,
    customization: PlayerCustomization = .init()
  ) {
    self.playbackURL = playbackURL
    self.seekableWindow = seekableWindow
    self.isLive = isLive
    self.customization = customization
  }

  /// Player UI settings configured in the Bunny dashboard for the library/stream, so the live
  /// player reflects them (matching how the VOD player honors its play-data config).
  public struct PlayerCustomization: Equatable {
    public let fontFamily: String?
    public let playerKeyColor: String?
    public let uiLanguage: String?
    public let showHeatmap: Bool
    public let enableCompactControls: Bool
    /// Raw control tokens (e.g. "airplay", "fullscreen", "play-large"). Empty means "unspecified".
    public let controlTokens: [String]

    public init(
      fontFamily: String? = nil,
      playerKeyColor: String? = nil,
      uiLanguage: String? = nil,
      showHeatmap: Bool = false,
      enableCompactControls: Bool = false,
      controlTokens: [String] = []
    ) {
      self.fontFamily = fontFamily
      self.playerKeyColor = playerKeyColor
      self.uiLanguage = uiLanguage
      self.showHeatmap = showHeatmap
      self.enableCompactControls = enableCompactControls
      self.controlTokens = controlTokens
    }
  }
}
