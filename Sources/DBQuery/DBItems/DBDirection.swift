
public enum DBDirection {
	case asc
	case desc
	/// Order in which NULL values come first.
	case null
	/// Order in which NOT NULL values come first.
	case notNull

	public func serialize() -> String {
		switch self {
		case .asc:
			return " ASC"
		case .desc:
			return " DESC"
		case .null:
			return " NULL"
		case .notNull:
			return " NOT NULL"
		}
	}
}
