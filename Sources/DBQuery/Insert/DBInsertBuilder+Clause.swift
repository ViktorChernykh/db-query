//
//  DBInsertBuilder+Clause.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

extension DBInsertBuilder {

	@discardableResult
	/// Adds `with` request.
	///
	/// - Parameter sql: DBRaw sql query.
	/// - Returns: `self` for chaining.
	public func with(_ sql: DBRaw) -> Self {
		self.with.append(sql)

		return self
	}

	@discardableResult
	/// Sets list of table's column names.
	///
	/// - Parameter columns: The list of table columns.
	/// - Returns: `self` for chaining.
	public func fields(_ columns: Column...) -> Self {
		self.columns += columns.map {
			DBColumn($0).serialize()
		}
		return self
	}

	@discardableResult
	/// Add values for the `set()`.
	///
	/// - Parameter values: The list of values must be equal columns count.
	/// - Returns: self` for chaining.
	public func values(_ values: Encodable...) -> Self {
		self.inserts.append(DBInsert(values: values.map { DBValue(value: $0) }))

		return self
	}

	@discardableResult
	/// Add values for the `set()`.
	///
	/// - Parameters:
	///   -  value: The list of values must be equal columns count.
	///   - type: Database type.
	/// - Returns: self` for chaining.
	public func value(_ value: Encodable, as type: String? = nil) -> Self {
		let last = self.inserts.count - 1
		self.inserts[last].values.append(DBValue(value: value, type: type))

		return self
	}

	@discardableResult
	/// Append DBInsert for next element.
	///
	/// - Returns: self` for chaining.
	public func new() -> Self {
		self.inserts.append(DBInsert())

		return self
	}

	@discardableResult
	/// Sets a list of table columns to returning from the sql request.
	///
	/// - Parameter columns: The list of table's column name.
	/// - Returns: `self` for chaining.
	public func returning(_ columns: Column...) -> Self {
		self.returning = columns.map {
			DBColumn($0).serialize()
		}
		return self
	}

	@discardableResult
	/// Reset values for the next `INSERT`.
	///
	/// - Returns: `self` for chaining.
	public func resetValues() -> Self {
		self.inserts = []
		self.columns = []

		return self
	}

	@discardableResult
	/// Sets a list of table columns on conflict from the sql request.
	///
	/// - Parameter columns: The list of table column names.
	/// - Returns: `self` for chaining.
	public func onConflict(_ columns: Column...) -> Self {
		self.onConflict = columns.map {
			DBColumn($0).serialize()
		}
		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator.
	///
	/// - Parameters:
	///   - data: The struct with source data for a binary expression.
	///   - type: Database type.
	/// - Returns: `self` for chaining.
	public func set(_ data: ColumnBind, as type: String? = nil) -> Self {
		let lhs = DBColumn(table: nil, data.lhs.key).serialize()
		self.setsForUpdate.append(DBRaw(lhs + data.op, [data.rhs], as: type))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator.
	///
	/// - Parameters:
	///   - column: column to set
	///   - rhs: value for set
	///   - type: Database type.
	/// - Returns: `self` for chaining.
	public func set(_ column: Column, to rhs: Encodable, as type: String? = nil) -> Self {
		let lhs = DBColumn(table: nil, column.key).serialize()
		self.setsForUpdate.append(DBRaw(lhs + " = ", [rhs], as: type))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator.
	///
	/// - Parameters:
	///   - column: column to set
	///   - rhs: value for plus
	/// - Returns: `self` for chaining.
	public func set(_ column: Column, plus rhs: Encodable) -> Self {
		let lhs = DBColumn(table: nil, column.key).serialize()
		self.setsForUpdate.append(DBRaw(lhs + " = " + lhs + " + ", [rhs]))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator for update.
	///
	/// - Parameters:
	///   - column: column to set
	///   - rhs: value for minus
	/// - Returns: `self` for chaining.
	public func set(_ column: Column, minus rhs: Encodable) -> Self {
		let lhs = DBColumn(table: nil, column.key).serialize()
		self.setsForUpdate.append(DBRaw(lhs + " = " + lhs + " - ", [rhs]))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator for update.
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func doUpdateSet(_ data: ColumnBind) -> Self {
		let lhs = DBColumn(table: nil, data.lhs.key).serialize()
		self.setsForUpdate.append(DBRaw(lhs + data.op, [data.rhs]))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator for update.
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func doNothing() -> Self {
		self.isDoNothing = true
		return self
	}
}
