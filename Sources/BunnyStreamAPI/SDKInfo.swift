import Foundation

public enum SDKInfo {
    public static let name = "bunny-stream-ios"
    public static let version = "1.0.0"
    public static let userAgentHeaderField = "User-Agent"

    /// `<platform UA> bunny-stream-ios/<version> (<device type>) [<integrator>/<version>]`,
    /// e.g. `MyApp/42 CFNetwork/1568.100.1 Darwin/24.0.0 bunny-stream-ios/1.0.0 (mobile)`.
    public static var userAgent: String {
        state.userAgent
    }

    public static func configureIntegrator(name: String?, version: String?) {
        state.configure(name: name, version: version)
    }

    static func makeUserAgent(platformUserAgent: String?, deviceType: String, integrator: String?) -> String {
        [platformUserAgent, "\(name)/\(version) (\(deviceType))", integrator]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static let state = UserAgentState()
}

private final class UserAgentState: @unchecked Sendable {
    private let lock = NSLock()
    private var integrator: String?
    private let platformUserAgent = PlatformInfo.defaultUserAgent
    private let deviceType = PlatformInfo.deviceType

    var userAgent: String {
        lock.lock()
        defer { lock.unlock() }
        return SDKInfo.makeUserAgent(
            platformUserAgent: platformUserAgent,
            deviceType: deviceType,
            integrator: integrator
        )
    }

    func configure(name: String?, version: String?) {
        lock.lock()
        defer { lock.unlock() }
        guard let name = normalized(name) else {
            integrator = nil
            return
        }
        integrator = normalized(version).map { "\(name)/\($0)" } ?? name
    }

    private func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalized.isEmpty ? nil : normalized.replacingOccurrences(of: " ", with: "-")
    }
}

enum PlatformInfo {
    /// Rebuilds the User-Agent URLSession would send by default (`<App>/<build> CFNetwork/<ver> Darwin/<ver>`),
    /// since setting the header explicitly replaces it.
    static var defaultUserAgent: String {
        let info = Bundle.main.infoDictionary
        let appName = (info?["CFBundleName"] as? String) ?? (info?["CFBundleExecutable"] as? String)
        let appVersion = info?["CFBundleVersion"] as? String
        let cfNetworkVersion = Bundle(identifier: "com.apple.CFNetwork")?
            .infoDictionary?["CFBundleShortVersionString"] as? String

        var components: [String] = []
        if let appName = appName?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), !appName.isEmpty {
            components.append(appVersion.map { "\(appName)/\($0)" } ?? appName)
        }
        if let cfNetworkVersion {
            components.append("CFNetwork/\(cfNetworkVersion)")
        }
        if let darwinVersion = systemInfo(\.release) {
            components.append("Darwin/\(darwinVersion)")
        }
        return components.joined(separator: " ")
    }

    /// `mobile`, `tablet`, `tv` or `desktop`. Derived from the hardware model so it can be read off the main thread.
    static var deviceType: String {
        #if os(tvOS)
        return "tv"
        #elseif os(macOS)
        return "desktop"
        #else
        if ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp {
            return "desktop"
        }
        return deviceType(forModel: hardwareModel)
        #endif
    }

    static func deviceType(forModel model: String) -> String {
        if model.hasPrefix("iPad") { return "tablet" }
        if model.hasPrefix("AppleTV") { return "tv" }
        return "mobile"
    }

    private static var hardwareModel: String {
        // On the simulator `uname` reports the host architecture (e.g. `arm64`).
        ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? systemInfo(\.machine) ?? ""
    }

    private static func systemInfo<T>(_ keyPath: KeyPath<utsname, T>) -> String? {
        var systemInfo = utsname()
        guard uname(&systemInfo) == 0 else { return nil }
        let value = withUnsafeBytes(of: systemInfo[keyPath: keyPath]) { buffer in
            String(decoding: buffer.prefix { $0 != 0 }, as: UTF8.self)
        }
        return value.isEmpty ? nil : value
    }
}
