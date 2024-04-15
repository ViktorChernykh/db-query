//
//  SQLDatabase+Transaction.swift
//  DBQuery
//
//  Created by Victor Chernykh on 20.11.2022.
//

import SQLKit

public extension SQLDatabase {
	func transaction<T>(level: TransactionType = .readCommitted, _ closure: @escaping (SQLDatabase) async throws -> T) async throws -> T {
		do {
			try await self.begin(level: level, on: self)
			let result = try await closure(self)
			try await commit(on: self)
			return result
		} catch let error {
			try await self.rollBack(on: self)
			throw error
		}
	}

	func begin(level: TransactionType = .readCommitted, on db: SQLDatabase) async throws {
		let sql = "BEGIN \(level.rawValue);"
		try await self.raw(DBRaw(sql)).run()
	}

	func savePoint(_ name: String, on db: SQLDatabase) async throws {
		try await self.raw(DBRaw("SAVEPOINT \(name);")).run()
	}

	func rollBack(to name: String? = nil, on db: SQLDatabase) async throws {
		var sql: String
		if let name {
			sql = "ROLLBACK TO \(name);"
		} else {
			sql = "ROLLBACK;"
		}
		try await self.raw(DBRaw(sql)).run()
	}

	func commit(on db: SQLDatabase) async throws {
		try await self.raw(DBRaw("COMMIT;")).run()
	}
}
