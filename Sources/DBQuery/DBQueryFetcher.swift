//
//  DBQueryFetcher.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

import SQLKit

public protocol DBQueryFetcher: AnyObject {
    var database: SQLDatabase { get }
    func serialize() -> SQLRaw
}

extension DBQueryFetcher {
    // MARK: - First

    public func first<D>(decode: D.Type) -> EventLoopFuture<D?> where D: Decodable {
        self.first().flatMapThrowing {
            guard let row = $0 else {
                return nil
            }
            return try row.decode(type: D.self)
        }
    }

    /// Collects the first raw output and returns it.
    ///
    ///     builder.first()
    ///
    public func first() -> EventLoopFuture<SQLRow?> {
        return self.all().map { $0.first }
    }

    // MARK: - All

    public func all<D>(decode: D.Type) -> EventLoopFuture<[D]>
    where D: Decodable
    {
        self.all().flatMapThrowing {
            try $0.map {
                try $0.decode(type: D.self)
            }
        }
    }

    /// Collects all raw output into an array and returns it.
    ///
    ///     builder.all()
    ///
    public func all() -> EventLoopFuture<[SQLRow]> {
        var all: [SQLRow] = []
        return self.run { row in
            all.append(row)
        }.map { all }
    }

    // MARK: - Run

    public func run<D>(decode: D.Type, _ handler: @escaping (Result<D, Error>) -> ()) -> EventLoopFuture<Void>
        where D: Decodable
    {
        return self.run {
            do {
                try handler(.success($0.decode(type: D.self)))
            } catch {
                handler(.failure(error))
            }
        }
    }

    /// Runs the query, passing output to the supplied closure as it is received.
    ///
    ///     builder.run { print($0) }
    ///
    /// The returned future will signal completion of the query.
    public func run(_ handler: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> {
        return self.database.execute(sql: self.serialize()) { row in
            handler(row)
        }
    }

    /// Runs the query.
    ///
    ///     builder.run()
    ///
    /// - returns: A future signaling completion.
    public func run() -> EventLoopFuture<Void> {
        return self.database.execute(sql: self.serialize()) { _ in }
    }
}
