//
//  DBInsertBuilder.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

import SQLKit

public final class DBInsertBuilder<T: DBModel>: DBQueryFetcher, DBFilterSerialize {
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

    public var filterAnd: [DBRaw] = []
    public var filterOr: [DBRaw] = []
    public var onConflict: [String]? = nil
    public var setsForUpdate: [DBRaw] = []
    public var isDoNothing = false

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

        if let onConflict {
            query.sql += " ON CONFLICT(\(onConflict.joined(separator: ", ")))"

            if isDoNothing {
                query.sql += " DO NOTHING"
            } else {
                query.sql += " DO UPDATE SET "

                for sets in setsForUpdate {
                    let binds = sets.binds
                    switch binds.count {
                    case 0:
                        query.sql += sets.sql + ", "
                    case 1:
                        if let val = binds[0] as? String,      // This for Database types
                           String(val.prefix(1)) == "\'",
                           String(val.suffix(1)) == "\'" {
                            if sql.suffix(4) == " IN " {
                                query.sql += "\(sets.sql)(\(val)), "
                            } else {
                                query.sql += "\(sets.sql)\(val), "
                            }
                            continue
                        }
                        query.binds += binds
                        j += 1
                        query.sql += sets.sql + "$\(j), "
                    default:
                        query.binds += binds
                        query.sql += sets.sql + "("
                        for _ in binds {
                            j += 1
                            query.sql += "$\(j), "
                        }
                        query.sql = String(query.sql.dropLast(2)) + "), "
                    }
                }
                query.sql = String(query.sql.dropLast(2))
            }

            if (self.filterAnd.count + self.filterOr.count) > 0 {
                query.sql += " WHERE"
                query = serializeFilter(source: query)
            }
        }

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
