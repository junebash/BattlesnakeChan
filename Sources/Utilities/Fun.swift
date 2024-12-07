infix operator |>

public func |> <T> (lhs: consuming T, rhs: (inout T) -> Void) -> T {
    rhs(&lhs)
    return lhs
}
