//
//  DBSessionsMiddleware.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

/// Middleware for processing sessions.
public final class DBSessionsMiddleware<T: DBModel & Authenticatable>: AsyncMiddleware {
	// MARK: Properties
	/// The sessions configuration.
	public let configuration: DBSessionsConfiguration
	/// Session store.
	public let delegate: DBSessionProtocol

	/// Creates a new `SessionsMiddleware`.
	///
	/// - parameters:
	///     - configuration: `SessionsConfiguration` to use for naming and creating cookie values.
	///     - storage: `StorageDelegate` implementation to use for fetching and storing sessions.
	public init(
		configuration: DBSessionsConfiguration,
		storage: DBStorageDelegate
	) {
		self.configuration = configuration

		switch storage {
		case .memory:
			self.delegate = DBSessionMemory.shared
		case .postgres:
			self.delegate = DBSessionPostgres()
		case .custom(let driver):
			self.delegate = driver
		}
	}

	public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
		var cookieValue: String
		let expires = Date().addingTimeInterval(configuration.timeInterval)
		var userId: UUID? = nil

		// Check for an existing session
		if let cookie = request.cookies[configuration.cookieName],
		   let session = try await delegate.read(cookie.string, for: request),	// read session
		   session.expires > Date() {
			cookieValue = cookie.string

			// Authenticate
			if let id = session.userId,
			   let user = try await T.select(on: request.sql)
				.fields()
				.filter(Column("id", "u") == id)
				.first(decode: T.self) {
				userId = id
				request.auth.login(user)
			}
			// Update session
			let data: String? = nil
			try await delegate.update(
				cookieValue,
				data: data,	// nil is not change existing data
				expires: expires,
				userId: userId,
				for: request)
		} else {
			// cookie id not found, create new session.
			cookieValue = try await delegate.create(
				data: nil,
				expires: expires,
				userId: nil,
				for: request)
		}
		let response = try await next.respond(to: request)
		// set new/update cookie
		response.cookies[configuration.cookieName] = configuration.cookieFactory(
			cookieValue,
			expires: expires)
		
		return response
	}
}
