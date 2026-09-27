import XCTest
@testable import BunnyStreamAPI

final class SDKInfoTests: XCTestCase {
  override func tearDown() {
    SDKInfo.configureIntegrator(name: nil, version: nil)
    super.tearDown()
  }

  func testDefaultUserAgentIdentifiesNativeSDK() {
    XCTAssertEqual(SDKInfo.userAgent, "BunnyStream-iOS/1.0.0")
  }

  func testIntegratorIsAppendedWithoutReplacingNativeSDK() {
    SDKInfo.configureIntegrator(name: "bunny-stream-react-native", version: "0.1.1")

    XCTAssertEqual(
      SDKInfo.userAgent,
      "BunnyStream-iOS/1.0.0 bunny-stream-react-native/0.1.1"
    )
  }

  func testEmptyIntegratorResetsConfiguration() {
    SDKInfo.configureIntegrator(name: "wrapper", version: "1")
    SDKInfo.configureIntegrator(name: "  ", version: nil)

    XCTAssertEqual(SDKInfo.userAgent, "BunnyStream-iOS/1.0.0")
  }
}
