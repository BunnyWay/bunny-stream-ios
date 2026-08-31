import AVFoundation
import BunnyStreamAPI

class FairPlayStreamHandler: NSObject, AVAssetResourceLoaderDelegate {
  private let urlSession = URLSession(configuration: .default)
  private let certificateURL: URL
  private let licenseURL: URL

  /// - Parameters:
  ///   - token: Optional embed-view token, required when the library enforces token authentication.
  ///   - expires: Expiration timestamp that `token` was signed with.
  init(videoId: String, libraryId: Int, token: String? = nil, expires: Int64? = nil) {
    // The certificate and license endpoints apply the same referrer protection and embed token
    // authentication as the player embed view, so both carry the playback token when there is one.
    var authQueryItems: [URLQueryItem] = []
    if let token {
      authQueryItems.append(URLQueryItem(name: "token", value: token))
    }
    if let expires {
      authQueryItems.append(URLQueryItem(name: "expires", value: String(expires)))
    }

    certificateURL = Self.makeURL(path: "/FairPlay/\(libraryId)/certificate", queryItems: authQueryItems)
    licenseURL = Self.makeURL(
      path: "/FairPlay/\(libraryId)/license",
      queryItems: [URLQueryItem(name: "videoId", value: videoId)] + authQueryItems
    )
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
      let certificateData = try await fetchCertificate()
      let spcData = try loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdentifier)
      let ckcData = try await fetchCKC(spcData: spcData)
      loadingRequest.dataRequest?.respond(with: ckcData)
      loadingRequest.finishLoading()
    } catch {
      loadingRequest.finishLoading(with: error)
    }
  }
  
  /// Fetches the FairPlay application certificate, returned as raw DER bytes.
  private func fetchCertificate() async throws -> Data {
    var request = URLRequest(url: certificateURL)
    request.setValue(SDKInfo.userAgent, forHTTPHeaderField: SDKInfo.userAgentHeaderField)
    request.setValue(BunnyCDN.referer, forHTTPHeaderField: "Referer")
    let data = try await send(request, endpoint: "certificate")
    guard !data.isEmpty else {
      throw FairPlayHandlerError.invalidCertificateData
    }
    
    return data
  }
  
  /// Exchanges the SPC for a CKC. The license endpoint takes the raw SPC bytes as the request body
  /// and answers with the raw CKC bytes — a JSON wrapper (as used by the retired
  /// `/FairPlayLicense/{libraryId}/{videoId}` endpoint) makes it fail.
  private func fetchCKC(spcData: Data) async throws -> Data {
    var request = URLRequest(url: licenseURL)
    request.httpMethod = "POST"
    request.setValue(SDKInfo.userAgent, forHTTPHeaderField: SDKInfo.userAgentHeaderField)
    request.setValue(BunnyCDN.referer, forHTTPHeaderField: "Referer")
    request.httpBody = spcData
    
    let data = try await send(request, endpoint: "license")
    guard !data.isEmpty else {
      throw FairPlayHandlerError.invalidCKCData
    }
    
    return data
  }
  
  private func send(_ request: URLRequest, endpoint: String) async throws -> Data {
    let (data, response) = try await urlSession.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw FairPlayHandlerError.unexpectedResponse
    }
    guard (200...299).contains(httpResponse.statusCode) else {
      // Surface the status for integrators debugging DRM playback (a 401/403 here usually means a
      // missing or expired embed token, or referrer protection rejecting the request). The URL is
      // omitted on purpose — its query carries the playback token.
      print("[BunnyStreamPlayer] FairPlay \(endpoint) HTTP \(httpResponse.statusCode)")
      throw FairPlayHandlerError.requestFailed(statusCode: httpResponse.statusCode)
    }
    
    return data
  }
  
  private static func makeURL(path: String, queryItems: [URLQueryItem]) -> URL {
    var components = URLComponents(string: Constants.fairPlayBaseUrlString)!
    components.path = path
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }
    
    return components.url!
  }
}
