//
//  DBColumn.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct DBColumn {
	public var table: String?
	public var column: String
	public var alias: String?

	public init(table: String?, _ column: String, alias: String? = nil) {
		self.table = table
		self.column = column
		self.alias = alias
	}

	public init(_ column: Column, alias: String? = nil) {
		self.table = column.table
		self.column = column.key
		self.alias = alias
	}

	public func serialize() -> String {
		let table = table == nil ? "" : "\"\(table!)\"."
		let alias = alias == nil ? "" : " AS \(alias!)"

		return table + "\"\(column)\"" + alias
	}
}
