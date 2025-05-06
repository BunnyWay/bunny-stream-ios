import SwiftUI

struct SeekBarView: View {
  @Environment(\.videoPlayerTheme) var theme: VideoPlayerTheme
  @Environment(\.videoPlayerConfig) var videoPlayerConfig: VideoPlayerConfig
  @ObservedObject var viewModel: SeekBarViewModel
  @Binding var isDraggingOutside: Bool
  @State private var size: CGSize = .zero
  @State private var isDragging: Bool = false
  @State private var dragPosition: CGFloat = .zero
  @State private var activeLabelTextSize: CGSize = .zero
  
  enum UI {
    static let inactiveBarHeight: CGFloat = 3
    static let activeBarHeight: CGFloat = 6
    static let scrubberDiameter: CGFloat = 0
    static let activeScrubberDiameter: CGFloat = 14
    static let momentCircleDiameter: CGFloat = 10
    static let scrubberOffset: CGFloat = activeScrubberDiameter / 2
    static let seekBarFrameHeight: CGFloat = 40
    static let thumbnailSize: CGFloat = 100
    static let heatmapHeight: CGFloat = 31
  }
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        heatmapGraphView()
          .shouldAddView(videoPlayerConfig.showHeatmap)
        chapterMarksView()
        progressMarksView()
        momentsView()
        thumbnailPreviewView()
        activeLabelView()
        scrubberView()
      }
      .onAppear {
        updateSizeAndPosition(with: geometry.size)
      }
      .onChange(of: geometry.size) { newSize in
        updateSizeAndPosition(with: newSize)
      }
      .frame(height: UI.seekBarFrameHeight)
    }
    .frame(height: UI.seekBarFrameHeight)
    .background(.gray.opacity(0.001))
    .gesture(DragGesture(minimumDistance: .zero).onChanged { value in
      isDragging = true
      isDraggingOutside = true
      dragPosition = min(max(value.location.x, .zero), size.width)
    }
      .onEnded { _ in
        isDragging = false
        isDraggingOutside = false
        updatePlayerPosition(for: size)
      }
    )
    .onReceive(viewModel.$elapsedTime) { currentTime in
      guard !isDragging else { return }
      let duration = viewModel.duration
      guard duration != .zero else { return }
      let percentage = currentTime / duration
      dragPosition = min(max(size.width * CGFloat(percentage), -UI.scrubberOffset), size.width)
    }
  }
}

// MARK: - Views
private extension SeekBarView {
  @ViewBuilder
  func thumbnailPreviewView() -> some View {
    if isDragging {
      ThumbnailAsyncImageView(
        video: viewModel.video,
        second: draggingTime,
        thumbnailSize: $viewModel.thumbnailSize
      )
      .overlay {
        VStack {
          Spacer()
          Text(draggingTime.toFormattedTime())
            .foregroundColor(.white)
            .font(theme.font.size(11))
            .shadow(radius: 5)
            .padding(4)
        }
      }
      .frame(width: viewModel.scaledThumbnailSize.width, height: viewModel.scaledThumbnailSize.height)
      .shadow(radius: 5)
      .cornerRadius(5.0)
      .clipped()
      .offset(x: thumbnailOffsetX, y: viewModel.thumbnailYOffset)
    }
  }
  
  func scrubberView() -> some View {
    Circle()
      .foregroundColor(theme.tintColor)
      .frame(width: isDragging ? UI.activeScrubberDiameter : UI.scrubberDiameter,
             height: isDragging ? UI.activeScrubberDiameter : UI.scrubberDiameter)
      .offset(x: safeDragPosition - UI.scrubberOffset, y: .zero)
  }
  
  @ViewBuilder
  func chapterMarksView() -> some View {
    if let chapters = viewModel.video.chaptersList {
      HStack(spacing: 2) {
        ForEach(chapters, id: \.id) { chapter in
          let isActiveChapter = isDragging && chapter.contains(currentPosition)
          Rectangle()
            .fill(Color.white.opacity(0.7))
            .frame(width: chapterWidth(for: chapter), height: isActiveChapter ? UI.activeBarHeight : UI.inactiveBarHeight)
        }
      }
    }
  }
  
  @ViewBuilder
  func progressMarksView() -> some View {
    if let chapters = viewModel.video.chaptersList {
      HStack(spacing: 2) {
        ForEach(chapters, id: \.id) { chapter in
          let isActiveChapter = isDragging && chapter.contains(currentPosition)
          Rectangle()
            .fill(theme.tintColor)
            .frame(width: playedWidth(for: chapter), height: isActiveChapter ? UI.activeBarHeight : UI.inactiveBarHeight)
        }
      }
    }
  }

  func momentsView() -> some View {
    ZStack {
      ForEach(viewModel.video.moments, id: \.id) { moment in
        let xOffset = (CGFloat(moment.second) / CGFloat(viewModel.duration)) * size.width
        MomentView(diameter: UI.momentCircleDiameter)
          .offset(x: xOffset - UI.momentCircleDiameter / 2, y: .zero)
      }
    }
  }
  
  @ViewBuilder
  func activeLabelView() -> some View {
    if let label = activeLabel() {
      Text(label)
        .font(theme.font.size(12))
        .foregroundColor(.white)
        .shadow(radius: 10)
        .padding(10)
        .background(
          GeometryReader { proxy in
            Color.clear.preference(key: ViewSizeKey.self, value: proxy.size)
          }
        )
        .onPreferenceChange(ViewSizeKey.self) { size in
          self.activeLabelTextSize = size
        }
        .offset(x: safeActiveLabelXOffset(), y: -UI.heatmapHeight)
    }
  }
  
  func heatmapGraphView() -> some View {
    HeatmapGraphView(heatmap: viewModel.heatmap, playedPercentage: CGFloat(dragPosition / size.width))
      .frame(height: UI.heatmapHeight)
      .offset(x: .zero, y: -UI.seekBarFrameHeight / 2 + UI.inactiveBarHeight)
      .environment(\.videoPlayerTheme, theme)
  }
}

// MARK: - Private methods
private extension SeekBarView {
  var totalSpacing: CGFloat {
    guard let chapters = viewModel.video.chaptersList else { return .zero }
    return CGFloat(chapters.count - 1) * 2
  }
  
  var adjustedWidth: CGFloat {
    size.width - totalSpacing
  }
  
  func chapterWidth(for chapter: Chapter) -> CGFloat {
    guard !viewModel.duration.isZero else { return 0 }
    let chapterWidthPercentage = chapter.widthPercentage(duration: viewModel.duration)
    return max(chapterWidthPercentage * adjustedWidth, .zero)
  }
  
  var currentPosition: CGFloat {
    (dragPosition / size.width) * CGFloat(viewModel.duration)
  }
  
  func playedDuration(in chapter: Chapter) -> CGFloat {
    var played: CGFloat = 0
    if currentPosition >= CGFloat(chapter.start) {
      played = min(currentPosition - CGFloat(chapter.start), CGFloat(chapter.end - chapter.start))
    }
    return played
  }
  
  func playedWidth(for chapter: Chapter) -> CGFloat {
    guard !chapter.end.isZero else { return 0 }
    let playedChapterWidthPercentage = playedDuration(in: chapter) / CGFloat(chapter.end - chapter.start)
    return max(playedChapterWidthPercentage * chapterWidth(for: chapter), .zero)
  }
  
  func activeLabel() -> String? {
    if let moment = viewModel.video.moments.first(where: { isDragging && $0.contains(currentPosition, in: Int(viewModel.duration)) }) {
      return moment.label
    } else if let chapter = viewModel.video.chaptersList?.first(where: { isDragging && $0.contains(currentPosition) }),
              case .regular(let title) = chapter.type {
      return title
    }
    return nil
  }
  
  func updatePlayerPosition(for size: CGSize) {
    let duration = viewModel.duration
    guard duration != .zero else { return }
    let percentage = Double(dragPosition / size.width)
    let seekTimeSeconds = duration * percentage
    viewModel.elapsedTime = seekTimeSeconds
    viewModel.player.jump(to: seekTimeSeconds)
  }
  
  func updateSizeAndPosition(with newSize: CGSize) {
    size = newSize
    let duration = viewModel.duration
    guard duration != .zero else { return }
    let percentage = viewModel.elapsedTime / duration
    dragPosition = min(max(newSize.width * CGFloat(percentage), -UI.scrubberOffset), newSize.width)
  }
  
  var thumbnailOffsetX: CGFloat {
    let potentialOffset = dragPosition - viewModel.scaledThumbnailSize.width / 2
    let offsetFromLeft = max(potentialOffset, .zero)
    let offsetFromRight = min(offsetFromLeft, size.width - viewModel.scaledThumbnailSize.width)
    return offsetFromRight
  }
  
  func safeActiveLabelXOffset() -> CGFloat {
    let xOffset = dragPosition
    let potentialOffset = xOffset - activeLabelTextSize.width / 2
    let offsetFromLeft = max(potentialOffset, .zero)
    return min(offsetFromLeft, adjustedWidth - activeLabelTextSize.width)
  }
  
  var safeDragPosition: CGFloat {
    let buffer: CGFloat = 6.0
    return min(max(dragPosition, UI.scrubberOffset - buffer), size.width - buffer)
  }
  
  var draggingTime: Double {
    Double(dragPosition / size.width) * viewModel.duration
  }
}
