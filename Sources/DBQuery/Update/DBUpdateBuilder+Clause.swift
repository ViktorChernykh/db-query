//
//  DBUpdateBuilder+Clause.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

extension DBUpdateBuilder {
    
    // MARK: - WITH
    @discardableResult
    /// Adds the raw `with` subquery to the select query.
    ///
    /// - Parameter sql: raw `with` query
    /// - Returns: `self` for chaining.
    public func with(_ sql: DBRaw) -> Self {
        self.with = sql
        
        return self
    }
    
    @discardableResult
    /// Sets the cursor's name.
    ///
    /// - Parameter name: The name of cursor.
    /// - Returns: `self` for chaining.
    public func cursor(_ name: String) -> Self {
        self.cursor = name
        
        return self
    }
    
    @discardableResult
    /// Sets a list of table columns to returning from the sql request.
    /// 
    /// - Parameter fields: The list of table column names.
    /// - Returns: `self` for chaining.
    public func returning(_ fields: Column...) -> Self {
        self.returning = fields.map {
            DBColumn(table: alias, $0).serialize()
        }
        return self
    }
}
