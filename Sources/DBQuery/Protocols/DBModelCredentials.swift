//
//  DBModelCredentials.swift
//  DBQuery
//
//  Created by Victor Chernykh on 28.03.2023.
//

public protocol DBModelCredentials {
	var email: String { get set }
	var passwordHash: String { get set }
}
