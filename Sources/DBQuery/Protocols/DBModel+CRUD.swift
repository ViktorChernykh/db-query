import Foundation
import SQLKit
import FluentKit

public protocol DBModel: AnyObject, Codable, DBSchema {
	var id: UUID { get set }
}

extension DBModel {
	/// Creates DBSelectBuilder.
	/// - Parameters:
	///   - section: A suffix for table name.
	///   - id: model id
	///   - db: SQLDatabase.
	/// - Returns: DBSelectBuilder.
	public static func find(section: String = "", id: UUID, on db: SQLDatabase) async throws -> Self? {
		return try await DBSelectBuilder<Self>(section: section, on: db)
			.filter(Column("id", alias) == id)
			.first(decode: Self.self)
	}

	/// Creates DBSelectBuilder.
	/// - Parameters:
	///   - section: A suffix for table name.
	///   - db: SQLDatabase.
	/// - Returns: DBSelectBuilder.
	public static func select(section: String = "", on db: SQLDatabase) -> DBSelectBuilder<Self> {
		return DBSelectBuilder<Self>(
			section: section,
			on: db)
	}

	@discardableResult
	/// Creates line into database
	/// - Parameters:
	///   - section: A suffix for table name.
	///   - db: SQLDatabase.
	/// - Returns: Created model's id.
	public static func create(section: String = "", on db: SQLDatabase) -> DBInsertBuilder<Self> {
		return DBInsertBuilder<Self>(
			section: section,
			on: db)
	}

	/// Creates DBUpdateBuilder.
	/// - Parameters:
	///   - section: A suffix for table name.
	///   - db: SQLDatabase.
	/// - Returns: DBUpdateBuilder.
	public static func update(section: String = "", on db: SQLDatabase) -> DBUpdateBuilder<Self> {
		return DBUpdateBuilder<Self>(
			section: section,
			on: db)
	}

	/// Deletes DBDeleteBuilder.
	/// - Parameters:
	///   - section: A suffix for table name.
	///   - db: SQLDatabase.
	/// - Returns: DBUpdateBuilder.
	public static func delete(section: String = "", on db: SQLDatabase) -> DBDeleteBuilder<Self> {
		return DBDeleteBuilder<Self>(
			section: section,
			on: db)
	}

	/// Deletes DBDeleteBuilder.
	/// - Parameters:
	///   - section: A suffix for table name.
	///   - id: model id
	///   - db: SQLDatabase.
	/// - Returns: DBUpdateBuilder.
	public static func delete(section: String = "", id: UUID, on db: SQLDatabase) async throws {
		return try await DBDeleteBuilder<Self>(section: section, on: db)
			.filter(Column("id", alias) == id)
			.run()
	}
}
