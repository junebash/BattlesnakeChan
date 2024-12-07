extension Optional {
    public struct UnwrapError: Error {}

    public func orThrows(_ error: @autoclosure () -> any Error) throws -> Wrapped {
        switch self {
        case .none: throw error()
        case .some(let wrapped): return wrapped
        }
    }

    public func orThrows() throws -> Wrapped {
        try self.orThrows(UnwrapError())
    }
}
