//
//  DBAuthenticatable.swift
//  DBQuery
//
//  Created by Victor Chernykh on 31.01.2023.
//

import Vapor

public protocol DBAuthenticatable: Authenticatable, DBModel {
	var email: String { get set }
	var password: String { get set }

	func verify(password: String) throws -> Bool
}
