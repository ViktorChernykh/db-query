//
//  DBSelectBuilder+Join.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

import SQLKit

extension DBSelectBuilder {
	@discardableResult
	/// This method add new `Join` to the select query.
	///
	/// - Parameters:
	///   - model: Type of model for join.
	///   - method: Join method.
	///   - tableAlias: Alternate alias for the join table.
	/// - Returns: `self` for chaining.
	public func join<J: DBModel>(
		_ model: J.Type,
		_ method: DBJoinMethod,
		as tableAlias: String? = nil
	) -> Self {
		let alias = tableAlias ?? model.alias
		let joinTable = DBTable(self.space, table: model.schema + self.section, as: alias).serialize()
		let join = DBJoin(alias: alias, from: joinTable, method: method)
		self.joins.append(join)

		return self
	}

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

	// MARK: - AND
	@discardableResult
	/// Adds `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .on(p.starId == s.id)...
	///
	/// - Parameters:
	///   - data: The struct with source data for a binary expression.
	///   - rightAlias: An alias for right table.
	/// - Returns: `self` for chaining.
	public func on(_ data: ColumnColumn, _ rightAlias: String) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data.lhs).serialize()
		let rhs = DBColumn(table: rightAlias, data.rhs).serialize()

		self.joins[last].filterAnd.append(DBRaw(lhs + data.op + rhs))
		return self
	}

	@discardableResult
	/// Adds `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .on(p.name == "Earth")...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func on(_ data: ColumnBind) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data.lhs).serialize()

		self.joins[last].filterAnd.append(DBRaw(lhs + data.op, [data.rhs]))
		return self
	}

	@discardableResult
	/// Adds `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .on(p.name ~~ ["Earth", "Mars"])...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func on(_ data: ColumnBinds) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data.lhs).serialize()

		self.joins[last].filterAnd.append(DBRaw(lhs + data.op, data.rhs))
		return self
	}

	@discardableResult
	/// Adds custom `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .on(p.name, "ILIKE", "%\(name)%")...
	///
	/// - Parameters:
	///   - data: The struct with source data for a binary expression.
	///   - custom: Custom operation for binary expression.
	///   - bind: The right value of the condition.
	/// - Returns: `self` for chaining.
	public func on(_ data: Column, _ custom: String, _ bind: Encodable) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data).serialize()

		self.joins[last].filterAnd.append(DBRaw(lhs + " \(custom) ", [bind]))
		return self
	}

	// MARK: - OR
	@discardableResult
	/// Adds `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .orOn(p.starId == s.id")...
	///
	/// - Parameters:
	///   - data: The struct with source data for a binary expression.
	///   - rightAlias: An alias for right table.
	/// - Returns: `self` for chaining.
	public func orOn(_ data: ColumnColumn, _ rightAlias: String) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data.lhs).serialize()
		let rhs = DBColumn(table: rightAlias, data.rhs).serialize()

		self.joins[last].filterOr.append(DBRaw(lhs + data.op + rhs))
		return self
	}

	@discardableResult
	/// Adds `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .orOn(p.name ~~ ["Earth", "Mars"])...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orOn(_ data: ColumnBind) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data.lhs).serialize()

		self.joins[last].filterOr.append(DBRaw(lhs + data.op, [data.rhs]))
		return self
	}

	@discardableResult
	/// Adds `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .orOn(p.name == "Earth")...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orOn(_ data: ColumnBinds) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data.lhs).serialize()

		self.joins[last].filterOr.append(DBRaw(lhs + data.op, data.rhs))
		return self
	}

	@discardableResult
	/// Adds custom `ON` condition for last `Join`.
	///
	///     query
	///     .join(Planet.self, .left)
	///     .orOn(p.name, "ILIKE", "%\(name)%")...
	///
	/// - Parameters:
	///   - data: The struct with source data for a binary expression.
	///   - custom: A custom operation for binary expression.
	///   - bind: The right value of the condition.
	/// - Returns: `self` for chaining.
	public func orOn(_ data: Column, _ custom: String, _ bind: Encodable) -> Self {
		let last = lastJoin()
		let lhs = DBColumn(table: self.joins[last].alias, data).serialize()

		self.joins[last].filterOr.append(DBRaw(lhs + " \(custom) ", [bind]))
		return self
	}

	/// Count the number of initiated Joins. If the number is 0, throws a fatal error.
	/// - Returns: number of initiated Joins.
	private func lastJoin() -> Int {
		let last = self.joins.count - 1
		guard last >= 0 else {
			fatalError("No initiated joins.")
		}
		return last
	}
}
