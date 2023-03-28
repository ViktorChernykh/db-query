//
//  DBSessionProtocol.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

/// Capable of managing CRUD operations for `Session`s.
public protocol DBSessionProtocol {
	func create(
		data: [String: Data]?,
		expires: Date,
		userId: UUID?,
		for req: Request) async throws -> String

	func read(_ sessionId: String, for req: Request) async throws -> DBSessionModel?

	func update(
		_ sessionId: String,
		data: [String: Data]?,
		expires: Date,
		userId: UUID?,
		for req: Request
	) async throws

	func update(
		_ sessionId: String,
		data: String?,
		expires: Date,
		userId: UUID?,
		for req: Request
	) async throws

	func delete(_ sessionId: String, for req: Request) async throws
}
