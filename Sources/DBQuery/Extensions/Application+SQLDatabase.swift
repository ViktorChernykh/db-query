import SQLKit
import Vapor

extension Application {
	/// Returns Fluent.Database as SQLKit.SQLDatabase
	public var sql: SQLDatabase {
		guard let sql = self.db as? SQLDatabase else {
			fatalError("The database is not sql.")
		}
		return sql
	}
}
