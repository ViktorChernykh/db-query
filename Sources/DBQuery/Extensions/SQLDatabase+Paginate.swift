//
//  SQLDatabase+Paginate.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.12.2022.
//

import SQLKit

extension SQLDatabase {
	public func paginate<U: Decodable>(
		page: Int?,
		per: Int?,
		sql: String,
		copy: String,
		binds: [Encodable],
		decode: U.Type
	) async throws -> Page<U> {
		let pageRequest = PageRequest(
			page: max(page ?? 1, 1),
			per: max(min(per ?? 100, 100), 1)
		)
		let query = sql + " LIMIT \(pageRequest.per) OFFSET \(pageRequest.offset);"

		async let count = self.raw(SQLRaw(copy + ";", binds)).first(decode: DBCount.self)
		async let items = self.raw(SQLRaw(query, binds)).all(decode: U.self)

		let(models, total) = try await(items, count)
		return Page(
			items: models,
			metadata: .init(
				page: pageRequest.page,
				per: pageRequest.per,
				total: total?.count ?? 0
			)
		)
	}
}
