//
//  DBSchema.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

public protocol DBSchema {
    static var alias: String { get }
    static var schema: String { get }
}
