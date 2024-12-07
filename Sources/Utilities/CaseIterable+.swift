extension CaseIterable {
    public static func random(using rng: inout some RandomNumberGenerator) -> Self {
        Self.allCases.randomElement(using: &rng)!
    }

    public static func random() -> Self {
        var rng = SystemRandomNumberGenerator()
        return Self.random(using: &rng)
    }
}
