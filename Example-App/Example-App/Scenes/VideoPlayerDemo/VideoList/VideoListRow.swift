//
//  StreamAPIDemoVideoRow.swift
//  Example-App
//
//  Created by Egzon Arifi on 17/10/2023.
//
//

import SwiftUI
import UIKit

/// Drop-in replacement for SwiftUI's `AsyncImage(url:content:)` that attaches the Bunny CDN
/// `Referer` header to the image request.
///
/// When a library enables **"Block direct url file access"** (referer hotlink protection), the CDN
/// returns HTTP 403 for image requests that arrive without an allowed `Referer`. Plain `AsyncImage`
/// can't set request headers, so thumbnails/posters come back blank. This mirrors what the
/// BunnyStream player already does for its own images (via Kingfisher) and what the Android demo
/// app does with a Coil interceptor.
struct RefererAsyncImage<Content: View>: View {
  /// Embed-player Referer used by Bunny's own web player — mirrors `BunnyCDN.referer` in the SDK.
  private static var referer: String { "https://iframe.mediadelivery.net/" }

  private let url: URL?
  private let transaction: Transaction
  @ViewBuilder private let content: (AsyncImagePhase) -> Content

  @State private var phase: AsyncImagePhase = .empty

  init(
    url: URL?,
    transaction: Transaction = Transaction(),
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    self.url = url
    self.transaction = transaction
    self.content = content
  }

  var body: some View {
    content(phase)
      .task(id: url) { await load() }
  }

  private func load() async {
    withTransaction(transaction) { phase = .empty }
    guard let url else { return }

    var request = URLRequest(url: url)
    request.setValue(Self.referer, forHTTPHeaderField: "Referer")

    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
        withTransaction(transaction) { phase = .failure(URLError(.badServerResponse)) }
        return
      }
      guard let image = UIImage(data: data) else {
        withTransaction(transaction) { phase = .failure(URLError(.cannotDecodeContentData)) }
        return
      }
      withTransaction(transaction) { phase = .success(Image(uiImage: image)) }
    } catch {
      // Ignore cancellations (view disappeared or url changed); surface real failures.
      if Task.isCancelled { return }
      withTransaction(transaction) { phase = .failure(error) }
    }
  }
}

struct VideoListRow: View {
  var video: VideoResponseInfo
  var thumbnailURL: URL?

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .foregroundStyle(Color.gray)
        .overlay {
          imageView
            .transition(.opacity)
            .cornerRadius(16)
        }
        .clipped()
        .shadow(radius: 10)
      VStack {
        topView()
        Spacer()
        videoInfoView()
      }
    }
    .frame(height: 230)
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .contextMenu {
      // Long-press to copy the exact video GUID — paste it into "Direct Video Play" to test that
      // flow with a known-good ID (a plain tap can't be used here: the whole row is the play button).
      Button {
        UIPasteboard.general.string = video.id
      } label: {
        Label("Copy Video ID", systemImage: "doc.on.doc")
      }
    }
  }
}

extension VideoListRow {
  var imageView: some View {
    GeometryReader { geometry in
      VStack {
        RefererAsyncImage(url: thumbnailURL) { phase in
          switch phase {
          case .empty:
            ProgressView()
              .transition(.opacity)
          case .success(let image):
            image
              .resizable()
              .transition(.opacity)
              .aspectRatio(contentMode: .fill)
              .overlay {
                LinearGradient(
                  gradient: Gradient(
                    colors: [
                      .clear,
                      .black.opacity(
                        0.7
                      )]
                  ),
                  startPoint: .center,
                  endPoint: .bottom
                )
              }
          case .failure:
            Image(systemName: "photo")
              .resizable()
              .foregroundColor(.black.opacity(0.2))
              .scaledToFit()
              .frame(width: 50)
              .transition(.opacity)
          @unknown default:
            EmptyView()
          }
        }
        .clipped()
      }
      .frame(width: geometry.size.width, height: 230)
    }
  }
  
  func topView() -> some View {
    HStack {
      Spacer()
      if video.encodeProgress != 100 {
        capsuleText(string: "Processing", foregroundColor: .purple)
      } else {
        capsuleText(string: "\(video.views) views")
      }
    }
    .padding()
  }
  
  func capsuleText(string: String, foregroundColor: Color = .black.opacity(0.6)) -> some View {
    Text(string)
      .foregroundColor(foregroundColor)
      .font(.caption)
      .padding()
      .frame(height: 24)
      .background(Capsule().fill(Color.white))
      .overlay(
        Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 0.3)
          .shadow(color: .black.opacity(0.2), radius: 5)
      )
  }
  
  func videoInfoView() -> some View {
    VStack {
      VStack(alignment: .leading, spacing: 12) {
        Text(video.title ?? "")
          .font(.headline)
          .foregroundColor(.white)
          .padding(.horizontal)
          .multilineTextAlignment(.leading)
        HStack(spacing: 6) {
          Image(systemName: "number")
            .foregroundColor(.white.opacity(0.85))
          Text(video.id)
            .font(.system(.caption2, design: .monospaced))
            .foregroundColor(.white.opacity(0.85))
            .lineLimit(1)
            .truncationMode(.middle)
        }
        .padding(.horizontal)
        HStack {
          Image(systemName: "stopwatch")
            .foregroundColor(.white)
          Text(Double(video.length).toFormattedTime())
            .foregroundColor(.white)
          Spacer()
          Text(video.formattedFileSize)
            .foregroundColor(.white)
        }
        .padding([.horizontal, .bottom])
      }
    }
  }
}
