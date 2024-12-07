public struct Battlesnake: Equatable, Sendable, Codable, Identifiable {
    public struct Customizations: Codable, Equatable, Sendable {
        public var color: Color?
        public var head: Customization?
        public var tail: Customization?
    }

    public let id: String
    public let name: String
    public var health: Int
    public var body: [Point]
    public var latency: String
    public var head: Point
    public var shout: String
    public var squad: String
    public var customizations: Customizations?

    public var latencyDuration: Duration? {
        Double(latency).map { .milliseconds($0) }
    }
}
