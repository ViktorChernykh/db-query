//
//  DBUpdateBuilder+Predicate.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

extension DBUpdateBuilder {
    // MARK: --- AND ---
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .filter(p.name == p.otherField)...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnColumn) -> Self {
        let lhs = DBColumn(table: nil, data.lhs).serialize()
        let rhs = DBColumn(table: nil, data.rhs).serialize()
        self.filterAnd.append(DBRaw(lhs + data.op + rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .filter(p.name == "Earth")...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnBind) -> Self {
        let lhs = DBColumn(table: nil, data.lhs).serialize()
        self.filterAnd.append(DBRaw(lhs + data.op, [data.rhs]))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .filter(p.name ~~ ["Earth", "Mars"])...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnBinds) -> Self {
        let lhs = DBColumn(table: nil, data.lhs).serialize()
        self.filterAnd.append(DBRaw(lhs + data.op, data.rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .filter(p.name, "ILIKE", "%\(name)%")...
    ///
    /// - Parameters:
    ///   - column: The left values of the condition.
    ///   - custom: A custom operation for a binary expression.
    ///   - bind: The right value of the condition.
    /// - Returns: `self` for chaining.
    public func filter(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
        let lhs = DBColumn(table: nil, column).serialize()
        self.filterAnd.append(DBRaw(lhs + " \(custom) ", [bind]))
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
        let lhs = DBColumn(table: nil, column).serialize()
        self.filterAnd.append(DBRaw(lhs + " \(custom) ", binds))
        return self
    }
    
    // MARK: --- OR ---
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .orFilter(p.name == p.otherField)...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnColumn) -> Self {
        let lhs = DBColumn(table: nil, data.lhs).serialize()
        let rhs = DBColumn(table: nil, data.rhs).serialize()
        
        self.filterOr.append(DBRaw(lhs + data.op + rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .orFilter(p.name == "Earth")...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnBind) -> Self {
        let lhs = DBColumn(table: nil, data.lhs).serialize()
        self.filterOr.append(DBRaw(lhs + data.op, [data.rhs]))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .orFilter(p.name ~~ ["Earth", "Mars"])...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnBinds) -> Self {
        let lhs = DBColumn(table: nil, data.lhs).serialize()
        self.filterOr.append(DBRaw(lhs + data.op, data.rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .orFilter(p.name, "ILIKE", "%\(name)%")...
    ///
    /// - Parameters:
    ///   - column: The left values of the condition.
    ///   - custom: A custom operation for a binary expression.
    ///   - bind: The right value of the condition.
    /// - Returns: `self` for chaining.
    public func orFilter(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
        let lhs = DBColumn(table: nil, column).serialize()
        self.filterOr.append(DBRaw(lhs + " \(custom) ", [bind]))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     .orFilter(p.name, "ILIKE", ["%\(name)%"])...
    ///
    /// - Parameters:
    ///   - column: The left values of the condition.
    ///   - custom: A custom operation for a binary expression.
    ///   - binds: The right values of the condition.
    /// - Returns: `self` for chaining.
    public func orFilter(_ column: Column, _ custom: String, _ binds: [Encodable]) -> Self {
        let lhs = DBColumn(table: nil, column).serialize()
        self.filterOr.append(DBRaw(lhs + " \(custom) ", binds))
        return self
    }
}
