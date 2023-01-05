//
//  DBColumn.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct DBColumn {
	public var table: String?
	public var column: String
	public var columnAlias: String?

	public init(table: String?, _ column: String, as columnAlias: String? = nil) {
		self.table = table
		self.column = column
		self.columnAlias = columnAlias
	}

	public init(_ column: Column, as columnAlias: String? = nil) {
		self.table = column.table
		self.column = column.key
		self.columnAlias = columnAlias
	}

	public func serialize() -> String {
		var result = ""
		if let table {
			result = "\(col: table)."
		}
		result += "\(col: column)"
		if let columnAlias {
			result += " AS \(col: columnAlias)"
		}

		return result
	}
}
