public struct SemanticVersion: Sendable, Hashable {
    public var major: Int
    public var minor: Int
    public var patch: Int
    public var note: String?

    public var description: String {
        var str = "\(major).\(minor).\(patch)"
        if let note { str += "-\(note)" }
        return str
    }
}

extension SemanticVersion {
    public init(_ major: Int, _ minor: Int, _ patch: Int, _ note: String? = nil) {
        self.init(major: major, minor: minor, patch: patch, note: note)
    }

    public init?(_ versionString: String) {
        var components = versionString.split(separator: ".")[...]
        guard components.count >= 1 else { return nil }
        var majorStr = components.removeFirst()[...]
        if majorStr.first == "v" { majorStr.removeFirst() }
        guard let major = Int(majorStr) else { return nil }
        var minor: Int?
        if let minorStr = components.popFirst() {
            guard let minorInt = Int(minorStr) else { return nil }
            minor = minorInt
        }
        var patch: Int?
        if let patchStr = components.popFirst() {
            guard let patchInt = Int(patchStr) else { return nil }
            patch = patchInt
        }
        if components.count > 1 { return nil }
        let note = (components.first?.dropFirst()).map(String.init)
        self.init(major, minor ?? 0, patch ?? 0, note)
    }
}

extension SemanticVersion: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)
        self = try SemanticVersion(versionString).orThrows(
            DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Malformed version string: \(versionString)"
            )
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
