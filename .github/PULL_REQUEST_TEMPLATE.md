## Summary

<!-- What changed and why? -->

## Type of Change

- [ ] Bug fix
- [ ] Feature
- [ ] Documentation
- [ ] Refactor or cleanup
- [ ] CI/build/release
- [ ] Breaking change

## Affected Areas

- [ ] BunnyStreamAPI
- [ ] BunnyStreamUploader
- [ ] BunnyStreamPlayer
- [ ] BunnyStreamCameraUpload
- [ ] Example app
- [ ] Documentation / DocC
- [ ] Build or package configuration

## Testing

<!-- Describe what you ran. Include device/simulator details for UI, playback, upload, or camera changes. -->
<!-- Build and test against an iOS destination: plain `swift build` / `swift test` target macOS and
     fail on the iOS-only Google IMA dependency. -->

- [ ] `xcodebuild build-for-testing -destination 'name=iPhone 16 Pro' -scheme 'Bunny-Package' -skipPackagePluginValidation`
- [ ] `xcodebuild test-without-building -destination 'name=iPhone 16 Pro' -scheme 'Bunny-Package' -skipPackagePluginValidation`
- [ ] Manual playback/upload/camera test
- [ ] Not run, reason:

## SDK User Impact

<!-- Mention public API changes, migration steps, dependency changes, platform changes, or behavior changes. -->

## AI Assistance

- [ ] No substantial AI assistance was used.
- [ ] AI helped with this PR; I reviewed and understand the final changes.

## Checklist

- [ ] The PR is focused on one clear change.
- [ ] `CHANGELOG.md` has an entry under `[Unreleased]`, or the change is invisible to SDK users (CI, tests, internal refactors with no behavior change).
- [ ] Public API or behavior changes are documented.
- [ ] Tests or manual verification are included where appropriate.
- [ ] No secrets, access keys, private URLs, certificates, or provisioning profiles are included.
