# Contributing to Bunny Stream iOS

Thanks for helping improve Bunny Stream iOS. This Swift Package Manager SDK is used by developers who need reliable Bunny Stream API access, video playback, resumable uploads, background uploads, and camera recording in iOS apps.

## Good First Contributions

Good places to start:

- README, DocC, and example app improvements
- Small bug fixes with clear reproduction steps
- Test coverage for API, uploader, player, or camera upload behavior
- Better error messages and edge-case handling
- Improvements to CI reliability or package documentation
- Examples that make integration easier for SwiftUI developers

If you are unsure whether a change fits, open an issue first and describe the problem you want to solve.

## Development Setup

Requirements:

- macOS
- Xcode 15 or newer
- Swift Package Manager
- iOS 15+ simulator or device for integration testing

Useful commands:

```bash
swift package clean
swift build
swift test
xcodebuild build-for-testing -destination 'name=iPhone 16 Pro' -scheme 'Bunny-Package' -skipPackagePluginValidation
xcodebuild test-without-building -destination 'name=iPhone 16 Pro' -scheme 'Bunny-Package' -skipPackagePluginValidation
```

If Xcode asks you to trust the OpenAPI Generator plugin, approve it before building. In CI, use `-skipPackagePluginValidation` as the existing workflows do.

## Package Areas

- `BunnyStreamAPI`: Swift OpenAPI client and authentication
- `BunnyStreamUploader`: TUS and URLSession upload flows, progress tracking, pause/resume, background handling
- `BunnyStreamPlayer`: SwiftUI video player, AVKit/AVFoundation integration, captions, audio tracks, AirPlay, FairPlay-related playback utilities
- `BunnyStreamCameraUpload`: camera recording and direct upload UI/components
- `Example-App`: integration examples

Try to keep changes scoped to the package they affect.

## Pull Request Guidelines

Before opening a pull request:

- Make sure the change solves one clear problem.
- Add or update tests when behavior changes.
- Update README or DocC when public APIs or setup steps change.
- Keep generated OpenAPI output separate from handwritten logic when practical.
- Avoid unrelated formatting-only changes in large files.
- Verify the package builds in Xcode if your change touches SwiftUI, AVKit, camera upload, or package configuration.

Pull requests should include:

- What changed
- Why the change is needed
- How it was tested
- Any migration notes for SDK users

## API and Compatibility

This repository publishes Swift packages used by external applications. Please be careful with:

- Public API renames or removals
- Behavior changes in upload, playback, authentication, or camera flows
- Minimum platform changes
- Package dependency upgrades
- Changes to generated OpenAPI client behavior
- Changes that affect background uploads, AirPlay, FairPlay, or media permissions

If a change may be breaking, call it out clearly in the PR description.

## Using AI Tools

AI tools are welcome when they help you work faster or improve quality, but contributors remain responsible for the final contribution.

When using AI:

- Review and understand all generated code before submitting it.
- Do not paste access keys, customer data, private logs, certificates, provisioning profiles, or other secrets into AI tools.
- Prefer small, reviewable changes over large generated rewrites.
- Mention substantial AI assistance in the PR description when it materially shaped the implementation.
- Make sure generated code follows the existing Swift style and package architecture.

## Reporting Bugs

Please use the bug report template and include:

- SDK version or commit
- iOS/macOS version
- Xcode version
- Device or simulator
- Package affected (`BunnyStreamAPI`, `BunnyStreamUploader`, `BunnyStreamPlayer`, `BunnyStreamCameraUpload`, or example app)
- Minimal reproduction steps
- Expected and actual behavior
- Logs, screenshots, or sample code when useful

Never include Bunny access keys, signing certificates, provisioning profiles, private URLs, or other secrets in issues.

## Security Issues

Please do not report security vulnerabilities in public issues. See `SECURITY.md` for the private reporting process.

## License

By contributing, you agree that your contribution will be licensed under the MIT License used by this repository.
