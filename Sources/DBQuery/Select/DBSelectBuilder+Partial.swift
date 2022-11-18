//
//  DBSelectBuilder+Partial.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

extension DBSelectBuilder {

    @discardableResult
    /// Sets the distinct value to true for serializing.
    /// - Parameters:
    ///   - columns: List of columns for distinct.
    ///   - alterAlias: alias for columns, by default - the alias from the first table in `FROM`.
    /// - Returns: `self` for chaining.
    public func distinct(on columns: Column..., as alterAlias: String? = nil) -> Self {
        self.isDistinct = true
        let alias = alterAlias ?? self.alias
        self.columns = columns.map {
            DBColumn(table: alias, $0).serialize()
        }
        return self
    }

    @discardableResult
    /// Adds a `LIMIT` clause to the query. If called more than once, the last call wins.
    ///
    /// - Parameter max: Maximum limit.
    /// - Returns: `self` for chaining.
    public func limit(_ max: Int) -> Self {
        self.limit = max
        return self
    }

    @discardableResult
    /// Adds a `OFFSET` clause to the query. If called more than once, the last call wins.
    ///
    /// - Parameter n: Offset.
    /// - Returns: `self` for chaining.
    public func offset(_ n: Int) -> Self {
        self.offset = n
        return self
    }
}
