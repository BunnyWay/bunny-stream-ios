import AVFoundation
import BunnyStreamAPI

class FairPlayStreamHandler: NSObject, AVAssetResourceLoaderDelegate {
  private let videoId: String
  private let libraryId: Int
  private let urlSession = URLSession(configuration: .default)
  private var fairPlayURL: URL
  
  init(videoId: String, libraryId: Int) {
    self.videoId = videoId
    self.libraryId = libraryId
    self.fairPlayURL = URL(string: "\(Constants.videoCoreBaseUrlString)/FairPlayLicense/\(libraryId)/\(videoId)")!
  }
  
  func setupAssetPlayback(url: URL, httpHeaders: [String: String] = [:]) -> AVPlayerItem {
    var headers = httpHeaders
    // "Block direct url file access" (referer hotlink protection) rejects manifest/segment
    // requests that arrive without a Referer (HTTP 403). AVURLAssetHTTPHeaderFieldsKey propagates
    // this header to AVPlayer's own manifest + segment requests, alongside any CMCD headers.
    headers["Referer"] = BunnyCDN.referer
    let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
    asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
    return AVPlayerItem(asset: asset)
  }
  
  func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
    if let url = loadingRequest.request.url,
       url.scheme == "skd",
       let host = url.host,
       let contentIdentifier = Data(base64Encoded: host) {
      Task {
        await handleFairPlayRequest(loadingRequest: loadingRequest, contentIdentifier: contentIdentifier)
      }
      return true
    }
    return false
  }
}

private extension FairPlayStreamHandler {
  func handleFairPlayRequest(loadingRequest: AVAssetResourceLoadingRequest, contentIdentifier: Data) async {
    do {
      let certificateData = try await fetchCertificate(contentIdentifier: contentIdentifier)
      let spcData = try loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdentifier)
      let ckcData = try await fetchCKC(spcData: spcData)
      loadingRequest.dataRequest?.respond(with: ckcData)
      loadingRequest.finishLoading()
    } catch {
      loadingRequest.finishLoading(with: error)
    }
  }
  
  private func fetchCertificate(contentIdentifier: Data) async throws -> Data {
    var request = URLRequest(url: fairPlayURL)
    request.setValue(SDKInfo.userAgent, forHTTPHeaderField: SDKInfo.userAgentHeaderField)
    request.setValue(BunnyCDN.referer, forHTTPHeaderField: "Referer")
    let (data, _) = try await urlSession.data(for: request)
    let certificateResponse = try JSONDecoder().decode(CertificateResponse.self, from: data)
    guard let certificateData = Data(base64Encoded: certificateResponse.certificate) else {
      throw FairPlayHandlerError.invalidCertificateData
    }
    
    return certificateData
  }
  
  private func fetchCKC(spcData: Data) async throws -> Data {
    var request = URLRequest(url: fairPlayURL)
    request.httpMethod = "POST"
    request.setValue(SDKInfo.userAgent, forHTTPHeaderField: SDKInfo.userAgentHeaderField)
    request.setValue(BunnyCDN.referer, forHTTPHeaderField: "Referer")
    let spcRequest = SPCRequest(spc: spcData.base64EncodedString())
    request.httpBody = try JSONEncoder().encode(spcRequest)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, _) = try await urlSession.data(for: request)
    let ckcResponse = try JSONDecoder().decode(CKCResponse.self, from: data)
    guard let ckcData = Data(base64Encoded: ckcResponse.ckc) else {
      throw FairPlayHandlerError.invalidCKCData
    }
    
    return ckcData
  }
}
