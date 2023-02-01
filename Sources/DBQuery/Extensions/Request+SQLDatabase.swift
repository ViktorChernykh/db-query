//
//  Request+SQLDatabase.swift
//  DBQuery
//
//  Created by Victor Chernykh on 31.01.2023.
//

import SQLKit
import Vapor

extension Request {
	/// Returns Fluent.Database as SQLKit.SQLDatabase
	public var sql: SQLDatabase {
		guard let sql = self.db as? SQLDatabase else {
			fatalError("The database is not sql.")
		}
		return sql
	}
}
