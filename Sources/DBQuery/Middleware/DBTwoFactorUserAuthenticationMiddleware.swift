//
//  DBTwoFactorUserAuthenticationMiddleware.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Vapor

public struct DBTwoFactorUserAuthenticationMiddleware<U, TF>: AsyncMiddleware
where U: DBTwoFactorAuthentication, TF: DBOTPToken {
	public func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
		guard let basic = req.headers.basicAuthorization else {
			return try await next.respond(to: req)
		}
		guard let user = try await U.select(on: req.sql)
			.filter(Column("email", "u") == basic.username)
			.first(decode: U.self)
		else {
			return try await next.respond(to: req)
		}

		if user.twoFactorEnabled {
			guard let twoFactorHeader = req.headers.first(name: "X-Auth-2FA") else {
				throw Abort(.partialContent)
			}

			guard let token = try await TF.select(on: req.sql)
				.filter(Column("userId", "tft") == user.id)
				.first(decode: TF.self),
				  try user.verify(password: basic.password) && token.validate(twoFactorHeader, allowBackupCode: true)
			else {
				return try await next.respond(to: req)
			}
			req.auth.login(user)
			return try await next.respond(to: req)
		}

		do {
			if try user.verify(password: basic.password) {
				req.auth.login(user)
			}
		} catch { }

		return try await next.respond(to: req)
	}
}
