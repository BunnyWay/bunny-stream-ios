import SwiftUI

struct ConditionalModifier: ViewModifier {
  var shouldShow: Bool
  
  func body(content: Content) -> some View {
    if shouldShow {
      content
    }
  }
}

extension View {
  func shouldAddView(_ condition: Bool) -> some View {
    self.modifier(ConditionalModifier(shouldShow: condition))
  }
  
  func shouldAddView(controlsToCheck: VideoPlayerConfig.Control..., in controls: [VideoPlayerConfig.Control]) -> some View {
    self.modifier(ConditionalModifier(shouldShow: Set(controlsToCheck).isSubset(of: Set(controls))))
  }

  /// Gates on the whole config rather than the bare control list, so compact mode is applied
  /// alongside the dashboard's control selection.
  func shouldAddView(controlsToCheck: VideoPlayerConfig.Control..., in config: VideoPlayerConfig) -> some View {
    self.modifier(ConditionalModifier(shouldShow: controlsToCheck.allSatisfy(config.shows)))
  }
}
