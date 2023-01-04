//
//  Column.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct Column {
	public let key: String
	public let table: String?

	public init(_ key: String, _ table: String?) {
		self.key = key
		self.table = table
	}
}

extension Column: CustomStringConvertible {
	public var description: String {
		if let table {
			return "\(str: table).\(str: key)"
		} else {
			return "\(str: key)"
		}
	}
}
