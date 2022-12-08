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
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func set(_ data: ColumnBind) -> Self {
        let lhs = DBColumn(table: nil, data.lhs).serialize()
        self.sets.append(DBRaw(lhs + data.op, [data.rhs]))

        return self
    }

    @discardableResult
    /// Adds value to the `SET` operator.
    ///
    /// - Parameters:
    ///    - field: column to set
    ///    - rhs: value for set
    /// - Returns: `self` for chaining.
    public func set<T: Encodable>(_ field: Column, to rhs: T) -> Self {
        let lhs = DBColumn(table: nil, field).serialize()
        self.sets.append(DBRaw(lhs + " = ", [rhs]))

        return self
    }

    @discardableResult
    /// Adds value to the `SET` operator.
    ///
    /// - Parameters:
    ///    - field: column to set
    ///    - rhs: value for set
    /// - Returns: `self` for chaining.
    public func set<T: Encodable>(_ field: Column, plus rhs: T) -> Self {
        let lhs = DBColumn(table: nil, field).serialize()
        self.sets.append(DBRaw(lhs + " = " + lhs + " + ", [rhs]))

        return self
    }

    @discardableResult
    /// Adds value to the `SET` operator for update.
    ///
    /// - Parameters:
    ///    - field: column to set
    ///    - rhs: value for set
    /// - Returns: `self` for chaining.
    public func set<T: Encodable>(_ field: Column, minus rhs: T) -> Self {
        let lhs = DBColumn(table: nil, field).serialize()
        self.sets.append(DBRaw(lhs + " = " + lhs + " - ", [rhs]))

        return self
    }
}
