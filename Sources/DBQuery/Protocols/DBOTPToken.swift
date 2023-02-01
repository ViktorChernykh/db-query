//
//  DBOTPToken.swift
//  DBQuery
//
//  Created by Victor Chernykh on 31.01.2023.
//

import Foundation

public protocol DBOTPToken: DBModel {
	var userId: UUID { get set }
	func validate(_ input: String, allowBackupCode: Bool) -> Bool
}
