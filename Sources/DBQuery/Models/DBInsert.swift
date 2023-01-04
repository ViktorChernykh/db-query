//
//  DBInsert.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

public struct DBInsert {
	// MARK: Stored properties
	public var values: [DBValue]

	public init(values: [DBValue] = []) {
		self.values = values
	}
}
