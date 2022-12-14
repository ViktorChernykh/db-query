//
//  DBDeleteBuilder+Clause.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

import SQLKit

extension DBDeleteBuilder {

	@discardableResult
	/// Adds the raw `with` subquery to the select query.
	///
	/// - Parameter sql: raw `with` query.
	/// - Returns: `self` for chaining.
	public func with(_ sql: DBRaw) -> Self {
		self.with = sql

		return self
	}

	@discardableResult
	/// Sets the `using` model.
	///
	/// - Parameters:
	///   - model: The model type for `using`.
	///   - tableAlias: The table alias for an `using` model.
	/// - Returns: `self` for chaining.
	public func using<F: DBModel>(_ model: F.Type, _ tableAlias: String? = nil) -> Self {
		let alias = tableAlias ?? model.alias
		let schema = DBTable(space, table: model.schema + self.section, as: alias)
		self.using.append(schema.serialize())

		return self
	}

	@discardableResult
	/// Sets the cursor's name.
	///
	/// - Parameter name: The name of the cursor.
	/// - Returns: `self` for chaining.
	public func cursor(_ name: String) -> Self {
		self.cursor = name

		return self
	}

	@discardableResult
	/// Sets a list of table columns to returning from the sql request.
	///
	/// - Parameters:
	///   - fields: The list of table columns name.
	///   - tableAlias: The alternate alias for `using` model.
	/// - Returns: `self` for chaining.
	public func returning(_ fields: Column..., as tableAlias: String? = nil) -> Self {
		let table = tableAlias ?? self.alias
		self.returning = fields.map {
			DBColumn(table: table, $0).serialize()
		}
		return self
	}
}
