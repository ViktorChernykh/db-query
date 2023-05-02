//
//  DBSessionMemory.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

/// Singleton for storage in memory.
public actor DBSessionMemory: DBSessionProtocol {
	/// Singleton instance
	public static let shared = DBSessionMemory()

	/// Storage for sessions
	public var cache: [String: DBSessionModel] = [:]

	// MARK: - Init
	private init() { }

	// MARK: - Methods
	/// Creates a new session and stores it in the cache.
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

		cache[session.string] = session

		return session.string
	}


	/// Reads session data from cache by session id.
	/// - Parameter req: Vapor.request
	/// - Returns: model  by session key saved in cache
	public func read(on req: Request) async throws -> DBSessionModel? {
		if let sessionId = req.cookies["session"]?.string {
			return cache[sessionId]
		}
		return nil
	}

	/// Reads session data from cache by session id.
	/// - Parameter req: Vapor.request
	/// - Returns: Cross-Site Request Forgery if specify
	public func readCSRF(on req: Request) async throws -> String? {
		if let sessionId = req.cookies["session"]?.string {
			return cache[sessionId]?.csrf
		}
		return nil
	}

	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - csrf: Cross-Site Request Forgery
	///   - req: Vapor.request
	public func setCSRF(_ csrf: String, on req: Request) async throws {
		if let sessionId = req.cookies["session"]?.string,
			let session = cache[sessionId] {
			session.csrf = csrf
		}
	}

	/// Updates the session data in the cache.
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
		if let sessionId = req.cookies["session"]?.string,
			let session = cache[sessionId] {
			if let encoded = try? JSONEncoder().encode(data) {
				session.data = String(decoding: encoded, as: UTF8.self)
			}
			session.expires = expires
			session.userId = userId
			cache[sessionId] = session
		}
	}

	/// Updates the session data in the cache.
	/// - Parameters:
	///   - data: dictionary with session data
	///   - req: Vapor.request
	public func update(
		data: [String: String],
		on req: Request
	) async throws {
		if let sessionId = req.cookies["session"]?.string,
			let session = cache[sessionId] {
			if let encoded = try? JSONEncoder().encode(data) {
				session.data = String(decoding: encoded, as: UTF8.self)
			}
			cache[sessionId] = session
		}
	}

	/// Updates the session data in the cache.
	/// - Parameters:
	///   - expires: sessions expires
	///   - req: Vapor.request
	public func update(
		expires: Date,
		on req: Request
	) async throws {
		if let sessionId = req.cookies["session"]?.string,
			let session = cache[sessionId] {
			session.expires = expires
			cache[sessionId] = session
		}
	}

	/// Updates the session data in the cache.
	/// - Parameters:
	///   - userId: user id
	///   - req: Vapor.request
	public func update(
		userId: UUID?,
		on req: Request
	) async throws {
		if let cookie = req.cookies["session"],
			let session = cache[cookie.string] {
			session.userId = userId
			cache[cookie.string] = session
		}
	}

	/// Delete session from cache.
	/// - Parameter req: Vapor.request
	public func delete(on req: Request) async throws {
		if let sessionId = req.cookies["session"]?.string {
			cache[sessionId] = nil
		}
	}

	/// Delete session from cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	public func delete(_ sessionId: String, on req: Request) async throws {
		cache[sessionId] = nil
	}
}
