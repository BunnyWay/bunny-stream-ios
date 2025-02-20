// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Bunny",
  defaultLocalization: "en",
  platforms: [.iOS(.v15), .macOS(.v13)],
  products: [
    .library(name: "BunnyStreamSDK", targets: ["BunnyStreamSDK"]),
    .library(name: "BunnyVideoUploader", targets: ["BunnyVideoUploader"]),
    .library(name: "BunnyVideoPlayer", targets: ["BunnyVideoPlayer"]),
    .library(name: "BunnyLiveStream", targets: ["BunnyLiveStream"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.7.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", exact: "1.8.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", exact: "1.0.2"),
    .package(url: "https://github.com/tus/TUSKit.git", branch: "main"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", branch: "master"),
    .package(url: "https://github.com/dagronf/SwiftSubtitles.git", branch: "main"),
    .package(url: "https://github.com/googleads/swift-package-manager-google-interactive-media-ads-ios.git", exact: "3.18.4"),
    .package(url: "https://github.com/shogo4405/HaishinKit.swift", exact: "1.7.3")
  ],
  targets: [
    .target(
      name: "BunnyStreamSDK",
      dependencies: [
        .product(
          name: "OpenAPIRuntime",
          package: "swift-openapi-runtime"
        ),
        .product(
          name: "OpenAPIURLSession",
          package: "swift-openapi-urlsession"
        ),
      ],
      path: "Sources/BunnyStreamSDK",
      plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
      ]
    ),
    .target(
      name: "BunnyVideoUploader",
      dependencies: [
        .byName(name: "BunnyStreamSDK"),
        .product(name: "TUSKit", package: "TUSKit")
      ],
      path: "Sources/BunnyVideoUploader"),
    .target(
      name: "BunnyVideoPlayer",
      dependencies: [
        .byName(name: "Kingfisher"),
        .byName(name: "SwiftSubtitles"),
        .byName(name: "BunnyStreamSDK"),
        .product(name: "GoogleInteractiveMediaAds", package: "swift-package-manager-google-interactive-media-ads-ios")
      ],
      path: "Sources/BunnyVideoPlayer",
      resources: [.process("Resources")]
    ),
    .target(
      name: "BunnyLiveStream",
      dependencies: [
        .byName(name: "BunnyStreamSDK"),
        .product(name: "HaishinKit", package: "HaishinKit.swift")
      ],
      path: "Sources/BunnyLiveStream",
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "BunnyStreamSDKTests",
      dependencies: ["BunnyStreamSDK"],
      path: "Tests/BunnyStreamSDKTests"
    ),
    .testTarget(
      name: "BunnyVideoUploaderTests",
      dependencies: ["BunnyVideoUploader"],
      path: "Tests/BunnyVideoUploaderTests"
    ),
  ]
)
