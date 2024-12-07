public struct Board: Codable, Sendable, Equatable {
    public let width: Int
    public let height: Int
    public var food: [Point]
    public var hazards: [Point]
    public var snakes: [Battlesnake]
}
