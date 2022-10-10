//
//  SQLRow+Extension.swift
//  DBQuery
//
//  Created by Victor Chernykh on 11.09.2022.
//

import SQLKit

extension SQLRow {
    /// Decode an entire `Decodable` type at once, optionally applying a prefix and/or a decoding strategy
    /// to each key of the type before looking it up in the row.
    public func decode<D>(type: D.Type) throws -> D
        where D: Decodable
    {
        let rowDecoder = DBRowDecoder()
        return try rowDecoder.decode(D.self, from: self)
    }

    /// Decode an entire `Decodable` type at once using an explicit `SQLRowDecoder`.
    public func decode<D>(type: D.Type, with rowDecoder: DBRowDecoder) throws -> D
        where D: Decodable
    {
        return try rowDecoder.decode(D.self, from: self)
    }
}
