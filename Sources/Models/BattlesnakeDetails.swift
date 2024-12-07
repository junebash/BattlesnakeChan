public enum BattlesnakeAPIVersion: String, Sendable, Hashable, Codable {
    case v1 = "1"
}

public struct Customization: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static var `default`: Self { .init(rawValue: "default") }
}

public struct BattlesnakeDetails: Codable, Sendable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case apiVersion = "apiversion"
        case author, color, head, tail, version
    }

    public var version: SemanticVersion
    public var color: Color
    public var head: Customization = .default
    public var tail: Customization = .default
    public let author: String = "June Bash"
    public let apiVersion: BattlesnakeAPIVersion = .v1

    @TaskLocal public static var current: Self = Self(
        version: SemanticVersion(0, 0, 1),
        color: Color(red: 0.8, green: 0.1, blue: 1)
    )
}
