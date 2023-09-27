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
		data: [String: String]?,
		expires: Date,
		userId: UUID?,
		on req: Request) async throws -> String

	func read(on req: Request) async throws -> DBSessionModel?
	func readCSRF(on req: Request) async throws -> CSRF?
	func updateCSRF(on req: Request) async throws

	func update(
		data: [String: String],
		expires: Date,
		userId: UUID?,
		on req: Request
	) async throws

	func update(
		data: [String: String],
		on req: Request
	) async throws

	func update(
		expires: Date,
		on req: Request
	) async throws

	/// Make the session authorized.
	func update(
		userId: UUID?,
		on req: Request
	) async throws

	func delete(on req: Request) async throws
	func delete(_ sessionId: String, on req: Request) async throws
	func deleteAll(for userId: UUID, on req: Request) async throws
	func deleteOther(_ sessionId: String, for userId: UUID, on req: Request) async throws
}
