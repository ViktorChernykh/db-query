//
//  DBSessionCycle.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

public struct DBSessionCycle: DBSessionProtocol {

	public init() { }

	public func create(
		_ data: [String: Data]? = nil,
		expires: Date,
		isAuth: Bool = false,
		userId: UUID? = nil,
		for req: Request
	) async throws -> String {
		let sessionId = DBSessionModel.generateID()

		try await DBSessionModel.create(on: req.sql)
			.new()
			.values(UUID(), sessionId, data, expires, isAuth, userId)
			.run()

		return sessionId
	}

	public func read(_ sessionID: String, for req: Request) async throws -> DBSessionModel? {
		try await DBSessionModel.select(on: req.sql)
			.filter(sess.id == sessionID)
			.first(decode: DBSessionModel.self)
	}

	public func update(
		_ sessionID: String,
		data: [String: Data]? = nil,
		expires: Date,
		isAuth: Bool,
		userId: UUID? = nil,
		for req: Request
	) async throws {
		try await DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionID)
			.set(sess.data, to: data)
			.set(sess.expires, to: expires)
			.set(sess.isAuth, to: isAuth)
			.set(sess.userId, to: userId)
			.run()
	}

	public func delete(_ sessionID: String, for req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionID)
			.run()
	}
}
