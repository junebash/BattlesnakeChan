public struct GameMoveRequest: Codable, Sendable, Equatable {
    public var game: Game
    public var turn: Int
    public var board: Board
    public var you: Battlesnake
}

public enum Direction: String, Codable, Hashable, Sendable, CaseIterable {
    case up, down, left, right
}

public struct MoveResponse: Codable, Sendable, Equatable {
    public var move: Direction
    public var shout: String?
}
