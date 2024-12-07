
public struct Color: Sendable, Hashable {
    fileprivate struct MissingInfoKey: Error {}

    public enum CodingStrategy {
        case ints
        case floats
        case hexString

        fileprivate static var infoKey: CodingUserInfoKey {
            get throws {
                try CodingUserInfoKey(rawValue: "com-junebash-BattlesnakeChan-ColorCodingStrategy")
                    .orThrows(MissingInfoKey())
            }
        }
    }

    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public init(red: Double, green: Double, blue: Double) {
        self.init(red: UInt8(red * 255), green: UInt8(green * 255), blue: UInt8(blue * 255))
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
    }

    public init(from decoder: any Decoder) throws {
        let strategy = (try? decoder.userInfo[CodingStrategy.infoKey] as? CodingStrategy) ?? .hexString
        switch strategy {
        case .ints:
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let red = try container.decode(UInt8.self, forKey: .red)
            let green = try container.decode(UInt8.self, forKey: .green)
            let blue = try container.decode(UInt8.self, forKey: .blue)
            self.init(red: red, green: green, blue: blue)
        case .floats:
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let red = UInt8(try container.decode(Double.self, forKey: .red) * 255)
            let green = UInt8(try container.decode(Double.self, forKey: .green) * 255)
            let blue = UInt8(try container.decode(Double.self, forKey: .blue) * 255)
            self.init(red: red, green: green, blue: blue)
        case .hexString:
            let container = try decoder.singleValueContainer()
            var string = try container.decode(String.self)[...]
            guard
                string.count == 7,
                string.removeFirst() == "#"
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid string: \(string.base)"
                )
            }
            let red = UInt8(string.prefix(2), radix: 16)
            string.removeFirst(2)
            let green = UInt8(string.prefix(2), radix: 16)
            string.removeFirst(2)
            let blue = UInt8(string, radix: 16)
            guard let red, let green, let blue else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid string: \(string.base)"
                )
            }
            self.init(red: red, green: green, blue: blue)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        let strategy = (try? encoder.userInfo[CodingStrategy.infoKey] as? CodingStrategy) ?? .hexString
        switch strategy {
        case .ints:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.red, forKey: .red)
            try container.encode(self.green, forKey: .green)
            try container.encode(self.blue, forKey: .blue)
        case .floats:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(Double(self.red) / 255, forKey: .red)
            try container.encode(Double(self.green) / 255, forKey: .green)
            try container.encode(Double(self.blue) / 255, forKey: .blue)
        case .hexString:
            let redStr = String(self.red, radix: 16, uppercase: true)
            let greenStr = String(self.green, radix: 16, uppercase: true)
            let blueStr = String(self.blue, radix: 16, uppercase: true)
            var container = encoder.singleValueContainer()
            try container.encode("#\(redStr)\(greenStr)\(blueStr)")
        }
    }
}

#if canImport(Foundation)
import Foundation

private extension Dictionary where Key == CodingUserInfoKey, Value == Any {
    var colorCodingStrategy: Color.CodingStrategy {
        get {
            (try? Color.CodingStrategy.infoKey).flatMap {
                self[$0] as? Color.CodingStrategy
            } ?? .hexString
        }
        set {
            guard let infoKey = try? Color.CodingStrategy.infoKey else { return }
            self[infoKey] = newValue
        }
    }
}

extension JSONDecoder {
    public var colorCodingStrategy: Color.CodingStrategy {
        get { userInfo.colorCodingStrategy }
        set { userInfo.colorCodingStrategy = newValue }
    }
}

extension JSONEncoder {
    public var colorCodingStrategy: Color.CodingStrategy {
        get { userInfo.colorCodingStrategy }
        set { userInfo.colorCodingStrategy = newValue }
    }
}
#endif
