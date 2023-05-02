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
			self.delegate = DBSessionPostgres.shared
		case .custom(let driver):
			self.delegate = driver
		}
	}

	public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
		let cookieValue: String
		let expires = Date().addingTimeInterval(configuration.timeInterval)

		// Check for an existing session
		if let session = try await delegate.read(on: request), // read session
		   session.expires > Date() {
			cookieValue = session.string

			// Update session.expires
			try await delegate.update(
				expires: expires,
				on: request)

			// Authenticate
			if let id = session.userId,
			   let user = try await T.select(on: request.sql)
				.fields()
				.filter(Column("id", "u") == id)
				.first(decode: T.self) {
				request.auth.login(user)
			}
		} else {
			// create new session
			cookieValue = try await delegate.create(
				csrf: nil,
				data: [:],
				expires: expires,
				userId: nil,
				on: request)

			request.cookies[configuration.cookieName] = configuration.cookieFactory(
				cookieValue,
				expires: expires)
		}

		let response = try await next.respond(to: request)

		response.cookies[configuration.cookieName] = configuration.cookieFactory(
			cookieValue,
			expires: expires)

		return response
	}
}
