//
//  Aggregates.swift
//  DBQuery
//
//  Created by Victor Chernykh on 08.09.2022.
//

public struct AgvResult: Codable {
	// MARK: Stored Properties
	public let avg: Int

	// MARK: Init
	public init(avg: Int) {
		self.avg = avg
	}
}

public struct CountResult: Codable {
	// MARK: Stored Properties
	public let count: Int

	// MARK: Init
	public init(count: Int) {
		self.count = count
	}
}

public struct MaxResult: Codable {
	// MARK: Stored Properties
	public let maximum: Int

	// MARK: Init
	public init(maximum: Int) {
		self.maximum = maximum
	}
}

public struct MinResult: Codable {
	// MARK: Stored Properties
	public let minimum: Int

	// MARK: Init
	public init(minimum: Int) {
		self.minimum = minimum
	}
}

public struct SumResult: Codable {
	// MARK: Stored Properties
	public let sum: Int

	// MARK: Init
	public init(sum: Int) {
		self.sum = sum
	}
}
