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
        self.with = sql

        return self
    }

    @discardableResult
    /// Sets list of table's column names.
    ///
    /// - Parameter fields: The list of table columns.
    /// - Returns: `self` for chaining.
    public func fields(_ fields: Column...) -> Self {
        self.columns += fields.map {
            DBColumn(table: self.alias, $0).serialize()
        }
        return self
    }

    @discardableResult
    /// Add values for the `set()`.
    ///
    /// - Parameter values: The list of values must be equal columns count.
    /// - Returns: self` for chaining.
    public func values(_ values: Encodable...) -> Self {
        self.inserts.append(DBInsert(values: values))

        return self
    }

    @discardableResult
    /// Sets a list of table columns to returning from the sql request.
    ///
    /// - Parameters:
    ///   - fields: The list of table's column name.
    /// - Returns: `self` for chaining.
    public func returning(_ fields: Column...) -> Self {
        self.returning = fields.map {
            DBColumn(table: self.alias, $0).serialize()
        }
        return self
    }

    @discardableResult
    /// Reset values for the next `INSERT`.
    ///
    /// - Returns: `self` for chaining.
    public func resetValues() -> Self {
        self.inserts = []

        return self
    }
}
