import XCTest
@testable import BunnyStreamPlayer

/// Verifies the Quality menu caps come from the stream's real variants. Fixed per-resolution
/// values sat below Bunny's measured peak `BANDWIDTH`, so picking 1080p played 720p.
final class ResolutionPeakBitRateCapsTests: XCTestCase {

    private let resolutions: [Video.Resolution] = [.auto, .res240p, .res360p, .res480p, .res720p, .res1080p]

    // Peak BANDWIDTH from a real Bunny master playlist, in playlist order (not sorted).
    private let variantPeaks: [Double] = [1_306_976, 2_233_064, 4_647_699, 738_464, 8_183_762]

    func test_eachCapAdmitsItsVariantAndExcludesTheNextOneUp() throws {
        let caps = try XCTUnwrap(Video.Resolution.peakBitRateCaps(for: resolutions, variantPeakBitRates: variantPeaks))
        let ranked: [(Video.Resolution, Double)] = [
            (.res240p, 738_464), (.res360p, 1_306_976), (.res480p, 2_233_064), (.res720p, 4_647_699)
        ]
        for (index, (resolution, peak)) in ranked.enumerated() {
            let cap = try XCTUnwrap(caps[resolution])
            XCTAssertGreaterThanOrEqual(cap, peak, "\(resolution.rawValue) cap excludes its own variant")
            let nextPeak = index + 1 < ranked.count ? ranked[index + 1].1 : 8_183_762
            XCTAssertLessThan(cap, nextPeak, "\(resolution.rawValue) cap admits the next variant up")
        }
    }

    func test_topResolutionAndAutoAreUncapped() throws {
        let caps = try XCTUnwrap(Video.Resolution.peakBitRateCaps(for: resolutions, variantPeakBitRates: variantPeaks))
        XCTAssertEqual(caps[.res1080p], 0)
        XCTAssertEqual(caps[.auto], 0)
    }

    // The fixed 1080p value (5 Mbps) sits below this variant's 8.18 Mbps peak — the original bug.
    func test_fixedBitrateWouldExcludeThe1080pVariant() {
        XCTAssertLessThan(Video.Resolution.res1080p.bitrate, 8_183_762)
    }

    func test_returnsNilWhenVariantCountDoesNotMatch() {
        XCTAssertNil(Video.Resolution.peakBitRateCaps(for: resolutions, variantPeakBitRates: [738_464, 1_306_976]))
        XCTAssertNil(Video.Resolution.peakBitRateCaps(for: resolutions, variantPeakBitRates: []))
        XCTAssertNil(Video.Resolution.peakBitRateCaps(for: [.auto], variantPeakBitRates: []))
    }

    func test_1440pAnd2160pAreListedFromPlayResponse() {
        XCTAssertEqual(Video.Resolution(rawValue: "1440p"), .res1440p)
        XCTAssertEqual(Video.Resolution(rawValue: "2160p"), .res2160p)
        XCTAssertLessThan(Video.Resolution.res1080p.bitrate, Video.Resolution.res1440p.bitrate)
        XCTAssertLessThan(Video.Resolution.res1440p.bitrate, Video.Resolution.res2160p.bitrate)
    }
}
