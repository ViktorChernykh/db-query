//
//  DBRaw.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct DBRaw {
	public  var sql: String
	public  var binds: [Encodable]

	public init(_ sql: String, _ binds: [Encodable] = []) {
		self.sql = sql
		self.binds = binds
	}
}
