//
//  DBSelectBuilder+Predicate.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

extension DBSelectBuilder {
	/// Common
	///
	///     final class Star: DBModel {
	///         static let schema = v1.schema
	///         id : UUID
	///         name: String
	///
	///         struct v1 {
	///             static let schema = "stars"
	///             static let id = Column("id")
	///             static let name = Column("name")
	///         }
	///     }
	///
	///     final class Planet: DBModel {
	///         static let schema = v1.schema
	///         id : UUID
	///         name: String
	///         starId: UUID
	///
	///         struct v1 {
	///             static let schema = "planets"
	///             static let id = Column("id")
	///             static let name = Column("name")
	///             static let starId = Column("star_id")
	///         }
	///     }
	///
	///     typealias p = Planet.v1
	///     typealias s = Star.v1
	///
	///     let query = Star.select(section: "aa", on: db)
	///         .filter(s.id == id)

	// MARK: --- AND ---
	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .filter(p.name == p.otherField)...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func filter(_ data: ColumnColumn) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		let rhs = DBColumn(data.rhs).serialize()

		self.filterAnd.append(DBRaw(lhs + data.op + rhs))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .filter(p.name == "Earth")...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func filter(_ data: ColumnBind) -> Self {
		let lhs = DBColumn(data.lhs).serialize()

		self.filterAnd.append(DBRaw(lhs + data.op, [data.rhs]))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .filter(p.name ~~ ["Earth", "Mars"])...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func filter(_ data: ColumnBinds) -> Self {
		let lhs = DBColumn(data.lhs).serialize()

		self.filterAnd.append(DBRaw(lhs + data.op, data.rhs))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .filter(p.name, "ILIKE", "%\(name)%")...
	///
	/// - Parameters:
	///   - column: The left values of the condition.
	///   - custom: An custom operation for a binary expression.
	///   - bind: The right value of the condition.
	/// - Returns: `self` for chaining.
	public func filter(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
		let lhs = DBColumn(column).serialize()

		self.filterAnd.append(DBRaw(lhs + " \(custom) ", [bind]))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition.
	///
	/// - Parameter sql: DBRaw.
	/// - Returns: `self` for chaining.
	public func filter(_ sql: DBRaw) -> Self {
		self.filterAnd.append(sql)
		return self
	}

	// MARK: --- OR ---

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .orFilter(p.name == p.otherField)...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orFilter(_ data: ColumnColumn) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		let rhs = DBColumn(data.rhs).serialize()

		self.filterOr.append(DBRaw(lhs + data.op + rhs))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .orFilter(p.name == "Earth")...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orFilter(_ data: ColumnBind) -> Self {
		let lhs = DBColumn(data.lhs).serialize()

		self.filterOr.append(DBRaw(lhs + data.op, [data.rhs]))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .orFilter(p.name ~~ ["Earth", "Mars"])...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orFilter(_ data: ColumnBinds) -> Self {
		let lhs = DBColumn(data.lhs).serialize()

		self.filterOr.append(DBRaw(lhs + data.op, data.rhs))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .orFilter(p.name, "ILIKE", "%\(name)%")...
	///
	/// - Parameters:
	///   - column: The left values of the condition.
	///   - custom: A custom operation for a binary expression.
	///   - bind: The right value of the condition.
	/// - Returns: `self` for chaining.
	public func orFilter(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
		let lhs = DBColumn(column).serialize()

		self.filterOr.append(DBRaw(lhs + " \(custom) ", [bind]))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition.
	///
	/// - Parameter sql: DBRaw.
	/// - Returns: `self` for chaining.
	public func orFilter(_ sql: DBRaw) -> Self {
		self.filterOr.append(sql)
		return self
	}
}
