import Foundation

public enum SDKInfo {
    public static let version = "1.0.0"
    public static let userAgentHeaderField = "User-Agent"

    public static var userAgent: String {
        state.userAgent
    }

    public static func configureIntegrator(name: String?, version: String?) {
        state.configure(name: name, version: version)
    }

    private static let state = UserAgentState()
}

private final class UserAgentState: @unchecked Sendable {
    private let lock = NSLock()
    private var integrator: String?

    var userAgent: String {
        lock.lock()
        defer { lock.unlock() }
        return ["BunnyStream-iOS/\(SDKInfo.version)", integrator]
            .compactMap { $0 }
            .joined(separator: " ")
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
