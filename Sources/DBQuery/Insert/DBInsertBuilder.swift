//
//  DBInsertBuilder.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

import SQLKit

public final class DBInsertBuilder<T: DBModel>: DBQueryFetcher {
    // MARK: Stored properties
    /// See `DBQueryFetcher`.
    public var database: SQLDatabase

    public let space: String?
    public let schema: String
    public let section: String
    public let alias: String

    public var with: DBRaw? = nil
    public var inserts: [DBInsert] = []
    public var columns: [String] = []
    public var returning: [String] = []

    // MARK: Init
    public init(space: String? = nil, section: String, on database: SQLDatabase) {
        self.database = database
        self.space = space
        self.schema = T.schema + section
        self.section = section
        self.alias = T.alias
    }

    public func serialize() -> SQLRaw {
        var query = DBRaw("")

        if let with = self.with {
            query.sql += "WITH " + with.sql + " "
            query.binds += with.binds
        }
        var j = query.binds.count

        let table = DBTable(self.space, table: self.schema, as: self.alias).serialize()
        query.sql += "INSERT INTO \(table)"

        if self.columns.count > 0 {
            query.sql += " (\(self.columns.joined(separator: ", ")))"
        }
        query.sql += " VALUES "

        var lines = [String]()
        for insert in inserts {
            var items = [String]()
            for value in insert.values {
                if let val = value as? String,      // This for Database types
                    String(val.prefix(1)) == "\'",
                    String(val.suffix(1)) == "\'" {
                    items.append(val)
                } else {
                    j += 1
                    items.append("$\(j)")
                    query.binds.append(value)
                }
            }
            lines.append("(" + items.joined(separator: ", ") + ")")
        }
        query.sql += lines.joined(separator: ", ")

        if self.returning.count > 0 {
            query.sql += " RETURNING " + self.returning.joined(separator: ", ")
        }
        query.sql += ";"
#if DEBUG
        print(query.sql)
#endif
        return SQLRaw(query.sql, query.binds)
    }
}
