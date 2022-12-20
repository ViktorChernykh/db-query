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

	public let schema: String
	public let alias: String
	public let section: String

	public var with: [DBRaw] = []
	public var from: String = ""
	public var using: [String] = []
	public var cursor: String? = nil
	public var filterAnd: [DBRaw] = []
	public var filterOr: [DBRaw] = []
	public var returning: [String] = []

	// MARK: Init
	public init(section: String, on database: SQLDatabase) {
		self.database = database
		self.schema = T.schema + section
		self.alias = T.alias
		self.section = section

		self.from = DBTable(table: self.schema, as: self.alias)
			.serialize()
	}

	public func serialize(end: String = "") -> SQLRaw {
		var query = DBRaw("")

		if with.count > 0 {
			query.sql += "WITH "
			query.sql += with.map { $0.sql }.joined(separator: ", ") + " "
			for item in with {
				query.binds += item.binds
			}
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
		query.sql += end

		return SQLRaw(query.sql, query.binds)
	}
}
