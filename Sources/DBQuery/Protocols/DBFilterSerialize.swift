//
//  DBFilterSerialize.swift
//  DBQuery
//
//  Created by Victor Chernykh on 07.09.2022.
//

public protocol DBFilterSerialize {
	var filters: [DBRaw] { get set }
}

extension DBFilterSerialize {
	func serializeFilter(source raw: DBRaw) -> DBRaw {
		var query = raw
		var j = query.binds.count

		for filter in filters {
			let binds = filter.binds
			if filter.sql.suffix(4) == " IN ", binds.isEmpty {
				continue
			}
			query.sql += filter.sql

			if binds.count > 0 {
				query.binds += binds
				if let type = filter.type {
					if binds.count == 1 {
						j += 1
						if query.sql.suffix(4) == " IN " {
							query.sql = String(query.sql.dropLast(3)) + "= "
						}
						query.sql += "$\(j)::\(type)"
					} else {
						query.sql += "("
						for _ in 0..<binds.count - 1 {
							j += 1
							query.sql += "$\(j)::\(type), "
						}
						j += 1
						query.sql += "$\(j)::\(type))"
					}
				} else {
					if binds.count == 1 {
						j += 1
						if query.sql.suffix(4) == " IN " {
							query.sql = String(query.sql.dropLast(3)) + "= "
						}
						query.sql += "$\(j)"

					} else if binds.count == 2, query.sql.hasSuffix("BETWEEN ") {
						j += 2
						query.sql += "$\(j - 1) AND $\(j)"

					} else {
						query.sql += "("
						for _ in 0..<binds.count - 1 {
							j += 1
							query.sql += "$\(j), "
						}
						j += 1
						query.sql += "$\(j))"
					}
				}
			}
		}

		return query
	}
}
