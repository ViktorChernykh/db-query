import Foundation
import SQLKit
import FluentKit

public protocol DBModel: AnyObject, Codable, DBSchema {
    var id: UUID { get set }
}

extension DBModel {
    /// Creates DBSelectBuilder with custom space and table name.
    /// - Parameters:
    ///   - space: A postgres schema name.
    ///   - section: A suffix for table name.
    ///   - id: model id
    ///   - db: SQLDatabase.
    /// - Returns: DBSelectBuilder.
    public static func find(space: String? = nil, section: String = "", id: UUID, on db: SQLDatabase) async throws -> Self? {
        return try await DBSelectBuilder<Self>(space: space, section: section, on: db)
            .filter(Column("id") == id)
            .first(decode: Self.self)
    }

    /// Creates DBSelectBuilder with custom space and table name.
    /// - Parameters:
    ///   - space: A postgres schema name.
    ///   - section: A suffix for table name.
    ///   - db: SQLDatabase.
    /// - Returns: DBSelectBuilder.
    public static func select(space: String? = nil, section: String = "", on db: SQLDatabase) -> DBSelectBuilder<Self> {
        return DBSelectBuilder<Self>(
            space: space,
            section: section,
            on: db)
    }

    @discardableResult
    /// Creates line into database
    /// - Parameters:
    ///   - space: A postgres schema name.
    ///   - section: A suffix for table name.
    ///   - db: SQLDatabase.
    /// - Returns: Created model's id.
    public static func create(space: String? = nil, section: String = "", on db: SQLDatabase) -> DBInsertBuilder<Self> {
        return DBInsertBuilder<Self>(
            space: space,
            section: section,
            on: db)
    }

    /// Creates DBUpdateBuilder with custom space and table name.
    /// - Parameters:
    ///   - space: A postgres schema name.
    ///   - section: A suffix for table name.
    ///   - db: SQLDatabase.
    /// - Returns: DBUpdateBuilder.
    public static func update(space: String? = nil, section: String = "", on db: SQLDatabase) -> DBUpdateBuilder<Self> {
        return DBUpdateBuilder<Self>(
            space: space,
            section: section,
            on: db)
    }

    /// Deletes DBDeleteBuilder with custom space and table name.
    /// - Parameters:
    ///   - space: A postgres schema name.
    ///   - section: A suffix for table name.
    ///   - db: SQLDatabase.
    /// - Returns: DBUpdateBuilder.
    public static func delete(space: String? = nil, section: String = "", on db: SQLDatabase) -> DBDeleteBuilder<Self> {
        return DBDeleteBuilder<Self>(
            space: space,
            section: section,
            on: db)
    }

    /// Deletes DBDeleteBuilder with custom space and table name.
    /// - Parameters:
    ///   - space: A postgres schema name.
    ///   - section: A suffix for table name.
    ///   - id: model id
    ///   - db: SQLDatabase.
    /// - Returns: DBUpdateBuilder.
    public static func delete(space: String? = nil, section: String = "", id: UUID, on db: SQLDatabase) async throws {
        return try await DBDeleteBuilder<Self>(space: space, section: section, on: db)
            .filter(Column("id") == id)
            .run()
    }
}
