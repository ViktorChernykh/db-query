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
	///   - data: dictionary with session data.
	///   - expires: sessions expires.
	///   - userId: user id.
	///   - req: `Vapor.Request`.
	/// - Returns: session id
	public func create(
		data: [String: String]? = nil,
		expires: Date = Date().addingTimeInterval(604_800), // 7 days
		userId: UUID? = nil,
		on req: Request
	) async throws -> String {
		let session = DBSessionModel(
			string: DBSessionModel.generateID(),
			data: data,
			expires: expires,
			userId: userId)
		try await session.create(on: req.sql)

		return session.string
	}

	/// Reads session data from cache by session id.
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: model  by session key saved in cache.
	public func read(on req: Request) async throws -> DBSessionModel? {
		if let sessionId = req.cookies["session"]?.string {
			return try await DBSessionModel.select(on: req.sql)
				.fields()
				.filter(sess.string == sessionId)
				.first(decode: DBSessionModel.self)
		}
		return nil
	}

	/// Reads session data from cache by session id.
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: Cross-Site Request Forgery if specify.
	public func readCSRF(on req: Request) async throws -> CSRF? {
		if let sessionId = req.cookies["session"]?.string {
			return try await DBSessionModel.select(on: req.sql)
				.fields(sess.csrf, sess.csrfExpired)
				.filter(sess.string == sessionId)
				.first(decode: CSRF.self)
		}
		return nil
	}

	/// Reads session data from cache by session id.
	/// - Parameter req: `Vapor.Request`.
	public func updateCSRF(on req: Request) async throws {
		let csrf = Data([UInt8].random(count: 16)).base32EncodedString()
		let csrfExpired = Date().addingTimeInterval(3600)

		if let sessionId = req.cookies["session"]?.string {
			try await DBSessionModel.update(on: req.sql)
				.filter(sess.string == sessionId)
				.set(sess.csrf, to: csrf)
				.set(sess.csrfExpired, to: csrfExpired)
				.run()
		}
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - data: dictionary with session data.
	///   - expires: sessions expires.
	///   - userId: user id.
	///   - req: `Vapor.Request`.
	public func update(
		data: [String: String],
		expires: Date,
		userId: UUID?,
		on req: Request
	) async throws {
		if let sessionId = req.cookies["session"]?.string {
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
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - data: session data encoded to string.
	///   - req: `Vapor.Request`.
	public func update(
		data: [String: String],
		on req: Request
	) async throws {
		if let sessionId = req.cookies["session"]?.string {
			let query = DBSessionModel.update(on: req.sql)
				.filter(sess.string == sessionId)

			if let encoded = try? JSONEncoder().encode(data) {
				let string = String(decoding: encoded, as: UTF8.self)
				query.set(sess.data, to: string)
				try await query.run()
			}
		}
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - expires: sessions expires.
	///   - req: `Vapor.Request`.
	public func update(
		expires: Date,
		on req: Request
	) async throws {
		if let sessionId = req.cookies["session"]?.string {
			let query = DBSessionModel.update(on: req.sql)
				.filter(sess.string == sessionId)
				.set(sess.expires, to: expires)

			try await query.run()
		}
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - userId: user id.
	///   - req: `Vapor.Request`.
	public func update(
		userId: UUID?,
		on req: Request
	) async throws {
		if let sessionId = req.cookies["session"]?.string {
			let query = DBSessionModel.update(on: req.sql)
				.filter(sess.string == sessionId)
				.set(sess.userId, to: userId)

			try await query.run()
		}
	}

	/// Delete session from database.
	/// - Parameter req: `Vapor.Request`.
	public func delete(on req: Request) async throws {
		guard let sessionId = req.cookies["session"]?.string else { return }
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionId)
			.run()
	}

	/// Delete session from database.
	/// - Parameters:
	///   - sessionId: session key.
	///   - req: `Vapor.Request`.
	public func delete(_ sessionId: String, on req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionId)
			.run()
	}

	/// Deletes all sessions for the specified user ID.
	/// - Parameters:
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteAll(for userId: UUID, on req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.userId == userId)
			.run()
	}

	/// Deletes all sessions for the  user ID except specified sessionId.
	/// - Parameters:
	///	  - sessionId: sessionId for exception.
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteOther(_ sessionId: String, for userId: UUID, on req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.userId == userId)
			.filter(sess.string != sessionId)
			.run()
	}
}
