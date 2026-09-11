import Foundation

extension FairPlayStreamHandler {
  enum FairPlayHandlerError: Error {
    case invalidCertificateData
    case invalidCKCData
    case requestFailed(statusCode: Int)
    case unexpectedResponse
  }
}
