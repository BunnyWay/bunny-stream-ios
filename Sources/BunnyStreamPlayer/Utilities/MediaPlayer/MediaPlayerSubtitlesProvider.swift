import Foundation
import SwiftSubtitles
import AVFoundation

class MediaPlayerSubtitlesProvider {
  let video: Video
  private let subtitlesActor = SubtitlesActor()
  
  init(video: Video) {
    self.video = video
  }
  
  func loadSubtitles() async throws {
    for caption in video.captions {
      guard let fullUrl = caption.captionsURL else {
        print("[MediaPlayerSubtitlesProvider] Invalid or missing URL for caption lang=\(caption.languageCode) using path=\(caption.captionsPath ?? "nil")")
        continue 
      }
      do {
        let (data, _) = try await URLSession.shared.data(from: fullUrl)
        let subtitles = try Subtitles(data: data, expectedExtension: "vtt", encoding: .utf8)
        await subtitlesActor.updateSubtitles(key: caption.languageCode, subtitles: subtitles)
      } catch {
        print("[MediaPlayerSubtitlesProvider] Failed to load/parse caption for lang=\(caption.languageCode) from \(fullUrl): \(error)")
      }
    }
  }
  
  func subtitle(for time: CMTime, currentLanguage language: String) async -> Subtitles.Cue? {
    await subtitlesActor.getSubtitle(for: language, time: time)
  }
  
  func loadSubtitlesIfNeeded() async {
    let shouldLoadSubtitles = await subtitlesActor.shouldLoadSubtitles(video: video)
    if shouldLoadSubtitles {
      try? await loadSubtitles()
    }
  }
}

private extension MediaPlayerSubtitlesProvider {
  actor SubtitlesActor {
    var subtitles: [String: Subtitles] = [:]
    
    func updateSubtitles(key: String, subtitles: Subtitles) {
      self.subtitles[key] = subtitles
    }
    
    func getSubtitle(for language: String, time: CMTime) -> Subtitles.Cue? {
      subtitles[language]?.firstCue(containing: Subtitles.Time(time: time))
    }
    
    func shouldLoadSubtitles(video: Video) -> Bool {
      !video.captions.isEmpty && subtitles.isEmpty
    }
  }
}
