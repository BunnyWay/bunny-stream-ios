import Foundation

public enum SDKInfo {
    /// The SDK's released version, as tagged in the repository.
    ///
    /// Bump this in the same commit that updates `CHANGELOG.md` for a release — it is what the
    /// `User-Agent` reports, so a stale value misattributes traffic in Bunny's logs.
    public static let version = "1.0.0"

    /// Sent on every HTTP request the SDK makes.
    public static let userAgent = "BunnyStream-iOS/\(version)"

    public static let userAgentHeaderField = "User-Agent"
}
