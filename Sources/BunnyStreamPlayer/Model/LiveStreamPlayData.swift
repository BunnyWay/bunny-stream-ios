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

  public init(playbackURL: URL, seekableWindow: Double, isLive: Bool) {
    self.playbackURL = playbackURL
    self.seekableWindow = seekableWindow
    self.isLive = isLive
  }
}
