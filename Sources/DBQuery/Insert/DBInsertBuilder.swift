//
//  DBInsertBuilder.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

import SQLKit

public final class DBInsertBuilder<T: DBModel>: DBQueryFetcher, DBFilterSerialize, DBPredicateForInsertUpdate {
	// MARK: Stored properties
	/// See `DBQueryFetcher`.
	public var database: SQLDatabase

	public let schema: String
	public let section: String
	public let alias: String

	public var with: [DBRaw] = []
	public var inserts: [DBInsert] = []
	public var columns: [String] = []

	public var filters: [DBRaw] = []
	public var onConflict: [String]? = nil
	public var setsForUpdate: [DBRaw] = []
	public var isDoNothing = false

	public var returning: [String] = []

	// MARK: Init
	public init(section: String, on database: SQLDatabase) {
		self.database = database
		self.schema = T.schema + section
		self.section = section
		self.alias = T.alias
	}

	public func serialize() -> SQLRaw {
		var query = DBRaw("")

		if with.count > 0 {
			query.sql += "WITH "
			query.sql += with.map { $0.sql }.joined(separator: ", ") + " "
			for item in with {
				query.binds += item.binds
			}
		}
		var j = query.binds.count

		let table = DBTable(table: self.schema, as: self.alias).serialize()
		query.sql += "INSERT INTO \(table)"

		if self.columns.count > 0 {
			query.sql += " (\(self.columns.joined(separator: ", ")))"
		}
		query.sql += " VALUES "

		var lines = [String]()
		for insert in inserts {
			var items = [String]()
			for value in insert.values {
				j += 1
				if let type = value.type {
					items.append("$\(j)::\(type)")
				} else {
					items.append("$\(j)")
				}
				query.binds.append(value.value)
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

				for set in setsForUpdate {
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
		return SQLRaw(query.sql, query.binds)
	}
}
