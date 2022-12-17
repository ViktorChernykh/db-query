//
//  StringInterpolation+Extension.swift
//  DBQuery
//
//  Created by Victor Chernykh on 17.12.2022.
//

extension String.StringInterpolation {
	public mutating func appendInterpolation(c column: Column) {
		let string = "\"" + column.key + "\""
		appendLiteral(string)
	}

	public mutating func appendInterpolation(s text: String) {
		let string = "\"" + text + "\""
		appendLiteral(string)
	}
}
