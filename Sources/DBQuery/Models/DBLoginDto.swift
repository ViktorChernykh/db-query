//
//  DBLoginDto.swift
//  DBQuery
//
//  Created by Victor Chernykh on 28.03.2023.
//

/// Data transfer object for a login request
public struct DBLoginDto: Codable {
	// MARK: - Stored properties
	public let email: String
	public let password: String

	// MARK: - Init
	public init(email: String, password: String) {
		self.email = email
		self.password = password
	}
}
