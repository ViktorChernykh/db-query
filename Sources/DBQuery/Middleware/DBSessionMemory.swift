//
//  DBSessionMemory.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

public actor DBSessionMemory: DBSessionProtocol {
	public static let shared = DBSessionMemory()
	private (set) var cache: [String: DBSessionModel] = [:]

	private init() { }

	public func create(
		data: [String: Data]? = nil,
		expires: Date = Date().addingTimeInterval(31_536_000), // 1 year
		isAuth: Bool = false,
		userId: UUID? = nil,
		for req: Request
	) async throws -> String {
		let sessionId = DBSessionModel.generateID()
		let session = DBSessionModel(
			id: UUID(),
			string: sessionId,
			data: data ?? [:],
			expires: expires,
			isAuth: isAuth,
			userId: userId)

		cache[sessionId] = session

		return sessionId
	}

	public func read(_ sessionId: String, for req: Request) async throws -> DBSessionModel? {
		cache[sessionId]
	}

	public func update(
		_ sessionId: String,
		data: [String: Data]? = nil,
		expires: Date,
		isAuth: Bool? = nil,
		userId: UUID? = nil,
		for req: Request
	) async throws {
		let session = cache[sessionId]

		if let dictionary = data {
			if let data = try? JSONEncoder().encode(dictionary) {
				session?.data = String(decoding: data, as: UTF8.self)
			}
		}
		if let isAuth {
			session?.isAuth = isAuth
		}
		if let userId {
			session?.userId = userId
		}
	}

	public func delete(_ sessionId: String, for req: Request) async throws {
		cache[sessionId] = nil
	}
}
