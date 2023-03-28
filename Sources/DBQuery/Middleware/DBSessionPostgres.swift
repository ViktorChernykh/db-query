//
//  DBSessionPostgres.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

/// Implementation DBSessionProtocol for Postgres database.
public struct DBSessionPostgres: DBSessionProtocol {

	public init() { }

	/// Creates a new session and stores it in the cache.
	/// - Parameters:
	///   - data: dictionary with session data
	///   - expires: sessions expires
	///   - userId: user id
	///   - req: Vapor.request
	/// - Returns: session id
	public func create(
		data: [String: Data]? = nil,
		expires: Date = Date().addingTimeInterval(31_536_000), // 1 year
		userId: UUID? = nil,
		for req: Request
	) async throws -> String {
		let sessionId = DBSessionModel.generateID()
		let session = DBSessionModel(
			string: sessionId,
			data: data,
			expires: expires,
			userId: userId)
		try await session.create(on: req.sql)

		return sessionId
	}

	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	/// - Returns: model  by session key saved in cache
	public func read(_ sessionId: String, for req: Request) async throws -> DBSessionModel? {
		try await DBSessionModel.select(on: req.sql)
		.fields()
		.filter(sess.string == sessionId)
		.first(decode: DBSessionModel.self)
	}

	/// Updates the session data in the cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - data: dictionary with session data
	///   - expires: sessions expires
	///   - userId: user id
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		data: [String: Data]? = nil,
		expires: Date,
		userId: UUID? = nil,
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionId)
			.set(sess.expires, to: expires)
			.set(sess.data, to: data)
		if let data {
			if let encoded = try? JSONEncoder().encode(data) {
				let string = String(decoding: encoded, as: UTF8.self)
				query.set(sess.data, to: string)
			}
		}
		query.set(sess.userId, to: userId)
		try await query.run()
	}

	/// Updates the session data in the cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - data: session data encoded to string
	///   - expires: sessions expires
	///   - userId: user id
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		data: String? = nil,
		expires: Date,
		userId: UUID? = nil,
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionId)
			.set(sess.expires, to: expires)
			.set(sess.data, to: data)
			.set(sess.userId, to: userId)
		try await query.run()
	}

	/// Delete session from cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	public func delete(_ sessionId: String, for req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionId)
			.run()
	}
}
