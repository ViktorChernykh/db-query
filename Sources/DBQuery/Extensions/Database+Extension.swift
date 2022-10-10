import Fluent
import SQLKit

extension Database {
    /// Returns Fluent.Database as SQLKit.SQLDatabase
    public var sql: SQLDatabase {
        guard let sql = self as? SQLDatabase else {
            fatalError("The database is not sql.")
        }
        return sql
    }
}
