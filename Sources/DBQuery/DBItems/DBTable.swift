//
//  DBTable.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

public struct DBTable {
    public var space: String?
    public var table: String
    public var alias: String?

    public init(_ space: String? = nil, table: String, as alias: String? = nil) {
        self.space = space
        self.table = table
        self.alias = alias
    }

    public func serialize() -> String {
        let space = self.space == nil ? "" : "\"\(self.space!)\"."
        let alias = self.alias == nil ? "" : " AS \"\(alias!)\""
        return space + "\"\(table)\"" + alias
    }
}
