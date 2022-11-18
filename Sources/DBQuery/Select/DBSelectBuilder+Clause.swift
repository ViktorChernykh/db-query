//
//  DBSelectBuilder+Clause.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

import SQLKit

extension DBSelectBuilder {

    // MARK: - WITH
    @discardableResult
    /// Adds the raw `with` subquery to the select query.
    ///
    /// - Parameter sql: DBRaw `with` query.
    /// - Returns: `self` for chaining.
    public func with(_ sql: DBRaw) -> Self {
        self.with = sql

        return self
    }

    // MARK: - FROM
    @discardableResult
    /// Adds a foreign table name.
    ///
    /// - Parameters:
    ///   - model: Model's type for query.
    ///   - tableAlias: An alternative alias of the name for the external table, default the alias of the base table.
    /// - Returns: `self` for chaining.
    public func from<F: DBModel>(_ model: F.Type, as tableAlias: String? = nil) -> Self {
        let alias = tableAlias ?? model.alias
        let schema = DBTable(table: model.schema + self.section, as: alias)
        self.from.append(schema.serialize())

        return self
    }

    // MARK: - WHERE
    @discardableResult
    /// Specify the column to be part of the result set of the query.
    ///
    /// - Returns: `self` for chaining.
    public func fields() -> Self {
        self.columns = ["\"\(self.alias)\".*"]

        return self
    }
    @discardableResult
    /// Specify the column to be part of the result set of the query.
    ///
    /// - Parameters:
    ///   - column: The name of the column.
    ///   - columnAlias: An alias for the column name.
    ///   - tableAlias: An alternative alias of the name for the external table, default the alias of the base table.
    /// - Returns: `self` for chaining.
    public func field(_ column: Column, alias columnAlias: String? = nil, as tableAlias: String? = nil) -> Self {
        let table: String
        if let tableAlias = tableAlias {
            table = tableAlias
        } else if let last = currentJoin() {
            table = self.joins[last].alias
        } else {
            table = self.alias
            if self.columns.count == 1, self.columns[0] == "\"\(self.alias)\".*" {
                self.columns = []
            }
        }

        let col = DBColumn(table: table, column, alias: columnAlias).serialize()
        self.columns.append(col)

        return self
    }

    @discardableResult
    /// Specify the columns to be part of the result set of the query.
    ///
    /// - Parameters:
    ///   - columns: The list of the column names.
    ///   - tableAlias: An alternative alias of the name for the external table, default the alias of the base table.
    /// - Returns: `self` for chaining.
    public func fields(_ columns: Column..., as tableAlias: String? = nil) -> Self {
        let table: String
        if let tableAlias = tableAlias {
            table = tableAlias
        } else if let last = currentJoin() {
            table = self.joins[last].alias
        } else {
            table = self.alias
            if self.columns.count == 1, self.columns[0] == "\"\(self.alias)\".*" {
                self.columns = []
            }
        }

        self.columns += columns.map {
            DBColumn(table: table, $0).serialize()
        }

        return self
    }

    /// Count the number of initiated Joins. If the number is 0, throws a fatal error.
    ///
    /// - Returns: Number of initiated Joins.
    private func currentJoin() -> Int? {
        let count = self.joins.count
        if count > 0 {
            return count - 1
        }
        return nil
    }
}

// MARK: - GROUP BY / ORDER BY
extension DBSelectBuilder {

    @discardableResult
    /// Adds a `GROUP BY` clause to the query with the specified column.
    ///
    /// - Parameters:
    ///   - columns: Name of columns to group results by.
    ///   - tableAlias: An alternative alias of the name for the external table, default the alias of the base table.
    /// - Returns: `self` for chaining.
    public func groupBy(_ columns: Column..., as tableAlias: String? = nil) -> Self {
        let table = tableAlias ?? self.alias
        let fields = columns.map {
            DBColumn(table: table, $0).serialize()
        }
        self.group += fields
        return self
    }

    @discardableResult
    /// Adds an `ORDER BY` clause to the query with the specified column and ordering.
    ///
    /// - Parameters:
    ///   - columns: Name of columns to sort results by.
    ///   - tableAlias: An alternative alias of the name for the external table, default the alias of the base table.
    ///   - direction: The sort direction for the column.
    /// - Returns: `self` for chaining.
    public func sort(_ columns: Column..., as tableAlias: String? = nil, direct: DBDirection = .asc) -> Self {
        let table = tableAlias ?? self.alias
        let fields = columns.map {
            DBColumn(table: table, $0).serialize() + direct.serialize()
        }
        self.order += fields

        return self
    }
}

// MARK: - AGGREGATE
extension DBSelectBuilder {
    public func avg(_ columns: Column..., as tableAlias: String? = nil) async throws -> Int {
        self.aggregate = .avg
        guard let row = try await aggreg(columns, as: tableAlias) else {
            return 0
        }

        return try row.decode(column: "avg", as: Int.self)
    }

    public func count(_ columns: Column..., as tableAlias: String? = nil) async throws -> Int {
        self.aggregate = .count
        self.limit = nil
        guard let row = try await aggreg(columns, as: tableAlias) else {
            return 0
        }

        return try row.decode(column: "count", as: Int.self)
    }

    public func maximum(_ columns: Column..., as tableAlias: String? = nil) async throws -> Double {
        self.aggregate = .max
        guard let row = try await aggreg(columns, as: tableAlias) else {
            return 0
        }

        return try row.decode(column: "max", as: Double.self)
    }

    public func minimum(_ columns: Column..., as tableAlias: String? = nil) async throws -> Double {
        self.aggregate = .min
        guard let row = try await aggreg(columns, as: tableAlias) else {
            return 0
        }

        return try row.decode(column: "min", as: Double.self)
    }

    public func sum(_ columns: Column..., as tableAlias: String? = nil) async throws -> Double {
        self.aggregate = .sum
        guard let row = try await aggreg(columns, as: tableAlias) else {
            return 0.0
        }

        return try row.decode(column: "sum", as: Double.self)
    }

    private func aggreg(_ columns: [Column], as tableAlias: String?) async throws -> SQLRow? {
        let alias = tableAlias ?? self.alias
        if columns.count > 0 {
            self.columns = columns.map {
                DBColumn(table: alias, $0).serialize()
            }
        } else {
            self.columns = ["\"\(alias)\".*"]
        }

        return try await self.first(limit: nil).get()
    }
}
