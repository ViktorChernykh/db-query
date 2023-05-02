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
		on req: Request
	) async throws -> String {
		let session = DBSessionModel(
			string: DBSessionModel.generateID(),
			csrf: csrf,
			data: data,
			expires: expires,
			userId: userId)
		try await session.create(on: req.sql)

		return session.string
	}

	/// Reads session data from cache by session id.
	/// - Parameter req: Vapor.request
	/// - Returns: model  by session key saved in cache
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
	/// - Parameter req: Vapor.request
	/// - Returns: Cross-Site Request Forgery if specify
	public func readCSRF(on req: Request) async throws -> String? {
		struct Csrf: Codable {
			let csrf: String
		}
		if let sessionId = req.cookies["session"]?.string {
			return try await DBSessionModel.select(on: req.sql)
				.field(sess.csrf)
				.filter(sess.string == sessionId)
				.first(decode: Csrf.self)?.csrf
		}
		return nil
	}

	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - csrf: Cross-Site Request Forgery
	///   - req: Vapor.request
	public func setCSRF(_ csrf: String, on req: Request) async throws {
		if let sessionId = req.cookies["session"]?.string {
			try await DBSessionModel.update(on: req.sql)
				.filter(sess.string == sessionId)
				.set(sess.csrf, to: csrf)
				.run()
		}
	}

	/// Updates the session data in the database.
	/// - Parameters:
	///   - data: dictionary with session data
	///   - expires: sessions expires
	///   - userId: user id
	///   - req: Vapor.request
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
	///   - data: session data encoded to string
	///   - req: Vapor.request
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
	///   - expires: sessions expires
	///   - req: Vapor.request
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
	///   - userId: user id
	///   - req: Vapor.request
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
	/// - Parameter req: Vapor.request
	public func delete(on req: Request) async throws {
		guard let sessionId = req.cookies["session"]?.string else { return }
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionId)
			.run()
	}

	/// Delete session from database.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	public func delete(_ sessionId: String, on req: Request) async throws {
		try await DBSessionModel.delete(on: req.sql)
			.filter(sess.string == sessionId)
			.run()
	}
}
