//
//  DBTwoFactorAuthentication.swift
//  DBQuery
//
//  Created by Victor Chernykh on 31.01.2023.
//

import Foundation

public protocol DBTwoFactorAuthentication: DBAuthenticatable {
	var twoFactorEnabled: Bool { get set }
}
