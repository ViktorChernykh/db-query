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
		csrf: String?,
		data: [String: String]?,
		expires: Date,
		userId: UUID?,
		for req: Request) async throws -> String

	func read(_ sessionId: String, for req: Request) async throws -> DBSessionModel?
	func readCSRF(_ sessionId: String, for req: Request) async throws -> String?
	func setCSRF(_ sessionId: String, csrf: String, for req: Request) async throws

	func update(
		_ sessionId: String,
		data: [String: String],
		expires: Date,
		userId: UUID?,
		for req: Request
	) async throws

	func update(
		_ sessionId: String,
		data: [String: String],
		for req: Request
	) async throws

	func update(
		_ sessionId: String,
		expires: Date,
		for req: Request
	) async throws

	func update(
		_ sessionId: String,
		userId: UUID?,
		for req: Request
	) async throws

	func delete(_ sessionId: String, for req: Request) async throws
}
