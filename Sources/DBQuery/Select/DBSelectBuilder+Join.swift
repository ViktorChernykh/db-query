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
		let joinTable = DBTable(table: model.schema + self.section, as: alias).serialize()
		let join = DBJoin(alias: alias, from: joinTable, method: method)
		self.joins.append(join)

		if self.filters.count > 0,
		   self.filters[0].sql == "\(col: self.alias).\(col: "companyId") = " {
			let column = Column("companyId", alias)
			let companyId = self.filters[0].binds[0]
			on(column == companyId)
		}

		return self
	}

	@discardableResult
	public func onOpenBracket() -> Self {
		let last = lastJoin()
		self.joins[last].filters.append(DBRaw("("))
		
		return self
	}

	@discardableResult
	public func onCloseBracket() -> Self {
		let last = lastJoin()
		self.joins[last].filters.append(DBRaw(")"))

		return self
	}

	/// Common
	///
	///     final class Star: DBModel {
	///     	static let alias = v1.alias
	///         static let schema = v1.schema
	///
	///         id : UUID
	///         name: String
	///
	///         struct v1 {
	///             static let schema = "stars"
	///             static let alias = "s"
	///
	///             static let id = Column("id", Self.alias)
	///             static let name = Column("name", Self.alias)
	///         }
	///     }
	///
	///     final class Planet: DBModel {
	///     	static let alias = v1.alias
	///         static let schema = v1.schema
	///
	///         id : UUID
	///         name: String
	///         starId: UUID
	///
	///         struct v1 {
	///             static let schema = "planets"
	///				static let alias = "p"
	///
	///             static let id = Column("id", Self.alias)
	///             static let name = Column("name", Self.alias)
	///             static let starId = Column("star_id", Self.alias)
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
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func on(_ data: ColumnColumn) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		let rhs = DBColumn(data.rhs).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " AND "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + data.op + rhs))
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
		let lhs = DBColumn(data.lhs).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " AND "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + data.op, [data.rhs]))
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
		let lhs = DBColumn(data.lhs).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " AND "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + data.op, data.rhs))
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
	///   - column: The struct with source data for a binary expression.
	///   - custom: Custom operation for binary expression.
	///   - bind: The right value of the condition.
	/// - Returns: `self` for chaining.
	public func on(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
		let lhs = DBColumn(column).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " AND "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + " \(custom) ", [bind]))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `ON` condition.
	///
	/// - Parameter sql: DBRaw.
	/// - Returns: `self` for chaining.
	public func on(_ sql: DBRaw) -> Self {
		let last = lastJoin()
		self.joins[last].filters.append(sql)
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
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orOn(_ data: ColumnColumn) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		let rhs = DBColumn(data.rhs).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " OR "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + data.op + rhs))
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
		let lhs = DBColumn(data.lhs).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " OR "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + data.op, [data.rhs]))
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
		let lhs = DBColumn(data.lhs).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " OR "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + data.op, data.rhs))
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
	///   - column: The struct with source data for a binary expression.
	///   - custom: A custom operation for binary expression.
	///   - bind: The right value of the condition.
	/// - Returns: `self` for chaining.
	public func orOn(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
		let lhs = DBColumn(column).serialize()
		let last = lastJoin()
		var conj = ""
		if let lastFilter = self.joins[last].filters.last, lastFilter.sql != "(" {
			conj = " OR "
		}
		self.joins[last].filters.append(DBRaw(conj + lhs + " \(custom) ", [bind]))
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
