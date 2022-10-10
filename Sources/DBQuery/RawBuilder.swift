import SQLKit

/// Builds raw SQL queries.
///
///     db.raw(SQLRaw())
///         .all(decoding: Planet.self)
///
public final class RawBuilder: SQLQueryFetcher {
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression
    
    /// Creates a new `SQLRawBuilder`.
    public init(_ query: SQLExpression, on db: SQLDatabase) {
        self.database = db
        self.query = query
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `RawBuilder`.
    ///
    ///     db.raw(SQLRaw())...
    ///
    /// - parameters:
    ///     - sql: The SQLRaw - alternative SQLQueryString.
    /// - returns: `RawBuilder`.
    public func raw(_ sql: SQLRaw) -> RawBuilder {
        return .init(sql, on: self)
    }
}
