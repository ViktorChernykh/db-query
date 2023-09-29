//
//  DBSessionsConfiguration.swift
//  DBQuery
//
//  Created by Victor Chernykh on 28.03.2023.
//

import Vapor

/// Configuration options for sessions.
public struct DBSessionsConfiguration {
	// MARK: Properties
	/// The affected domain at which the cookie is active.
	public let domain: String?

	/// The cookie's expiration.
	public let timeInterval: Double

	/// The time interval to delete expired sessions.
	public let flushTimeInterval: Double

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

	/// Creates a new `SessionsMiddleware`.
	///
	/// - parameters:
	///     - sessions: `Sessions` implementation to use for fetching and storing sessions.
	///     - configuration: `SessionsConfiguration` to use for naming and creating cookie values.
	public init(
		domain: String? = nil,
		timeInterval: Double = 604_800, // one week
		flushTimeInterval: Double = 86400, // one day
		isHTTPOnly: Bool = false,
		isSecure: Bool = false,
		maxAge: Int? = nil,
		path: String = "/",
		sameSite: HTTPCookies.SameSitePolicy = .lax,
		cookieName: String = "session"
	) {
		self.domain = domain
		self.timeInterval = timeInterval
		self.flushTimeInterval = flushTimeInterval
		self.isHTTPOnly = isHTTPOnly
		self.isSecure = isSecure
		self.maxAge = maxAge
		self.path = path
		self.sameSite = sameSite
		self.cookieName = cookieName
	}

	/// Creates cookie.
	/// - Parameters:
	///   - string: session id.
	///   - expires: session expires.
	/// - Returns: session cookie.
	public func cookieFactory(_ string: String, expires: Date) -> HTTPCookies.Value {
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
