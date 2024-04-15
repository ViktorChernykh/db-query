//
//  DBUpdateBuilder+Set.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

extension DBUpdateBuilder {
	@discardableResult
	/// Adds value to the `SET` operator.
	///
	/// - Parameters:
	///   - data: The struct with source data for a binary expression.
	///   - type: Database type.
	///   - Returns: `self` for chaining.
	public func set(_ data: ColumnBind, as type: String? = nil) -> Self {
		let lhs = DBColumn(table: nil, data.lhs.key).serialize()
		self.sets.append(Raw(lhs + data.op, [data.rhs], as: type))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator.
	///
	/// - Parameters:
	///   - field: column to set.
	///   - rhs: value for set.
	///   - type: Database type.
	/// - Returns: `self` for chaining.
	public func set(_ field: Column, to rhs: Encodable, as type: String? = nil) -> Self {
		let lhs = DBColumn(table: nil, field.key).serialize()
		self.sets.append(Raw(lhs + " = ", [rhs], as: type))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator.
	///
	/// - Parameters:
	///   - field: column to set.
	///   - rhs: value for plus.
	/// - Returns: `self` for chaining.
	public func set(_ field: Column, plus rhs: Encodable) -> Self {
		let lhs = DBColumn(table: nil, field.key).serialize()
		self.sets.append(Raw(lhs + " = " + lhs + " + ", [rhs]))

		return self
	}

	@discardableResult
	/// Adds value to the `SET` operator for update.
	///
	/// - Parameters:
	///   - field: column to set.
	///   - rhs: value for minus.
	/// - Returns: `self` for chaining.
	public func set(_ field: Column, minus rhs: Encodable) -> Self {
		let lhs = DBColumn(table: nil, field.key).serialize()
		self.sets.append(Raw(lhs + " = " + lhs + " - ", [rhs]))

		return self
	}
}
