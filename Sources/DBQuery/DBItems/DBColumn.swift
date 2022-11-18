//
//  DBColumn.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct DBColumn {
    public var space: String?
    public var table: String?
    public var column: String
    public var alias: String?

    public init(_ space: String? = nil, table: String?, _ column: String, alias: String? = nil) {
        self.space = space
        self.table = table
        self.column = column
        self.alias = alias
    }

    public init(_ space: String? = nil, table: String?, _ column: Column, alias: String? = nil) {
        self.space = space
        self.table = table
        self.column = column.key
        self.alias = alias
    }

    public func serialize() -> String {
        let space = self.space == nil ? "" : "\"\(self.space!)\"."
        let table = self.table == nil ? "" : "\"\(self.table!)\"."
        let alias = self.alias == nil ? "" : " AS \(self.alias!)"

        return space + table + "\"\(self.column)\"" + alias
    }
}
