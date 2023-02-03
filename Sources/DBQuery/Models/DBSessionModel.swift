//
//  DBSessionModel.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Fluent
import SQLKit
import Vapor

public typealias sess = DBSessionModel.v1

public final class DBSessionModel: DBModel {
	public static let schema = v1.schema
	public static var alias = v1.alias

	static func generateID() -> String {
		var bytes = Data()
		for _ in 0..<32 {
			bytes.append(.random(in: .min ..< .max))
		}
		return bytes.base64EncodedString()
	}

	struct Migrate: AsyncMigration {
		typealias v1 = DBSessionModel.v1

		func prepare(on db: Database) async throws {
			try await db.schema(v1.schema)
				.id()
				.field(v1.string, .custom("VARCHAR(32)"), .required)
				.field(v1.data, .string)
				.field(v1.expires, .datetime, .required)
				.field(v1.isAuth, .bool, .required)
				.field(v1.userId, .uuid)
				.unique(on: v1.string)
				.unique(on: v1.userId)
				.create()
		}

		func revert(on db: Database) async throws {
			try await db.schema(v1.schema).delete()
		}
	}

	public static var migrate: AsyncMigration {
		Migrate()
	}

	public var id: UUID
	public var string: String
	public var data: String?
	public var expires: Date
	public var isAuth: Bool
	public var userId: UUID?

	public init(
		id: UUID = UUID(),
		string: String? = nil,
		data: [String: Data] = [:],
		expires: Date,
		isAuth: Bool = false,
		userId: UUID? = nil
	) {
		self.id = id
		self.string = string ?? Self.generateID()
		if !data.isEmpty, let data = try? JSONEncoder().encode(data) {
			self.data = String(decoding: data, as: UTF8.self)
		} else {
			self.data = nil
		}
		self.expires = expires
		self.isAuth = isAuth
		self.userId = userId
	}
}

extension DBSessionModel {
	public enum v1 {
		public static let schema = "_db_sessions"
		public static let alias = "session"

		public static let id = Column("id", Self.alias)
		public static let string = Column("string", Self.alias)
		public static let data = Column("data", Self.alias)
		public static let expires = Column("expires", Self.alias)
		public static let isAuth = Column("isAuth", Self.alias)
		public static let userId = Column("userId", Self.alias)
	}
}

extension DBSessionModel {
	// MARK: - create
	@discardableResult
	public func create(on db: SQLDatabase) async throws -> UUID {
		let sql = "INSERT INTO \(col: v1.schema) VALUES($1, $2, $3, $4, $5, $6);"
		let binds: [Encodable] = [id, string, data, expires, isAuth, userId]
		let query = SQLRaw(sql, binds)
		try await db.raw(query).run()

		return id
	}
}

extension DBSessionModel: Authenticatable { }
