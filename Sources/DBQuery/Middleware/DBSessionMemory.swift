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
	private (set) var cache: [String: DBSessionModel] = [:]

	// MARK: - Init
	private init() { }

	// MARK: - Methods
	/// Creates a new session and stores it in the cache.
	/// - Parameters:
	///   - data: dictionary with session data
	///   - expires: sessions expires
	///   - isAuth: is user authenticate
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
			data: data ?? [:],
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
		let session = cache[sessionId]

		if let dictionary = data {
			if let data = try? JSONEncoder().encode(dictionary) {
				session?.data = String(decoding: data, as: UTF8.self)
			}
		}
		session?.userId = userId
	}

	/// Delete session from cache.
	/// - Parameters:
	///   - sessionId: session key
	///   - req: Vapor.request
	public func delete(_ sessionId: String, for req: Request) async throws {
		cache[sessionId] = nil
	}
}
