//
//  DBDeleteBuilder+Predicate.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

extension DBDeleteBuilder {
    // MARK: - AND -
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .filter(p.name == p.otherField)...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnColumn) -> Self {
        let lhs = DBColumn(table: self.alias, data.lhs).serialize()
        let rhs = DBColumn(table: self.alias, data.rhs).serialize()
        
        self.filterAnd.append(DBRaw(lhs + data.op + rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .filter(p.name == "Earth")...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnBind) -> Self {
        let lhs = DBColumn(table: self.alias, data.lhs).serialize()
        
        self.filterAnd.append(DBRaw(lhs + data.op, [data.rhs]))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .filter(p.name ~~ ["Earth", "Mars"])...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func filter(_ data: ColumnBinds) -> Self {
        let lhs = DBColumn(table: self.alias, data.lhs).serialize()
        
        self.filterAnd.append(DBRaw(lhs + data.op, data.rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .filter(p.name, "ILIKE", "%\(name)%")...
    ///
    /// - Parameters:
    ///   - column: The left values of the condition.
    ///   - custom: A custom operation for a binary expression.
    ///   - bind: The right value of the condition.
    /// - Returns: `self` for chaining.
    public func filter(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
        let lhs = DBColumn(table: self.alias, column).serialize()
        
        self.filterAnd.append(DBRaw(lhs + " \(custom) ", [bind]))
        return self
    }
    
    // MARK: - OR -
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .orFilter(p.name == p.otherField)...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnColumn) -> Self {
        let lhs = DBColumn(table: self.alias, data.lhs).serialize()
        let rhs = DBColumn(table: self.alias, data.rhs).serialize()
        
        self.filterOr.append(DBRaw(lhs + data.op + rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .orFilter(p.name == "Earth")...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnBind) -> Self {
        let lhs = DBColumn(table: self.alias, data.lhs).serialize()
        
        self.filterOr.append(DBRaw(lhs + data.op, [data.rhs]))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .orFilter(p.name ~~ ["Earth", "Mars"])...
    ///
    /// - Parameter data: The struct with source data for a binary expression.
    /// - Returns: `self` for chaining.
    public func orFilter(_ data: ColumnBinds) -> Self {
        let lhs = DBColumn(table: self.alias, data.lhs).serialize()
        
        self.filterOr.append(DBRaw(lhs + data.op, data.rhs))
        return self
    }
    
    @discardableResult
    /// Creates binary expression from struct with source data to `WHERE` condition.
    ///
    ///     typealias p = Planet.v1
    ///     let query = Planet.select( )
    ///     .orFilter(p.name, "ILIKE", "%\(name)%")...
    ///
    /// - Parameters:
    ///   - column: The left values of the condition.
    ///   - custom: A custom operation for a binary expression.
    ///   - bind: The right value of the condition.
    /// - Returns: `self` for chaining.
    public func orFilter(_ column: Column, _ custom: String, _ bind: Encodable) -> Self {
        let lhs = DBColumn(table: self.alias, column).serialize()
        
        self.filterOr.append(DBRaw(lhs + " \(custom) ", [bind]))
        return self
    }
}
