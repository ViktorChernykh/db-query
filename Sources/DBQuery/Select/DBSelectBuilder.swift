//
//  DBSelectBuilder.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

import SQLKit

public final class DBSelectBuilder<T: DBModel>: DBFilterSerialize {
    
    // MARK: Stored properties
    /// See `DBQueryFetcher`.
    public var database: SQLDatabase
    
    public let space: String?
    public let schema: String
    public let section: String
    public let alias: String
    
    public var with: DBRaw? = nil
    public var columns: [String] = []
    public var from: [String] = []
    public var filterAnd: [DBRaw] = []
    public var filterOr: [DBRaw] = []
    public var joins: [DBJoin] = []
    
    public var group: [String] = []
    public var having: [String] = []
    public var order: [String] = []
    public var limit: Int? = nil
    public var offset: Int? = nil
    public var isDistinct: Bool = false
    public var aggregate: DBAggregate? = nil
    
    // MARK: - Init
    public init(space: String? = nil, section: String, on database: SQLDatabase) {
        self.database = database
        self.space = space
        self.schema = T.schema + section
        self.section = section
        self.alias = T.alias
        
        self.from.append(
            DBTable(space, table: T.schema + section, as: alias).serialize()
        )
    }
    
    /// Makes copy of SelectBuilder.
    /// - Returns: SelectBuilder.
    public func copy() -> DBSelectBuilder {
        let copy = DBSelectBuilder<T>(space: self.space, section: self.section, on: self.database)
        copy.with = self.with
        copy.columns = self.columns
        copy.from = self.from
        copy.filterAnd = self.filterAnd
        copy.filterOr = self.filterOr
        copy.joins = self.joins
        
        copy.group = self.group
        copy.having = self.having
        copy.order = self.order
        copy.limit = self.limit
        copy.offset = self.offset
        copy.isDistinct = self.isDistinct
        copy.aggregate = self.aggregate
        
        return copy
    }
    
    public func serialize() -> SQLRaw {
        var query = DBRaw("")
        
        if let with = self.with {
            query.sql += "WITH " + with.sql + " "
            query.binds += with.binds
        }
        query.sql += "SELECT "
        var cols = ""
        if self.columns.count == 0 {
            cols = "\"\(self.alias)\".*"
        } else {
            cols = self.columns.joined(separator: ", ")
        }
        
        if isDistinct {
            cols = "DISTINCT ON (\(cols))"
        }
                    
        if let aggregate = self.aggregate {
            switch aggregate {
            case .avg:
                query.sql += "avg(\(cols))"
            case .count:
                query.sql += "count(\(cols))"
            case .max:
                query.sql += "max(\(cols))"
            case .min:
                query.sql += "min(\(cols))"
            case .sum:
                query.sql += "sum(\(cols))"
            }
        } else {
            query.sql += cols
        }
        
        query.sql += " FROM " + self.from.joined(separator: ", ")
        
        for join in joins {
            query = join.serialize(source: query)
        }
        if (self.filterAnd.count + self.filterOr.count) > 0 {
            query.sql += " WHERE"
            query = serializeFilter(source: query)
        }
        
        if self.group.count > 0 {
            query.sql += " GROUP BY " + self.group.joined(separator: ", ")
        }
        if self.having.count > 0 {
            query.sql += " HAVING " + self.having.joined(separator: ", ")
        }
        if self.order.count > 0 {
            query.sql += " ORDER BY " + self.order.joined(separator: ", ")
        }
        if let limit = self.limit {
            query.sql += " LIMIT \(limit)"
        }
        if let offset = self.offset {
            query.sql += " OFFSET \(offset)"
        }
        query.sql += ";"
#if DEBUG
        print(query.sql)
#endif
        return SQLRaw(query.sql, query.binds)
    }
}
