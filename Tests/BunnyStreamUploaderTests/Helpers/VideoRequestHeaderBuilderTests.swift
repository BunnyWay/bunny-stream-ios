import BunnyStreamAPI
import XCTest
@testable import BunnyStreamUploader

final class VideoRequestHeaderBuilderTests: XCTestCase {
  var headerBuilder: VideoRequestHeaderBuilder!
  
  override func setUp() {
    super.setUp()
    headerBuilder = VideoRequestHeaderBuilder()
  }
  
  override func tearDown() {
    SDKInfo.configureIntegrator(name: nil, version: nil)
    headerBuilder = nil
    super.tearDown()
  }
  
  func testBuildHeaders() {
    // Given
    let videoId = "video123"
    let info = VideoInfo(content: .data(Data()),
                         title: "SampleVideo",
                         fileType: "video/quicktime",
                         videoId: videoId,
                         libraryId: 123123,
                         expirationTime: 123123123)
    let signature = "sampleSignature"
    
    // When
    let headers = headerBuilder.buildHeaders(for: info, signature: signature)
    
    // Then
    XCTAssertEqual(headers["AuthorizationSignature"], signature)
    XCTAssertEqual(headers["AuthorizationExpire"], "123123123")
    XCTAssertEqual(headers["VideoId"], "video123")
    XCTAssertEqual(headers["LibraryId"], "123123")
    XCTAssertEqual(headers[SDKInfo.userAgentHeaderField], SDKInfo.userAgent)
    let filenameBase64 = "SampleVideo".data(using: .utf8)?.base64EncodedString()
    let filetypeBase64 = "video/quicktime".data(using: .utf8)?.base64EncodedString()
    XCTAssertEqual(headers["Upload-Metadata"], "filename \(filenameBase64 ?? ""),filetype \(filetypeBase64 ?? "")")
  }

  func testBuildHeadersUsesConfiguredIntegrator() {
    SDKInfo.configureIntegrator(name: "bunny-stream-react-native", version: "0.1.1")
    let info = VideoInfo(
      content: .data(Data()),
      title: "Video",
      fileType: "video/mp4",
      videoId: "video",
      libraryId: 1
    )

    let headers = headerBuilder.buildHeaders(for: info, signature: "signature")

    XCTAssertEqual(
      headers[SDKInfo.userAgentHeaderField],
      "BunnyStream-iOS/1.0.0 bunny-stream-react-native/0.1.1"
    )
  }
}
