# DBQuery

[![Swift 5.5](https://img.shields.io/badge/Swift-5.5-orange.svg?style=flat)](ttps://developer.apple.com/swift/)
[![Vapor 4](https://img.shields.io/badge/vapor-4.56-blue.svg?style=flat)](https://vapor.codes)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

## Overview

DBQuery an API for building and serializing SQL queries in Swift. DBQuery is a SQLKit wrapper that implements CRUD for Postgres. For database creation and migrations, use Fluent or SQLKit.

## Getting started

You need to add library to `Package.swift` file:

 - add package to dependencies:
```swift
.package(url: "https://github.com/ViktorChernykh/db-query.git", from: "0.0.1")
```

- and add product to your target:
```swift
.target(name: "App", dependencies: [
    . . .
    .product(name: "DBQuery", package: "db-query")
])
```

## Use case:

```swift
extension Request {
    /// Returns Fluent.Database as SQLKit.SQLDatabase
    public var sql: SQLDatabase {
        guard let sql = self.db as? SQLDatabase else {
            fatalError("The database is not sql.")
        }
        return sql
    }
}

/// Example of model
final class User: DBModel {
    static let alias = v1.alias
    static let schema = v1.schema
    
    var id: UUID
    var name: String
    var password: String
    
    init(
        id: UUID = UUID(),
        name: String,
        password: String
    )
    
    struct v1 {
        static let schema = "users"
        static let alias = "u"
        
        static let id: Column = "id"
        static let name: Column = "name"
        static let password: Column = "password"
    }
    
    struct Public: Codable {
        let id: UUID
        let name: String
    }
}
```
### CRUD

```swift
import DBQuery
import Vapor

    typealias u = User.v1
    
    let id = UUID()
    let name = "Ray"
    let password = "******"
    
    /// Create
    try await User.create(on: req.sql)
        .query.values(id, name, password)
        .run()

    /// Read
    let users = try await User.select(on: req.sql)
        .fields(u.id, u.name)
        .filter(u.name == "Ray")
        .all(decode: User.Public)

    /// Update
    try await User.update(on: req.sql)
        .filter(u.id == id)
        .set(u.name == "Ray2")  // or .set(u.name, to: "Ray2")
        .run()
        
    /// Delete
    let deleted = try await User.delete(on: req.sql)
        .filter(u.id ~~ [id1, id2])
        .returning(id)
        .all(decode: Deleted.self)
        .map(\.id)
```
## License

This project is released under the MIT license. See LICENSE for details.
