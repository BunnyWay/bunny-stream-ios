import Foundation

/// Recognises Bunny's DNS-level geo-block by resolving the CDN host.
///
/// The "Blocked countries" setting is enforced a layer below HTTP: the host is rejected during
/// resolution and answered with a loopback sinkhole (`127.0.0.1`), so no request ever reaches a
/// server and no 403 comes back. All AVFoundation reports is a refused connection, which on its
/// own is indistinguishable from an ordinary outage.
///
/// The Android SDK reads the sinkhole address straight out of OkHttp's `ConnectException`
/// message ("Failed to connect to <host>/127.0.0.1:443"). AVFoundation never exposes the address
/// it dialled, so the lookup is repeated here instead.
///
/// `getaddrinfo` blocks, so ``resolve(host:)`` must not be called on the main thread.
enum SinkholeDetector {
  /// What resolving a host says about a failed connection.
  enum Outcome: Equatable {
    /// The host resolved to a loopback or unspecified address: the stream is blocked for this
    /// viewer, and no retry will help.
    case sinkhole
    /// The host resolved to a routable address, so DNS is not what failed.
    case routable
    /// The host could not be resolved at all — what a device with no working connection looks
    /// like. A geo-block never looks like this: it answers, it just answers with a sinkhole.
    case unresolvable
  }

  /// Resolves `host` and classifies what came back.
  ///
  /// A single sinkhole answer is decisive: a blocked host can also carry routable records (for
  /// example an IPv6 address alongside a sinkholed IPv4 one), and being blocked on any of them
  /// is what the viewer experiences.
  static func resolve(host: String) -> Outcome {
    var hints = addrinfo()
    hints.ai_family = AF_UNSPEC
    hints.ai_socktype = SOCK_STREAM

    var head: UnsafeMutablePointer<addrinfo>?
    guard getaddrinfo(host, nil, &hints, &head) == 0, let first = head else { return .unresolvable }
    defer { freeaddrinfo(first) }

    var sawRoutable = false
    var node: UnsafeMutablePointer<addrinfo>? = first
    while let current = node {
      if let address = current.pointee.ai_addr,
         let literal = numericAddress(address, length: current.pointee.ai_addrlen) {
        if isSinkholeAddress(literal) { return .sinkhole }
        sawRoutable = true
      }
      node = current.pointee.ai_next
    }
    return sawRoutable ? .routable : .unresolvable
  }

  /// Whether a numeric address literal is a loopback or unspecified address.
  ///
  /// Kept free of any I/O so the discriminator itself is testable without touching DNS. Parsing
  /// goes through `inet_pton` rather than string matching, so every way of writing the same
  /// address (`::1`, `0:0:0:0:0:0:0:1`, `::ffff:127.0.0.1`) is treated alike.
  static func isSinkholeAddress(_ address: String) -> Bool {
    // Drop an IPv6 zone index ("fe80::1%en0") and any surrounding brackets.
    let literal = String(address.split(separator: "%", maxSplits: 1).first ?? "")
      .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
    guard !literal.isEmpty else { return false }

    var v4 = in_addr()
    if inet_pton(AF_INET, literal, &v4) == 1 {
      return isSinkholeIPv4(UInt32(bigEndian: v4.s_addr))
    }

    var v6 = in6_addr()
    if inet_pton(AF_INET6, literal, &v6) == 1 {
      let bytes = withUnsafeBytes(of: &v6) { Array($0) }
      // ::1 (loopback) and :: (unspecified).
      if bytes == Self.ipv6Loopback || bytes == Self.ipv6Unspecified { return true }
      // ::ffff:a.b.c.d — an IPv4 address carried in an IPv6 record.
      if Array(bytes.prefix(12)) == Self.ipv4MappedPrefix {
        let mapped = bytes.suffix(4).reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
        return isSinkholeIPv4(mapped)
      }
    }
    return false
  }

  /// `127.0.0.0/8` (loopback) or `0.0.0.0` (unspecified), on a host-order address.
  private static func isSinkholeIPv4(_ address: UInt32) -> Bool {
    address >> 24 == 127 || address == 0
  }

  private static let ipv6Loopback: [UInt8] = Array(repeating: 0, count: 15) + [1]
  private static let ipv6Unspecified = [UInt8](repeating: 0, count: 16)
  private static let ipv4MappedPrefix: [UInt8] = Array(repeating: 0, count: 10) + [0xff, 0xff]

  /// The address behind a `sockaddr`, in its numeric form.
  private static func numericAddress(
    _ address: UnsafeMutablePointer<sockaddr>,
    length: socklen_t
  ) -> String? {
    var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    let status = getnameinfo(
      address, length,
      &buffer, socklen_t(buffer.count),
      nil, 0,
      NI_NUMERICHOST
    )
    guard status == 0 else { return nil }
    return String(cString: buffer)
  }
}
