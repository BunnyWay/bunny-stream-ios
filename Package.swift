// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Bunny",
  defaultLocalization: "en",
  platforms: [.iOS(.v15), .macOS(.v13)],
  products: [
    .library(name: "BunnyStreamAPI", targets: ["BunnyStreamAPI"]),
    .library(name: "BunnyStreamUploader", targets: ["BunnyStreamUploader"]),
    .library(name: "BunnyStreamPlayer", targets: ["BunnyStreamPlayer"]),
    .library(name: "BunnyStreamCameraUpload", targets: ["BunnyStreamCameraUpload"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.7.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", exact: "1.8.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", exact: "1.0.2"),
    .package(url: "https://github.com/tus/TUSKit.git", branch: "main"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", branch: "master"),
    .package(url: "https://github.com/dagronf/SwiftSubtitles.git", branch: "main"),
    .package(url: "https://github.com/googleads/swift-package-manager-google-interactive-media-ads-ios.git", exact: "3.32.0"),
    .package(url: "https://github.com/shogo4405/HaishinKit.swift", exact: "1.7.3"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
  ],
  targets: [
    .target(
      name: "BunnyStreamAPI",
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
      path: "Sources/BunnyStreamAPI",
      plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
      ]
    ),
    .target(
      name: "BunnyStreamUploader",
      dependencies: [
        .byName(name: "BunnyStreamAPI"),
        .product(name: "TUSKit", package: "TUSKit")
      ],
      path: "Sources/BunnyStreamUploader"),
    .target(
      name: "BunnyStreamPlayer",
      dependencies: [
        .byName(name: "Kingfisher"),
        .byName(name: "SwiftSubtitles"),
        .byName(name: "BunnyStreamAPI"),
        .product(name: "GoogleInteractiveMediaAds", package: "swift-package-manager-google-interactive-media-ads-ios")
      ],
      path: "Sources/BunnyStreamPlayer",
      resources: [.process("Resources")]
    ),
    .target(
      name: "BunnyStreamCameraUpload",
      dependencies: [
        .byName(name: "BunnyStreamAPI"),
        .product(name: "HaishinKit", package: "HaishinKit.swift")
      ],
      path: "Sources/BunnyStreamCameraUpload",
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "BunnyStreamAPITests",
      dependencies: ["BunnyStreamAPI"],
      path: "Tests/BunnyStreamAPITests"
    ),
    .testTarget(
      name: "BunnyStreamUploaderTests",
      dependencies: ["BunnyStreamUploader"],
      path: "Tests/BunnyStreamUploaderTests"
    ),
  ]
)
