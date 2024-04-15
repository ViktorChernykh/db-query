//
//  Raw.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct Raw {
	public var sql: String
	public var binds: [Encodable]
	public var type: String?

	public init(_ sql: String, _ binds: [Encodable] = [], as type: String? = nil) {
		self.sql = sql
		self.binds = binds
		self.type = type
	}
}
