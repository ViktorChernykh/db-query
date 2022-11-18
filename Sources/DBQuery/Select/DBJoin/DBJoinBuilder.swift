//
//  DBJoin.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

public struct DBJoin: DBFilterSerialize {
    // MARK: Stored properties
    public var alias: String
    public var from: String
    public var method: DBJoinMethod
    public var filterAnd: [DBRaw] = []
    public var filterOr: [DBRaw] = []

    // MARK: - Init
    public init(
        alias: String,
        from: String,
        method: DBJoinMethod
    ) {
        self.alias = alias
        self.from = from
        self.method = method
    }

    func serialize(source raw: DBRaw) -> DBRaw {
        var joinRaw = DBRaw(
            raw.sql + self.method.serialize() + "JOIN " + self.from,
            raw.binds)
        if (self.filterAnd.count + self.filterOr.count) > 0 {
            joinRaw.sql += " ON"
            return serializeFilter(source: joinRaw)
        }
        return joinRaw
    }
}
