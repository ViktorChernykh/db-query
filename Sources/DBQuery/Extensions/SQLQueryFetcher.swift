import NIOCore
import SQLKit

public extension SQLQueryFetcher {
	func first<D>(decode: D.Type) async throws -> D? where D: Decodable {
		return try await self.first(decode: D.self).get()
	}

	func all<D>(decode: D.Type) async throws -> [D] where D: Decodable {
		return try await self.all(decode: D.self).get()
	}

	func run<D>(decode: D.Type, _ handler: @escaping (Result<D, Error>) -> ()) async throws -> Void where D: Decodable {
		return try await self.run(decode: D.self, handler).get()
	}
}

public extension SQLQueryFetcher {
	// MARK: First
	func first<D>(decode: D.Type) -> EventLoopFuture<D?> where D: Decodable {
		return self.first().flatMapThrowing {
			guard let row = $0 else {
				return nil
			}
			return try row.decode(model: D.self)
		}
	}

	// MARK: All
	func all<D>(decode: D.Type) -> EventLoopFuture<[D]> where D: Decodable {
		return self.all().flatMapThrowing {
			try $0.map {
				try $0.decode(model: D.self)
			}
		}
	}


	// MARK: Run
	func run<D>(decode: D.Type, _ handler: @escaping (Result<D, Error>) -> ()) -> EventLoopFuture<Void>
	where D: Decodable
	{
		return self.run {
			do {
				try handler(.success($0.decode(model: D.self)))
			} catch {
				handler(.failure(error))
			}
		}
	}
}
