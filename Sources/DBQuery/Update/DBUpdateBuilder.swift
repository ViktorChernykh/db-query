//
//  DBUpdateBuilder.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

import SQLKit

public final class DBUpdateBuilder<T: DBModel>: DBQueryFetcher, DBFilterSerialize {
	// MARK: Stored properties
	/// See `DBQueryFetcher`.
	public var database: SQLDatabase

	public let schema: String
	public let section: String
	public let alias: String

	public var with: [DBRaw] = []
	public var update: String = ""
	public var sets: [DBRaw] = []
	public var from: [String] = []
	public var cursor: String? = nil
	public var filterAnd: [DBRaw] = []
	public var filterOr: [DBRaw] = []
	public var returning: [String] = []

	// MARK: - Init
	public init(section: String, on database: SQLDatabase) {
		self.database = database
		self.schema = T.schema + section
		self.section = section
		self.alias = T.alias

		self.update.append(
			DBTable(table: T.schema + section).serialize()
		)
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
		query.sql += "UPDATE " + self.update
		var j = query.binds.count

		if sets.count > 0 {
			query.sql += " SET "
			let last = sets.count - 1
			if last > 0 {
				for i in 0..<last {
					let binds = sets[i].binds
					switch binds.count {
					case 0:
						query.sql += sets[i].sql + ", "
					case 1:
						if let val = binds[0] as? String,      // This for Database types
						   String(val.prefix(1)) == "\'",
						   String(val.suffix(1)) == "\'" {
							query.sql += "\(sets[i].sql)\(val), "
							continue
						}
						query.binds += binds
						j += 1
						query.sql += sets[i].sql + "$\(j), "
					default:
						if let val = binds[0] as? String,      // This for Database types
						   String(val.prefix(1)) == "\'",
						   String(val.suffix(1)) == "\'" {
							let vals = binds.compactMap { $0 as? String }.joined(separator: ", ")
							query.sql += "\(sets[i].sql)(\(vals)), "
							continue
						}
						query.binds += binds
						query.sql += sets[i].sql + "("
						for _ in 0..<binds.count - 1 {
							j += 1
							query.sql += "$\(j), "
						}
						j += 1
						query.sql += "$\(j)), "
					}
				}
			}
			let binds = sets[last].binds
			switch binds.count {
			case 0:
				query.sql += sets[last].sql
			case 1:
				if let val = binds[0] as? String,      // This for Database types
				   String(val.prefix(1)) == "\'",
				   String(val.suffix(1)) == "\'" {
					query.sql += "\(sets[last].sql)\(val)"
				} else {
					query.binds += binds
					j += 1
					query.sql += sets[last].sql + "$\(j)"
				}
			default:
				if let val = binds[0] as? String,      // This for Database types
				   String(val.prefix(1)) == "\'",
				   String(val.suffix(1)) == "\'" {
					let vals = binds.compactMap { $0 as? String }.joined(separator: ", ")
					query.sql += "\(sets[last].sql)(\(vals))"
				} else {
					query.binds += binds
					query.sql += sets[last].sql + "("
					for _ in 0..<binds.count - 1 {
						j += 1
						query.sql += "$\(j), "
					}
					j += 1
					query.sql += "$\(j))"
				}
			}
		}

		if self.from.count > 0 {
			query.sql += " FROM " + self.from.joined(separator: ", ")
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
#if DEBUG
		print(query.sql)
#endif
		return SQLRaw(query.sql, query.binds)
	}
}
