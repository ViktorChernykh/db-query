//
//  DBTable.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct DBTable {
	public var table: String
	public var alias: String?

	public init(table: String, as alias: String? = nil) {
		self.table = table
		self.alias = alias
	}

	public func serialize() -> String {
		if let alias {
			return "\(col: table)" + " AS \(col: alias)"
		}
		return "\(col: table)"
	}
}
