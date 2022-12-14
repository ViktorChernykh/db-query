//
//  DBDeleteBuilder.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

import SQLKit

public final class DBDeleteBuilder<T: DBModel>: DBQueryFetcher, DBFilterSerialize {
	// MARK: Stored properties
	/// See `DBQueryFetcher`.
	public var database: SQLDatabase

	public let space: String?
	public let schema: String
	public let section: String
	public let alias: String

	public var with: DBRaw? = nil
	public var from: String = ""
	public var using: [String] = []
	public var cursor: String? = nil
	public var filterAnd: [DBRaw] = []
	public var filterOr: [DBRaw] = []
	public var returning: [String] = []

	// MARK: Init
	public init(space: String? = nil, section: String, on database: SQLDatabase) {
		self.database = database
		self.space = space
		self.schema = T.schema + section
		self.section = section
		self.alias = T.alias

		self.from = DBTable(space, table: self.schema, as: self.alias)
			.serialize()
	}

	public func serialize() -> SQLRaw {
		var query = DBRaw("")

		if let with = self.with {
			query.sql += "WITH " + with.sql + " "
			query.binds += with.binds
		}
		query.sql += "DELETE FROM " + self.from

		if self.using.count > 0 {
			query.sql += " USING " + self.using.joined(separator: ", ")
		}

		if let cursor = self.cursor {
			query.sql += " WHERE CURRENT OF \(cursor)"
		} else {
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
