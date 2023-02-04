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
		isAuth: Bool = false,
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
			.value(isAuth)
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
		isAuth: Bool? = nil,
		userId: UUID? = nil,
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionID)
			.set(sess.expires, to: expires)
		if let data {
			query.set(sess.data, to: data)
		}
		if let isAuth {
			query.set(sess.isAuth, to: isAuth)
		}
		if let userId {
			query.set(sess.userId, to: userId)
		}
		try await query.run()
	}

	public func delete(_ sessionID: String, for req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionID)
			.run()
	}
}
