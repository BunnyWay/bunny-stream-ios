//
//  StreamAPIDemoVideoRow.swift
//  Example-App
//
//  Created by Egzon Arifi on 17/10/2023.
//
//

import SwiftUI

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
  }
}

extension VideoListRow {
  var imageView: some View {
    GeometryReader { geometry in
      VStack {
        AsyncImage(url: thumbnailURL) { phase in
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
