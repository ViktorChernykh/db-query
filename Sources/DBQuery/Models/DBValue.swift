//
//  DBValue.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.01.2023.
//

import Foundation

public struct DBValue {
	public var value: Encodable
	public var type: String?

	public init(value: Encodable, type: String? = nil) {
		self.value = value
		self.type = type
	}
}
