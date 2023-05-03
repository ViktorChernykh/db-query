//
//  DBSelectBuilder+Paginate.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

import Vapor

extension DBSelectBuilder {
	/// Returns a single `Page` out of the complete result set.
	///
	/// This method will first `count()` the result set, then request a subset of the results using `range()` and `all()`.
	///
	/// - Parameters:
	///   - page: The index of the page.
	///   - per: The size of the page.
	///   - decode: Type of model for decoding.
	/// - Returns: A single `Page` of the result set containing the requested items and page metadata.
	public func paginate<U: Decodable>(page: Int?, per: Int?, decode: U.Type) async throws -> Page<U> {
		let pageRequest = PageRequest(
			page: max(page ?? 1, 1),
			per: max(min(per ?? 100, 100), 1)
		)
		let copy = self.copy()
		copy.order = []
		copy.joins = copy.joins.filter { $0.method == .inner }
		self.offset = pageRequest.offset
		self.limit = pageRequest.per
		
		async let count = copy.count()
		async let items = self.all(decode: U.self)
		
		let(models, total) = try await(items, count)
		return Page(
			items: models,
			metadata: .init(
				page: pageRequest.page,
				per: pageRequest.per,
				total: total
			)
		)
	}
	
	public func paginate<U: Decodable>(decode: U.Type, on req: Request) async throws -> Page<U> {
		let page = try? req.query.decode(PageRequest.self)
		return try await paginate(page: page?.page, per: page?.per, decode: decode)
	}
}

/// A single section of a larger, traversable result set.
public struct Page<T: Codable>: Content {
	/// The page's items. Usually response models.
	public let items: [T]

	/// Metadata containing information about current page, items per page, and total items.
	public let metadata: PageMetadata

	/// Creates a new `Page`.
	public init(items: [T], metadata: PageMetadata) {
		self.items = items
		self.metadata = metadata
	}

	/// Maps a page's items to a different type using the supplied closure.
	public func map<U>(_ transform: (T) throws -> (U)) rethrows -> Page<U> {
		try .init(
			items: self.items.map(transform),
			metadata: self.metadata
		)
	}
}

/// Metadata for a given `Page`.
public struct PageMetadata: Content {
	/// Current page number. Starts at `1`.
	public let page: Int

	/// Max items per page.
	public let per: Int

	/// Total number of items available.
	public let total: Int

	/// Computed total number of pages with `1` being the minimum.
	public var pageCount: Int {
		let count = Int((Double(self.total)/Double(self.per)).rounded(.up))
		return count < 1 ? 1 : count
	}

	/// Creates a new `PageMetadata` instance.
	///
	/// - Parameters:
	///   - page: Current page number.
	///   - per: Max items per page.
	///   - total: Total number of items available.
	public init(page: Int, per: Int, total: Int) {
		self.page = page
		self.per = per
		self.total = total
	}
}

/// Represents information needed to generate a `Page` from the full result set.
public struct PageRequest: Decodable {
	/// Page number to request. Starts at `1`.
	public let page: Int

	/// Max items per page.
	public let per: Int

	public var offset: Int {
		(self.page - 1) * self.per
	}

	/// Crates a new `PageRequest`
	/// - Parameters:
	///   - page: Page number to request. Starts at `1`.
	///   - per: Max items per page.
	public init(page: Int, per: Int) {
		self.page = page
		self.per = per
	}
}
