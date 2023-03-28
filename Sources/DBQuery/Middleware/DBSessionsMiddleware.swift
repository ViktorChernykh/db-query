//
//  DBSessionsMiddleware.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

public enum SessionDelegate {
	case memory
	case postgres
	case custom(DBSessionProtocol)
}
public final class DBSessionsMiddleware<T: DBModel & Authenticatable>: AsyncMiddleware {
	// MARK: Properties
	/// The affected domain at which the cookie is active.
	public let domain: String?

	/// The cookie's expiration
	public let timeInterval: Double

	/// Does not expose the cookie over non-HTTP channels.
	public let isHTTPOnly: Bool

	/// Limits the cookie to secure connections.
	public let isSecure: Bool

	/// The maximum cookie age in seconds.
	public let maxAge: Int?

	/// The path at which the cookie is active.
	public let path: String

	/// A cookie which can only be sent in requests originating from the same origin as the target domain.
	/// This restriction mitigates attacks such as cross-site request forgery (XSRF).
	public let sameSite: HTTPCookies.SameSitePolicy	// "Strict", "Lax", "None"

	public let cookieName: String
	/// Session store.
	public let delegate: DBSessionProtocol

	/// Creates a new `SessionsMiddleware`.
	///
	/// - parameters:
	///     - sessions: `Sessions` implementation to use for fetching and storing sessions.
	///     - configuration: `SessionsConfiguration` to use for naming and creating cookie values.
	public init(
		domain: String? = nil,
		timeInterval: Double = 31_536_000, // one year
		isHTTPOnly: Bool = false,
		isSecure: Bool = false,
		maxAge: Int? = nil,
		path: String = "/",
		sameSite: HTTPCookies.SameSitePolicy = .lax,
		cookieName: String = "session",
		storage: SessionDelegate
	) {
		self.domain = domain
		self.timeInterval = timeInterval
		self.isHTTPOnly = isHTTPOnly
		self.isSecure = isSecure
		self.maxAge = maxAge
		self.path = path
		self.sameSite = sameSite
		self.cookieName = cookieName

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
		let cookieValue: String
		let newExpires = Date().addingTimeInterval(timeInterval)

		// Refresh session only if it hasn't expired
		if let cookie = request.cookies[cookieName],
		   let session = try await delegate.read(cookie.string, for: request),	// read session
		   session.expires > Date() {
			cookieValue = cookie.string

			// Update session
			try await delegate.update(
				cookieValue,
				data: nil,
				expires: newExpires,
				userId: session.userId,
				for: request)

			// Authenticate
			if let userId = session.userId,
			   let user = try await T.select(on: request.sql)
				.fields()
				.filter(Column("id", "u") == userId)
				.first(decode: T.self) {
				request.auth.login(user)
			}
		} else {
			// Session id not found, create new session.
			cookieValue = try await delegate.create(
				data: nil,
				expires: newExpires,
				userId: nil,
				for: request)
		}
		let response = try await next.respond(to: request)
		// set new cookie
		response.cookies[cookieName] = cookieFactory(cookieValue, expires: newExpires)
		return response
	}

	private func cookieFactory(_ string: String, expires: Date) -> HTTPCookies.Value {
		HTTPCookies.Value(
			string: string,
			expires: expires,
			maxAge: maxAge,
			domain: domain,
			path: path,
			isSecure: isSecure,
			isHTTPOnly: isHTTPOnly,
			sameSite: .lax
		)
	}
}
