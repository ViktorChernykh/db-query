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
	public func with(_ sql: Raw) -> Self {
		self.with.append(sql)

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
		let tAlias = tableAlias ?? model.alias
		let schema = DBTable(table: model.schema + self.section, as: tAlias)
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
	///   - columns: The list of table columns name.
	///   - alias: The alternate name for field.
	/// - Returns: `self` for chaining.
	public func returning(_ columns: Column..., as alias: String? = nil) -> Self {
		self.returning = columns.map {
			DBColumn($0, as: alias).serialize()
		}
		return self
	}
}
