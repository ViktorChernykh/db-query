//
//  DBSessionsMiddleware.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

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
	public let session: DBSessionProtocol

	/// Creates a new `SessionsMiddleware`.
	///
	/// - parameters:
	///     - sessions: `Sessions` implementation to use for fetching and storing sessions.
	///     - configuration: `SessionsConfiguration` to use for naming and creating cookie values.
	public init(
		domain: String? = nil,
		timeInterval: Double = 60 * 60 * 24 * 7, // one week
		isHTTPOnly: Bool = false,
		isSecure: Bool = false,
		maxAge: Int? = nil,
		path: String = "/",
		sameSite: HTTPCookies.SameSitePolicy,
		cookieName: String = "session",
		session: DBSessionProtocol
	) {
		self.domain = domain
		self.timeInterval = timeInterval
		self.isHTTPOnly = isHTTPOnly
		self.isSecure = isSecure
		self.maxAge = maxAge
		self.path = path
		self.sameSite = sameSite
		self.cookieName = cookieName
		self.session = session
	}

	public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
		let newExpires = Date().addingTimeInterval(timeInterval)
		let cookieValue: String

		if let value = request.cookies[cookieName],
		   let session = try await DBSessionModel.select(on: request.sql)
			.filter(sess.string == value.string)
			.first(decode: DBSessionModel.self),
		   let _ = try await DBSessionModel.update(on: request.sql)
					.filter(sess.string == value.string)
					.set(sess.expires == newExpires)
					.returning(sess.string)
					.first() {
			   cookieValue = value.string

			if session.isAuth,
				let userId = session.userId,
				let user = try await T.select(on: request.sql)
					.filter(Column("id", "u") == userId)
					.first(decode: T.self) {
				request.auth.login(user)
			}
		} else {
			// Session id not found, create new session.
			let session = DBSessionModel(expires: newExpires)
			try await session.create(on: request.sql)
			cookieValue = session.string
		}
		let response = try await next.respond(to: request)
		response.cookies[cookieName] = cookieFactory(cookieValue)
		return response
	}

	private func cookieFactory(_ string: String) -> HTTPCookies.Value {
		HTTPCookies.Value(
			string: string,
			expires: Date(timeIntervalSinceNow: timeInterval),
			maxAge: maxAge,
			domain: domain,
			path: path,
			isSecure: isSecure,
			isHTTPOnly: isHTTPOnly,
			sameSite: .lax
		)
	}

	struct DBSessionString: Codable {
		let string: String

		init(string: String) {
			self.string = string
		}
	}
}
