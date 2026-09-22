# Changelog

All notable changes to Bunny Stream iOS are documented in this file. The format follows
[Keep a Changelog](https://keepachangelog.com/), and the project follows semantic versioning:

- `MAJOR` versions may include breaking API or behavior changes.
- `MINOR` versions add functionality in a backward-compatible way.
- `PATCH` versions include backward-compatible bug fixes and maintenance updates.

## [1.0.0] - Unreleased

The first tagged release of Bunny Stream iOS. Until now the package could only be consumed from a
branch or a commit SHA; from this release on, `.upToNextMajor(from: "1.0.0")` resolves.

Headline addition: live streaming across the SDK — playback, broadcasting from the device camera,
and live stream management.

### Added

- **Live playback** — `BunnyStreamLivePlayer`, a self-driving SwiftUI view that polls the stream
  and swaps between states on its own: countdown for a scheduled stream, looping muted pre-stream
  trailer, live playback with DVR seeking and jump-to-live, offline before the start and after the
  end, and the recording once a finished stream is converted to a VOD.
  - `onStateChange` reports what the player is showing as a `BunnyLiveStreamPlaybackState`
    (`loading`, `playing(isVodRecording:)`, `countdown(until:title:)`,
    `trailer(vodId:scheduledStart:title:)`, `offline(message:)`, `failed(message:)`).
  - `onPlaybackError` reports poll failures, including transient ones the player recovers from;
    `BunnyLiveStreamError.isPermanent` tells a dead end from a hiccup.
  - Live player appearance follows the library's player settings from the Bunny dashboard —
    accent color, font, UI language, control list, heatmap and compact controls.
- **Live broadcasting from the device camera** — `BunnyStreamCameraUploadView(liveStream:...)`
  publishes to an existing live stream's RTMP ingest, starting and stopping the stream server-side.
  - `BunnyBroadcastController` drives and observes the broadcast from outside the view:
    `startBroadcast()`, `stopBroadcast()`, `rotateCamera()`, `toggleMute()`, plus published
    `state`, `elapsedTime`, `isMuted`, `cameraPosition`, `primaryIngestLive`, `backupIngestLive`
    and an `onEvent` callback.
  - Primary/backup ingest failover with proactive reconnect, and ingest badges in the built-in UI.
  - `BroadcastQuality` encoder presets: `.sd480`, `.hd720`, `.fullHd1080`, `.fullHd1080p60`.
- **Live stream management** — `BunnyStreamAPI.liveStreams`, a `LiveStreamRepository` over the
  Manage Live Streams API speaking domain types rather than generated ones: list, get, create,
  update, delete, start, stop, regenerate stream key, fetch play data, ingest status, and
  thumbnails (set from URL, upload, list, delete).
  - Domain models: `BunnyLiveStream`, `BunnyLiveStreamStatus` (0–7), `BunnyLiveStreamList`,
    `BunnyLiveStreamPlayData`, `BunnyLiveStreamIngestStatus`, `BunnyLiveStreamThumbnail`,
    `BunnyRtmpOutput`, `BunnyImageFormat`, `BunnyLiveStreamCreateRequest`,
    `BunnyLiveStreamUpdateRequest`, `BunnyTimestamp`.
  - `BunnyLiveStreamError` — one error type for every repository method, carrying `kind`,
    `statusCode` and `message`, with `isPermanent` so poll loops can branch on it instead of
    matching status codes. Conforms to `LocalizedError`.
  - RTMP outputs (restreaming to third-party destinations) on create and update.
- **Picture in Picture** for on-demand and live playback, with a control-bar button and
  customizable `pictureInPicture` / `pictureInPictureActive` icons in `PlayerIcons`.
- **Client-side watermark** — `PlayerWatermark`, rendered over on-demand and live video.
- `headers` on `BunnyStreamPlayer`, applied to manifest and segment requests — lets a library with
  "Block direct URL file access" enabled play by supplying an allowed `Referer`.
- HTTP 403 handling in the player: geo-blocking, referrer protection and token failures all surface
  as a generic "Video is not available" with no retry, in all 31 supported languages. The cause is
  deliberately not distinguished for viewers.
- `SDKInfo` — the `BunnyStream-iOS/<version>` User-Agent sent on every SDK HTTP request.
- Live-stream overlay strings (`LiveStream.strings`) across all 31 supported languages.
- Example App: live stream demo covering creation, scheduling, stream settings, broadcasting and
  playback.

### Changed

- `VideoPlayerConfigLoader.loadVideoThumbnail(libraryId:videoId:token:expires:)` gained an
  `accessKey:` parameter. It has a default value, so existing call sites keep compiling.
- On-demand playback no longer autoplays; the viewer starts it.

### Fixed

- Fix FairPlay license requests failing with HTTP 500 by sending the raw SPC with
  `Content-Type: application/octet-stream`.
- Fix FairPlay DRM endpoints — the deprecated license URL is replaced by
  `/FairPlay/{libraryId}/license`.
- Fix an endless spinner shown after a video upload completed.
- Fix thumbnail generation, and default thumbnail loading.
- Fix font customization parsing for dashboard-configured player fonts.
- Fix time zone handling in the scheduled-stream countdown.

## Release Notes Guidance

`[1.0.0]` stays marked `Unreleased` until the tag is cut; at that point its heading takes the
release date. After that, new work goes into a fresh `[Unreleased]` section above it.

When preparing a release, move relevant items from `[Unreleased]` into a new version section:

```markdown
## [1.1.0] - 2026-06-05

### Added

- Add ...

### Fixed

- Fix ...
```

For SDK users, call out:

- public API changes,
- migration steps,
- dependency upgrades that may affect apps,
- SwiftPM, Xcode, or minimum platform changes,
- playback, upload, background upload, camera, live streaming, AirPlay, or FairPlay behavior changes,
- security fixes.
