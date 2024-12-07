public struct Game: Codable, Equatable, Sendable {
    public struct RuleSet: Codable, Equatable, Sendable {
        public let name: String
        public let version: SemanticVersion
    }

    public enum Source: String, Hashable, Codable, Sendable {
        case tournament, league, arena, challenge, custom
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ruleset
        case mapName = "map"
        case timeoutMilliseconds = "timeout"
        case source
    }

    public let id: String
    public let ruleset: RuleSet
    public let mapName: String
    public let timeoutMilliseconds: Int
    public let source: Source

    public var timeout: Duration {
        .milliseconds(timeoutMilliseconds)
    }
}
