# BunnyStreamAPI

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://www.swift.org)
[![License](https://img.shields.io/badge/Licence-MIT-green.svg)](LICENSE)

## Overview

BunnyStreamAPI is the core package of the Bunny Stream iOS SDK, providing a comprehensive Swift interface to Bunny's REST Stream API. This package handles all API communication, request authentication, and response parsing, enabling seamless video content management.

### Features

- Complete Bunny REST Stream API integration
- Comprehensive video management capabilities
- Collection organization and management
- Thumbnail generation and management
- Analytics and CDN settings control
- Type-safe Swift API interface
- Detailed error handling and recovery options

### Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 13.0+

### Installation

```swift
dependencies: [
    .package(url: "https://github.com/BunnyWay/bunny-stream-ios.git", .upToNextMajor(from: "1.0.0"))
]
```

### Usage example

The example below demonstrates how to initialize the API client and retrieve video details:

```swift
import BunnyStreamAPI

// Initialize the BunnyStreamAPI client with your access key
let bunnyStreamAPI = BunnyStreamAPI(accessKey: "your_access_key")

// Fetch video details using the client
let videoInfo = try await bunnyStreamAPI.client.getVideo(
    path: .init(
        libraryId: 12345,
        videoId: "abcd-e9bb-4b96-wxyz-c17bc6a5292b"
    )
)
```

### Error Handling

BunnyStreamAPI provides detailed error information via custom error types. The example below shows how to handle errors gracefully:

```swift
do {
    let output = try await bunnyStreamAPI.client.deleteVideo(
        path: .init(
          libraryId: 123,
          videoId: "videoId"
        )
    )
} catch let error as BunnyStreamError {
    switch error {
    case .unauthorized:
        print("Invalid access key")
    case .notFound:
        print("Video not found")
    case .networkError(let underlying):
        print("Network error: \(underlying)")
    case .apiError(let status, let message):
        print("API error (\(status)): \(message)")
    }
}
```
