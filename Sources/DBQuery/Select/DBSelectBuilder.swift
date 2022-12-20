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

	public let schema: String
	public let section: String
	public let alias: String

	public var with: [DBRaw] = []
	public var columns: [DBRaw] = []
	public var from: [String] = []
	public var filterAnd: [DBRaw] = []
	public var filterOr: [DBRaw] = []
	public var joins: [DBJoin] = []

	public var group: [String] = []
	public var having: [String] = []
	public var order: [String] = []
	public var limit: Int? = nil
	public var offset: Int? = nil
	public var distinct: [String]? = nil
	public var aggregate: DBAggregate? = nil
	public var isolation: SelectIsolation? = nil
	public var isWait: Bool = false

	// MARK: - Init
	public init(section: String, on database: SQLDatabase) {
		self.database = database
		self.schema = T.schema + section
		self.section = section
		self.alias = T.alias

		self.from.append(
			DBTable(table: T.schema + section, as: alias).serialize()
		)
	}

	/// Makes copy of SelectBuilder.
	/// - Returns: SelectBuilder.
	public func copy() -> DBSelectBuilder {
		let copy = DBSelectBuilder<T>(section: self.section, on: self.database)
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
		copy.distinct = self.distinct
		copy.aggregate = self.aggregate

		return copy
	}

	public func serialize() -> SQLRaw {
		var query = DBRaw("")

		if with.count > 0 {
			query.sql += "WITH "
			query.sql += with.map { $0.sql }.joined(separator: ", ") + " "
			query.binds += with.flatMap { $0.binds }
		}
		query.sql += "SELECT"

		if let distinct {
			if distinct.count == 0 {
				query.sql += " DISTINCT"
			} else {
				query.sql += " DISTINCT ON (\(distinct.joined(separator: ", "))))"
			}
		}

		var cols = ""
		if self.columns.count == 0 {
			cols = "\"\(self.alias)\".*"
		} else {
			cols = self.columns.map { $0.sql }.joined(separator: ", ")
			query.binds += self.columns.flatMap { $0.binds }
		}

		if let aggregate {
			switch aggregate {
			case .avg:
				query.sql += " avg(\(cols))"
			case .count:
				query.sql += " count(\(cols))"
			case .max:
				query.sql += " max(\(cols))"
			case .min:
				query.sql += " min(\(cols))"
			case .sum:
				query.sql += " sum(\(cols))"
			}
		} else {
			query.sql += " " + cols
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
		if let isolation {
			query.sql += "FOR \(isolation.rawValue)"
			if self.isWait {
				query.sql += " NOWAIT"
			}
		}
		query.sql += ";"
#if DEBUG
		print(query.sql)
#endif
		return SQLRaw(query.sql, query.binds)
	}
}
