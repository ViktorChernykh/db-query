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
	///   - data: dictionary with session data.
	///   - expires: sessions expires.
	///   - userId: user id.
	///   - req: `Vapor.Request`.
	/// - Returns: session id.
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

		cache[session.string] = session

		return session.string
	}

	/// Reads session data from cache by session id.
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: model  by session key saved in cache.
	public func read(on req: Request) async throws -> DBSessionModel? {
		if let sessionId = req.cookies["session"]?.string {
			return cache[sessionId]
		}
		return nil
	}

	/// Reads session CSRF from the cache by session ID.
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: Cross-Site Request Forgery if specify.
	public func readCSRF(on req: Request) async throws -> CSRF? {
		if let sessionId = req.cookies["session"]?.string {
			if let session = cache[sessionId] {
				return CSRF(csrf: session.csrf, csrfExpired: session.csrfExpired)
			}
		}
		return nil
	}

	/// Reads session data from cache by session id.
	/// - Parameter req: `Vapor.Request`.
	public func updateCSRF(on req: Request) async throws {
		if let sessionId = req.cookies["session"]?.string,
			let session = cache[sessionId] {
			session.csrf = Data([UInt8].random(count: 16)).base32EncodedString()
			session.csrfExpired = Date().addingTimeInterval(3600)
			cache[sessionId] = session
		}
	}

	/// Updates the session data in the cache.
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
	///   - data: dictionary with session data.
	///   - req: `Vapor.Request`.
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
	///   - expires: sessions expires.
	///   - req: `Vapor.Request`.
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
	///   - userId: user id.
	///   - req: `Vapor.Request`.
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
	/// - Parameter req: `Vapor.Request`.
	public func delete(on req: Request) async throws {
		if let sessionId = req.cookies["session"]?.string {
			cache[sessionId] = nil
		}
	}

	/// Delete session from cache.
	/// - Parameters:
	///   - sessionId: session key.
	///   - req: `Vapor.Request`.
	public func delete(_ sessionId: String, on req: Request) async throws {
		cache[sessionId] = nil
	}
	
	/// Deletes all sessions for the specified user ID.
	/// - Parameters:
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteAll(for userId: UUID, on req: Request) async throws {
		var sessionIds = [String]()
		for (key, value) in await DBSessionMemory.shared.cache {
			if value.userId == userId {
				sessionIds.append(key)
			}
			for sessionId in sessionIds {
				try await DBSessionMemory.shared.delete(sessionId, on: req)
			}
		}
	}
	/// Deletes all sessions for the  user ID except specified sessionId.
	/// - Parameters:
	///	  - sessionId: sessionId for exception.
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteOther(_ sessionId: String, for userId: UUID, on req: Request) async throws {
		var sessionIds = [String]()
		for (key, value) in await DBSessionMemory.shared.cache {
			if value.userId == userId, value.string != sessionId {
				sessionIds.append(key)
			}
			for sessionId in sessionIds {
				try await DBSessionMemory.shared.delete(sessionId, on: req)
			}
		}
	}
}
