//
//  DBAuthenticateMiddleware.swift
//  DBQuery
//
//  Created by Victor Chernykh on 28.03.2023.
//

import Vapor

/// Middleware for processing sessions.
public final class DBAuthenticateMiddleware<T: DBModel & Authenticatable & DBModelCredentials>: AsyncMiddleware {
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
		let dto = try request.content.decode(DBLoginDto.self)
		try await authenticate(credentials: dto, for: request)
		return try await next.respond(to: request)
	}

	private func authenticate(credentials: DBLoginDto, for request: Request) async throws {
		guard let user = try await T.select(on: request.sql)
			.fields()
			.filter(Column("email", "u") == credentials.email)
			.first(decode: T.self),
			  try Bcrypt.verify(credentials.password, created: user.passwordHash) else {
			return
		}
		if user.isEmailConfirmed {
			let expires = Date().addingTimeInterval(configuration.timeInterval)

			if let cookie = request.cookies[configuration.cookieName],
			   try await delegate.read(cookie.string, for: request) != nil {
				let data: String? = nil
				try await delegate.update(
					cookie.string,
					data: data,
					expires: expires,
					userId: user.id,
					for: request)
			} else {
				let data: [String: Data]? = nil
				let cookieValue = try await delegate.create(
					data: data,
					expires: expires,
					userId: user.id,
					for: request)
				// set new cookie
				request.cookies[configuration.cookieName] = configuration.cookieFactory(
					cookieValue,
					expires: expires)
			}
		}
		request.auth.login(user)
	}
}
