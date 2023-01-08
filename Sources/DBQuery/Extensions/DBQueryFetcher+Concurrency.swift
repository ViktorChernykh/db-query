//
//  DBSelectBuilder+Concurrency.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

import NIOCore
import SQLKit

public extension DBQueryFetcher {
	func first() async throws -> SQLRow? {
		return try await self.first().get()
	}

	func first<D>(decode: D.Type) async throws -> D? where D: Decodable {
		return try await self.first(decode: D.self).get()
	}

	func all() async throws -> [SQLRow] {
		return try await self.all().get()
	}

	func all<D>(decode: D.Type) async throws -> [D] where D: Decodable {
		return try await self.all(decode: D.self).get()
	}

	func run<D>(decode: D.Type, _ handler: @escaping (Result<D, Error>) -> ()) async throws -> Void where D: Decodable {
		return try await self.run(decode: D.self, handler).get()
	}

	func run() async throws {
		return try await self.run().get()
	}
}
