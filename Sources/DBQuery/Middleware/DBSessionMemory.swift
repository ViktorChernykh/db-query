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
		for req: Request
	) async throws -> String {
		let sessionId = DBSessionModel.generateID()
		let session = DBSessionModel(
			string: sessionId,
			csrf: csrf,
			data: data,
			expires: expires,
			userId: userId)

		cache[sessionId] = session

		return sessionId
	}


	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	/// - Returns: model  by session key saved in cache
	public func read(_ sessionId: String, for req: Request) async throws -> DBSessionModel? {
		cache[sessionId]
	}

	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	/// - Returns: Cross-Site Request Forgery if specify
	public func readCSRF(_ sessionId: String, for req: Request) async throws -> String? {
		cache[sessionId]?.csrf
	}

	/// Reads session data from cache by session id.
	/// - Parameters:
	///   - sessionId: session key
	///   - csrf: Cross-Site Request Forgery
	///   - req: Vapor.request
	public func setCSRF(_ sessionId: String, csrf: String, for req: Request) async throws {
		if let session = cache[sessionId] {
			session.csrf = csrf
		}
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
		data: [String: String],
		expires: Date,
		userId: UUID?,
		for req: Request
	) async throws {
		if let session = cache[sessionId] {
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
	///   - sessionId: session key
	///   - data: dictionary with session data
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		data: [String: String],
		for req: Request
	) async throws {
		if let session = cache[sessionId] {
			if let encoded = try? JSONEncoder().encode(data) {
				session.data = String(decoding: encoded, as: UTF8.self)
			}
			cache[sessionId] = session
		}
	}

	/// Updates the session data in the cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - expires: sessions expires
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		expires: Date,
		for req: Request
	) async throws {
		if let session = cache[sessionId] {
			session.expires = expires
			cache[sessionId] = session
		}
	}

	/// Updates the session data in the cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - userId: user id
	///   - req: Vapor.request
	public func update(
		_ sessionId: String,
		userId: UUID?,
		for req: Request
	) async throws {
		if let session = cache[sessionId] {
			session.userId = userId
			cache[sessionId] = session
		}
	}

	/// Delete session from cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	public func delete(_ sessionId: String, for req: Request) async throws {
		cache[sessionId] = nil
	}
}
