//
//  DBPredicateForSelectDelete.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public protocol DBPredicateForSelectDelete: AnyObject {
	var filters: [DBRaw] { get set }
}

extension DBPredicateForSelectDelete {
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

	@discardableResult
	public func openBracket() -> Self {
		self.filters.append(DBRaw("("))
		return self
	}

	@discardableResult
	public func closeBracket() -> Self {
		self.filters.append(DBRaw(")"))
		return self
	}
	
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
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + lhs + data.op + rhs))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .filter(p.name == "Earth")...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func filter(_ data: ColumnBind, as type: String? = nil) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + lhs + data.op, [data.rhs], as: type))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .filter(p.name ~~ ["Earth", "Mars"])...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func filter(_ data: ColumnBinds, as type: String? = nil) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + lhs + data.op, data.rhs, as: type))
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
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + lhs + " \(custom) ", [bind]))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition.
	///
	///     .filter(p.name, "ILIKE", ["%\(name)%"])...
	///
	/// - Parameters:
	///   - column: The left values of the condition.
	///   - custom: A custom operation for a binary expression.
	///   - binds: The right values of the condition.
	/// - Returns: `self` for chaining.
	public func filter(_ column: Column, _ custom: String, _ binds: [Encodable]) -> Self {
		let lhs = DBColumn(column).serialize()
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + lhs + " \(custom) ", binds))
		return self
	}

	@discardableResult
	public func filter(_ query: String, _ custom: String, _ bind: Encodable) -> Self {
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + query + " \(custom) ", [bind]))
		return self
	}

	@discardableResult
	public func filter(_ query: String, _ custom: String, _ binds: [Encodable]) -> Self {
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + query + " \(custom) ", binds))
		return self
	}

	@discardableResult
	public func filter(_ query: String, _ custom: String, _ column: Column) -> Self {
		let rhs = DBColumn(column).serialize()
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " AND "
		}
		self.filters.append(DBRaw(conj + query + " \(custom) " + rhs))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition.
	///
	/// - Parameter sql: DBRaw.
	/// - Returns: `self` for chaining.
	public func filter(_ sql: DBRaw) -> Self {
		self.filters.append(sql)
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
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " OR "
		}
		self.filters.append(DBRaw(conj + lhs + data.op + rhs))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .orFilter(p.name == "Earth")...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orFilter(_ data: ColumnBind, as type: String? = nil) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " OR "
		}
		self.filters.append(DBRaw(conj + lhs + data.op, [data.rhs], as: type))
		return self
	}

	@discardableResult
	/// Creates binary expression from struct with source data to `WHERE` condition
	///
	///     .orFilter(p.name ~~ ["Earth", "Mars"])...
	///
	/// - Parameter data: The struct with source data for a binary expression.
	/// - Returns: `self` for chaining.
	public func orFilter(_ data: ColumnBinds, as type: String? = nil) -> Self {
		let lhs = DBColumn(data.lhs).serialize()
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " OR "
		}
		self.filters.append(DBRaw(conj + lhs + data.op, data.rhs, as: type))
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
		var conj = ""
		if let last = filters.last, last.sql != "(" {
			conj = " OR "
		}
		self.filters.append(DBRaw(conj + lhs + " \(custom) ", [bind]))
		return self
	}
}
