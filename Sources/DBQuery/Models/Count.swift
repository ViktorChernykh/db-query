//
//  Count.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.12.2022.
//

import Foundation

struct Count: Codable {
	// MARK: - Stored properties
	let count: Int

	// MARK: - Init
	init(_ count: Int) {
		self.count = count
	}
}
