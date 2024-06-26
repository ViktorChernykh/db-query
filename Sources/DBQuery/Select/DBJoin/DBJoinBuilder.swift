//
//  DBJoin.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

public struct DBJoin: DBFilterSerialize {
	// MARK: Stored properties
	public var alias: String
	public var from: String
	public var method: DBJoinMethod
	public var filters: [Raw] = []

	// MARK: - Init
	public init(
		alias: String,
		from: String,
		method: DBJoinMethod
	) {
		self.alias = alias
		self.from = from
		self.method = method
	}

	func serialize(source raw: Raw) -> Raw {
		var joinRaw = Raw(
			raw.sql + self.method.serialize() + "JOIN " + self.from,
			raw.binds
		)
		if self.filters.count > 0 {
			joinRaw.sql += " ON "
			return serializeFilter(source: joinRaw)
		}
		return joinRaw
	}
}
