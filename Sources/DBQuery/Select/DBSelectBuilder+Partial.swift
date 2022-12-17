//
//  DBSelectBuilder+Partial.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

extension DBSelectBuilder {

	@discardableResult
	/// Sets the distinct value to true for serializing.
	/// - Parameters:
	///   - columns: List of columns for distinct.
	///   - tableAlias: alias for table, by default - the alias from the first table in `FROM`.
	/// - Returns: `self` for chaining.
	public func distinct(_ columns: Column..., as tableAlias: String? = nil) -> Self {
		self.distinct = columns.map {
			let table = tableAlias ?? $0.table
			return DBColumn(table: table, $0.key).serialize()
		}
		return self
	}

	@discardableResult
	/// Adds a `LIMIT` clause to the query. If called more than once, the last call wins.
	///
	/// - Parameter max: Maximum limit.
	/// - Returns: `self` for chaining.
	public func limit(_ max: Int) -> Self {
		self.limit = max
		return self
	}

	@discardableResult
	/// Adds a `OFFSET` clause to the query. If called more than once, the last call wins.
	///
	/// - Parameter n: Offset.
	/// - Returns: `self` for chaining.
	public func offset(_ n: Int) -> Self {
		self.offset = n
		return self
	}
}
