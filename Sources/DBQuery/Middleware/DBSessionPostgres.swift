//
//  DBSessionPostgres.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

public struct DBSessionPostgres: DBSessionProtocol {

	public init() { }

	public func create(
		data: [String: Data]? = nil,
		expires: Date = Date().addingTimeInterval(31_536_000), // 1 year
		userId: UUID? = nil,
		for req: Request
	) async throws -> String {
		let sessionId = DBSessionModel.generateID()

		try await DBSessionModel.create(on: req.sql)
			.new()
			.value(UUID())
			.value(sessionId)
			.value(data)
			.value(expires)
			.value(userId)
			.run()

		return sessionId
	}

	public func read(_ sessionID: String, for req: Request) async throws -> DBSessionModel? {
		try await DBSessionModel.select(on: req.sql)
		.fields()
		.filter(sess.string == sessionID)
		.first(decode: DBSessionModel.self)
	}

	public func update(
		_ sessionID: String,
		data: [String: Data]? = nil,
		expires: Date,
		userId: UUID? = nil,
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionID)
			.set(sess.expires, to: expires)
			.set(sess.data, to: data)
			.set(sess.userId, to: userId)
		try await query.run()
	}

	public func delete(_ sessionID: String, for req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionID)
			.run()
	}
}
