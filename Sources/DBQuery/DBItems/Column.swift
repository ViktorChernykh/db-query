
public struct Column: ExpressibleByStringLiteral {
    public let key: String

    public init(stringLiteral value: String) {
        key = value
    }

    public init(_ value: String) {
        key = value
    }
}

extension Column: CustomStringConvertible {
    public var description: String {
        "\"" + key + "\""
    }
}
