//
//  DBRaw.swift
//
//
//  Created by Victor Chernykh on 15.04.2024.
//

import SQLKit

public struct DBRaw: SQLExpression {
	/// The raw SQL text serialized by this expression.
	public var sql: String
	public var binds: [any Encodable & Sendable]

	/// Create a new raw SQL text expression.
	///
	/// - Parameters:
	///	  - sql: The raw SQL text to serialize.
	///	  - binds: The values for sql.
	@inlinable
	public init(_ sql: String, _ binds: [any Encodable & Sendable] = []) {
		self.sql = sql
		self.binds = binds
	}

	// See `SQLExpression.serialize(to:)`.
	@inlinable
	public func serialize(to serializer: inout SQLSerializer) {
		serializer.write(self.sql)
		serializer.binds += self.binds
	}
}
