import Foundation
import SQLKit

public struct DBRowDecoder {

	public init() { }

	func decode<T>(_ type: T.Type, from row: SQLRow) throws -> T
	where T: Decodable
	{
		return try T.init(from: _Decoder(row: row))
	}

	enum _Error: Error {
		case nesting
		case unkeyedContainer
		case singleValueContainer
	}

	struct _Decoder: Decoder {
		let row: SQLRow
		var codingPath: [CodingKey] = []
		var userInfo: [CodingUserInfoKey: Any] {
			[:]
		}

		fileprivate init(row: SQLRow, codingPath: [CodingKey] = []) {
			self.row = row
			self.codingPath = codingPath
		}

		func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
		where Key: CodingKey
		{
			.init(_KeyedDecoder(referencing: self, row: self.row, codingPath: self.codingPath))
		}

		func unkeyedContainer() throws -> UnkeyedDecodingContainer {
			throw _Error.unkeyedContainer
		}

		func singleValueContainer() throws -> SingleValueDecodingContainer {
			throw _Error.singleValueContainer
		}
	}

	struct _KeyedDecoder<Key>: KeyedDecodingContainerProtocol
	where Key: CodingKey
	{
		/// A reference to the decoder we're reading from.
		private let decoder: _Decoder
		let row: SQLRow
		var codingPath: [CodingKey] = []
		var allKeys: [Key] {
			self.row.allColumns.compactMap {
				Key.init(stringValue: $0)
			}
		}

		fileprivate init(referencing decoder: _Decoder, row: SQLRow, codingPath: [CodingKey] = []) {
			self.decoder = decoder
			self.row = row
		}

		func contains(_ key: Key) -> Bool {
			self.row.contains(column: key.stringValue)
		}

		func decodeNil(forKey key: Key) throws -> Bool {
			try self.row.decodeNil(column: key.stringValue)
		}

		func decode<T>(_ type: T.Type, forKey key: Key) throws -> T
		where T: Decodable
		{
			try self.row.decode(column: key.stringValue, as: T.self)
		}

		func nestedContainer<NestedKey>(
			keyedBy type: NestedKey.Type,
			forKey key: Key
		) throws -> KeyedDecodingContainer<NestedKey>
		where NestedKey: CodingKey
		{
			throw _Error.nesting
		}

		func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
			throw _Error.nesting
		}

		func superDecoder() throws -> Decoder {
			_Decoder(row: self.row, codingPath: self.codingPath)
		}

		func superDecoder(forKey key: Key) throws -> Decoder {
			throw _Error.nesting
		}
	}
}
