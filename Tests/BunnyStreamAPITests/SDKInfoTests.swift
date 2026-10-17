import XCTest
@testable import BunnyStreamAPI

final class SDKInfoTests: XCTestCase {
  override func tearDown() {
    SDKInfo.configureIntegrator(name: nil, version: nil)
    super.tearDown()
  }

  func testDefaultUserAgentIdentifiesNativeSDK() {
    XCTAssertTrue(
      SDKInfo.userAgent.hasSuffix("bunny-stream-ios/1.0.0 (\(PlatformInfo.deviceType))"),
      SDKInfo.userAgent
    )
  }

  func testUserAgentStartsWithPlatformUserAgent() {
    XCTAssertTrue(SDKInfo.userAgent.contains("Darwin/"), SDKInfo.userAgent)
    XCTAssertTrue(SDKInfo.userAgent.hasPrefix(PlatformInfo.defaultUserAgent), SDKInfo.userAgent)
  }

  func testIntegratorIsAppendedWithoutReplacingNativeSDK() {
    SDKInfo.configureIntegrator(name: "bunny-stream-react-native", version: "0.1.1")

    XCTAssertTrue(
      SDKInfo.userAgent.hasSuffix(
        "bunny-stream-ios/1.0.0 (\(PlatformInfo.deviceType)) bunny-stream-react-native/0.1.1"
      ),
      SDKInfo.userAgent
    )
  }

  func testEmptyIntegratorResetsConfiguration() {
    SDKInfo.configureIntegrator(name: "wrapper", version: "1")
    SDKInfo.configureIntegrator(name: "  ", version: nil)

    XCTAssertTrue(
      SDKInfo.userAgent.hasSuffix("bunny-stream-ios/1.0.0 (\(PlatformInfo.deviceType))"),
      SDKInfo.userAgent
    )
  }

  func testMakeUserAgentFormat() {
    XCTAssertEqual(
      SDKInfo.makeUserAgent(
        platformUserAgent: "MyApp/42 CFNetwork/1568.100.1 Darwin/24.0.0",
        deviceType: "tablet",
        integrator: "bunny-stream-react-native/1.0.0"
      ),
      "MyApp/42 CFNetwork/1568.100.1 Darwin/24.0.0 bunny-stream-ios/1.0.0 (tablet) bunny-stream-react-native/1.0.0"
    )
  }

  func testMakeUserAgentWithoutPlatformUserAgent() {
    XCTAssertEqual(
      SDKInfo.makeUserAgent(platformUserAgent: "", deviceType: "mobile", integrator: nil),
      "bunny-stream-ios/1.0.0 (mobile)"
    )
  }

  func testDeviceTypeForModel() {
    XCTAssertEqual(PlatformInfo.deviceType(forModel: "iPhone16,2"), "mobile")
    XCTAssertEqual(PlatformInfo.deviceType(forModel: "iPad14,5"), "tablet")
    XCTAssertEqual(PlatformInfo.deviceType(forModel: "AppleTV14,1"), "tv")
  }
}
