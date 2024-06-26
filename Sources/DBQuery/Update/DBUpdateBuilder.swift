//
//  DBUpdateBuilder.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

import SQLKit

public final class DBUpdateBuilder<T: DBModel>: DBQueryFetcher, DBFilterSerialize, DBPredicateForInsertUpdate {
	// MARK: Stored properties
	/// See `DBQueryFetcher`.
	public var database: SQLDatabase

	public let schema: String
	public let section: String
	public let alias: String

	public var with: [Raw] = []
	public var update: String
	public var sets: [Raw] = []
	public var from: [String] = []
	public var cursor: String? = nil
	public var filters: [Raw] = []
	public var returning: [String] = []

	// MARK: - Init
	public init(section: String, on database: SQLDatabase) {
		self.database = database
		self.schema = T.schema + section
		self.section = section
		self.alias = T.alias
		self.update = "UPDATE " + DBTable(table: T.schema + section).serialize()
	}

	public func serialize() -> DBRaw {
		var query = Raw("")

		if with.count > 0 {
			query.sql += "WITH "
			query.sql += with.map { $0.sql }.joined(separator: ", ") + " "
			for item in with {
				query.binds += item.binds
			}
		}
		query.sql += self.update
		var j = query.binds.count

		if sets.count > 0 {
			query.sql += " SET "
			for set in sets {
				query.sql += set.sql
				let count = set.binds.count
				if count == 0 {
					query.sql += ", "
				} else {
					query.binds += set.binds
					j += 1
					if let type = set.type {
						query.sql += "$\(j)::\(type), "
					} else {
						query.sql += "$\(j), "
					}
				}
			}
			query.sql = String(query.sql.dropLast(2))
		}

		if self.from.count > 0 {
			query.sql += " FROM " + self.from.joined(separator: ", ")
		}

		if let cursor = self.cursor {
			query.sql += " WHERE CURRENT OF \(cursor)"
		} else {
			if self.filters.count > 0 {
				query.sql += " WHERE "
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
		return DBRaw(query.sql, query.binds)
	}
}
