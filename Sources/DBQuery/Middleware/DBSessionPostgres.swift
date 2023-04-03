//
//  DBSessionPostgres.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

/// Implementation DBSessionProtocol for Postgres database.
public struct DBSessionPostgres: DBSessionProtocol {
	/// Singleton instance
	public static let shared = DBSessionPostgres()

	// MARK: - Init
	private init() { }

	/// Creates a new session and stores it in the database.
	/// - Parameters:
	///   - csrf: Cross-Site Request Forgery
	///   - data: dictionary with session data
	///   - expires: sessions expires
	///   - userId: user id
	///   - req: Vapor.request
	/// - Returns: session id
	public func create(
		csrf: String? = nil,
		data: [String: String]? = nil,
		expires: Date = Date().addingTimeInterval(604_800), // 7 days
		userId: UUID? = nil,
		for req: Request
	) async throws -> String {
		let sessionId = DBSessionModel.generateID()
		let session = DBSessionModel(
			string: sessionId,
			csrf: csrf,
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

	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	/// - Returns: Cross-Site Request Forgery if specify
	public func readCSRF(_ sessionId: String, for req: Request) async throws -> String? {
		struct Csrf: Codable {
			let csrf: String
		}
		return try await DBSessionModel.select(on: req.sql)
			.field(sess.csrf)
			.filter(sess.string == sessionId)
			.first(decode: Csrf.self)?.csrf
	}

	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - sessionId: session key
	///   - csrf: Cross-Site Request Forgery
	///   - req: Vapor.request
	public func setCSRF(_ sessionId: String, csrf: String, for req: Request) async throws {
		try await DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionId)
			.set(sess.csrf, to: csrf)
			.run()
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - sessionId: session key
	///   - data: dictionary with session data
	///   - expires: sessions expires
	///   - userId: user id
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		data: [String: String],
		expires: Date,
		userId: UUID?,
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionId)
			.set(sess.expires, to: expires)
			.set(sess.userId, to: userId)

		if let encoded = try? JSONEncoder().encode(data) {
			let string = String(decoding: encoded, as: UTF8.self)
			query.set(sess.data, to: string)
		}

		try await query.run()
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - sessionId: session key
	///   - data: session data encoded to string
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		data: [String: String],
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionId)

		if let encoded = try? JSONEncoder().encode(data) {
			let string = String(decoding: encoded, as: UTF8.self)
			query.set(sess.data, to: string)
			try await query.run()
		}
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - sessionId: session key
	///   - expires: sessions expires
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		expires: Date,
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionId)
			.set(sess.expires, to: expires)

		try await query.run()
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - sessionId: session key
	///   - userId: user id
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		userId: UUID?,
		for req: Request
	) async throws {
		let query = DBSessionModel.update(on: req.sql)
			.filter(sess.string == sessionId)
			.set(sess.userId, to: userId)

		try await query.run()
	}

	/// Delete session from database.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	public func delete(_ sessionId: String, for req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionId)
			.run()
	}
}
