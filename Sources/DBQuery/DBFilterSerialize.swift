//
//  DBFilterSerialize.swift
//  DBQuery
//
//  Created by Victor Chernykh on 07.09.2022.
//

public protocol DBFilterSerialize {
	var filterAnd: [DBRaw] { get set }
	var filterOr: [DBRaw] { get set }
}

extension DBFilterSerialize {
	func serializeFilter(source raw: DBRaw) -> DBRaw {
		let rawAnd = serializeItem(source: raw, conjunction: .and)
		let rawOr = serializeItem(source: rawAnd, conjunction: .or)

		return rawOr
	}

	func serializeItem(source raw: DBRaw, conjunction: DBCondition) -> DBRaw {
		var secondFilter = false
		var query = raw
		query.sql += " "
		let filters: [DBRaw]
		if conjunction == .and {
			filters = self.filterAnd
		} else {
			filters = self.filterOr
			if self.filterAnd.count > 0 {
				secondFilter = true
				query.sql += "AND ("
			}
		}
		guard filters.count > 0 else { return raw }

		var j = query.binds.count
		let conj = conjunction.rawValue
		let last = filters.count - 1

		if last > 0 {
			for i in 0..<last {
				let binds = filters[i].binds
				let sql = filters[i].sql
				switch binds.count {
				case 0:
					query.sql += sql + conj
				case 1:
					if let val = binds[0] as? String,      // This for Database types
					   String(val.prefix(1)) == "\'",
					   String(val.suffix(1)) == "\'" {
						if sql.suffix(4) == " IN " {
							query.sql += "\(sql)(\(val)), "
						} else {
							query.sql += "\(sql)\(val), "
						}
						continue
					}
					query.binds += binds
					j += 1
					if sql.suffix(4) == " IN " {
						query.sql += sql + "($\(j))\(conj)"
					} else {
						query.sql += sql + "$\(j)\(conj)"
					}
				default:
					if let val = binds[0] as? String,      // This for Database types
					   String(val.prefix(1)) == "\'",
					   String(val.suffix(1)) == "\'" {
						let vals = binds.compactMap { $0 as? String }.joined(separator: ", ")
						query.sql += "\(filters[i].sql)(\(vals)), "
						continue
					}
					query.binds += binds
					query.sql += sql + "("
					for _ in 0..<binds.count - 1 {
						j += 1
						query.sql += "$\(j), "
					}
					j += 1
					query.sql += "$\(j))\(conj)"
				}
			}
		}
		let binds = filters[last].binds
		let sql = filters[last].sql
		switch binds.count {
		case 0:
			query.sql += sql
		case 1:
			if let val = binds[0] as? String,      // This for Database types
			   String(val.prefix(1)) == "\'",
			   String(val.suffix(1)) == "\'" {
				if sql.suffix(4) == " IN " {
					query.sql += "\(sql)(\(val))"
				} else {
					query.sql += "\(sql)\(val)"
				}
			} else {
				query.binds += binds
				j += 1
				if sql.suffix(4) == " IN " {
					query.sql += sql + "($\(j))"
				} else {
					query.sql += sql + "$\(j)"
				}
			}
		default:
			if let val = binds[0] as? String,      // This for Database types
			   String(val.prefix(1)) == "\'",
			   String(val.suffix(1)) == "\'" {
				let vals = binds.compactMap { $0 as? String }.joined(separator: ", ")
				query.sql += "\(sql)(\(vals))"
			} else {
				query.binds += binds
				query.sql += sql + "("
				for _ in 0..<binds.count - 1 {
					j += 1
					query.sql += "$\(j), "
				}
				j += 1
				query.sql += "$\(j))"
			}
		}
		if secondFilter {
			query.sql += ")"
		}

		return query
	}
}
