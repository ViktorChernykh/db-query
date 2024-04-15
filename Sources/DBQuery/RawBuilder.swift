import SQLKit

/// Builds raw SQL queries.
///
///     db.raw(DBRaw())
///         .all(decoding: Planet.self)
///
public final class RawBuilder: SQLQueryFetcher {

	/// See `SQLQueryBuilder`.
	public var database: SQLDatabase

	/// See `SQLQueryBuilder`.
	public var query: SQLExpression

	/// Creates a new `RawBuilder`.
	public init(_ query: SQLExpression, on db: SQLDatabase) {
		self.database = db
		self.query = query
	}
}

// MARK: Connection

extension SQLDatabase {
	/// Creates a new `RawBuilder`.
	///
	///     db.raw(DBRaw())...
	///
	/// - parameters:
	///    - sql: The DBRaw - alternative SQLQueryString.
	/// - returns: `RawBuilder`.
	public func raw(_ sql: DBRaw) -> RawBuilder {
#if DEBUG
		print(sql.sql)
#endif
		return .init(sql, on: self)
	}

	/// Creates a new `RawBuilder`.
	/// - Parameter string: SQL string
	/// - Returns: `RawBuilder`.
	public func raw(_ string: String) -> RawBuilder {
#if DEBUG
		print(string)
#endif
		let sql = DBRaw(string)
		return .init(sql, on: self)
	}

	/// Creates a new `RawBuilder`.
	/// - Parameter dbItem: enum DBTransaction
	/// - Returns: `RawBuilder`.
	public func raw(_ dbItem: DBTransaction) -> RawBuilder {
#if DEBUG
		print(dbItem.rawValue)
#endif
		let sql = DBRaw(dbItem.rawValue)
		return .init(sql, on: self)
	}
}
