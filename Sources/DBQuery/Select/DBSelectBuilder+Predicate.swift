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
    /// - Parameters:
    ///   - data: The struct with source data for a binary expression.
    ///   - leftAlias: An alias for left table.
    ///   - rightAlias: An alias for right table.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnColumn, _ leftAlias: String, _ rightAlias: String) -> Self {
        let lhs = DBColumn(table: leftAlias, data.lhs).serialize()
        let rhs = DBColumn(table: rightAlias, data.rhs).serialize()

        self.filterAnd.append(DBRaw(lhs + data.op + rhs))
        return self
    }

    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition
    ///
    ///     .filter(p.name == "Earth")...
    ///
    /// - Parameters:
    ///   - data: The struct with source data for a binary expression.
    ///   - leftAlias: An alias for the left table, by default - the alias from the first table in `FROM`.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnBind, _ leftAlias: String? = nil) -> Self {
        let table = leftAlias ?? self.alias
        let lhs = DBColumn(table: table, data.lhs).serialize()

        self.filterAnd.append(DBRaw(lhs + data.op, [data.rhs]))
        return self
    }

    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition
    ///
    ///     .filter(p.name ~~ ["Earth", "Mars"])...
    ///
    /// - Parameters:
    ///   - data: The struct with source data for a binary expression.
    ///   - leftAlias: An alias for the left table, by default - the alias from the first table in `FROM`.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnBinds, _ leftAlias: String? = nil) -> Self {
        let table = leftAlias ?? self.alias
        let lhs = DBColumn(table: table, data.lhs).serialize()

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
    ///   - leftAlias: alias for the left table, by default - the alias from the first table in `FROM`.
    /// - Returns: `self` for chaining.
    public func filter(_ column: Column, _ custom: String, _ bind: Encodable, _ leftAlias: String? = nil) -> Self {
        let table = leftAlias ?? self.alias
        let lhs = DBColumn(table: table, column).serialize()

        self.filterAnd.append(DBRaw(lhs + " \(custom) ", [bind]))
        return self
    }

    // MARK: --- OR ---

    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition
    ///
    ///     .orFilter(p.name == p.otherField)...
    ///
    /// - Parameters:
    ///   - data: The struct with source data for a binary expression.
    ///   - leftAlias: An alias for left table.
    ///   - rightAlias: An alias for right table.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnColumn, _ leftAlias: String, _ rightAlias: String) -> Self {
        let lhs = DBColumn(table: leftAlias, data.lhs).serialize()
        let rhs = DBColumn(table: rightAlias, data.rhs).serialize()

        self.filterOr.append(DBRaw(lhs + data.op + rhs))
        return self
    }

    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition
    ///
    ///     .orFilter(p.name == "Earth")...
    ///
    /// - Parameters:
    ///   - data: The struct with source data for a binary expression.
    ///   - leftAlias: An alias for the left table, by default - the alias from the first table in `FROM`.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnBind, _ leftAlias: String? = nil) -> Self {
        let table = leftAlias ?? self.alias
        let lhs = DBColumn(table: table, data.lhs).serialize()

        self.filterOr.append(DBRaw(lhs + data.op, [data.rhs]))
        return self
    }

    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition
    ///
    ///     .orFilter(p.name ~~ ["Earth", "Mars"])...
    ///
    /// - Parameters:
    ///   - data: The struct with source data for a binary expression.
    ///   - leftAlias: An alias for the left table, by default - the alias from the first table in `FROM`.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnBinds, _ leftAlias: String? = nil) -> Self {
        let table = leftAlias ?? self.alias
        let lhs = DBColumn(table: table, data.lhs).serialize()

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
    ///   - leftAlias: An alias for the left table, by default - the alias from the first table in `FROM`.
    /// - Returns: `self` for chaining.
    public func orFilter(_ column: Column, _ custom: String, _ bind: Encodable, _ leftAlias: String? = nil) -> Self {
        let table = leftAlias ?? self.alias
        let lhs = DBColumn(table: table, column).serialize()

        self.filterOr.append(DBRaw(lhs + " \(custom) ", [bind]))
        return self
    }
}
