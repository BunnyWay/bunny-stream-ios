#if os(iOS)
import AVKit
import SwiftUI

struct AVPlayerViewControllerRepresentable: UIViewControllerRepresentable {
  var player: AVPlayer
  var setupAds: ((ViewController) -> Void)?
  
  func makeUIViewController(context: Context) -> PlayerViewController {
    let controller = PlayerViewController(playerLayer: .init(player: player))
    controller.view.backgroundColor = .black
    context.coordinator.avPlayerViewController = controller
    return controller
  }
  
  func updateUIViewController(_ viewController: PlayerViewController, context: Context) {
    viewController.playerLayer.player = player
    setupAds?(viewController)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject {
    var avPlayerViewController: PlayerViewController?
    var parent: AVPlayerViewControllerRepresentable
    
    init(_ parent: AVPlayerViewControllerRepresentable) {
      self.parent = parent
    }
  }
}

class PlayerViewController: UIViewController {
  let playerLayer: AVPlayerLayer
  
  init(playerLayer: AVPlayerLayer) {
    self.playerLayer = playerLayer
    super.init(nibName: nil, bundle: nil)
    view.layer.addSublayer(playerLayer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerLayer.frame = view.frame
  }
}

#endif

#if os(macOS)
import AVKit
import SwiftUI

struct AVPlayerViewControllerRepresentable: NSViewRepresentable {
  var player: AVPlayer
  var setupAds: ((ViewController) -> Void)?
  
  func makeNSView(context: Context) -> AVPlayerView {
    let playerView = AVPlayerView()
    playerView.player = player
    playerView.controlsStyle = .none
    return playerView
  }
  
  func updateNSView(_ nsView: AVPlayerView, context: Context) {
    nsView.player = player
  }
}
#endif
