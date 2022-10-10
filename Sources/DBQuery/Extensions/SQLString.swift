@testable import SQLKit

public typealias SQLString = SQLQueryString

public func += (lhs: inout SQLString, rhs: SQLString) {
    lhs.fragments += rhs.fragments
}

extension SQLString {
    /// Embed a `String` as an SQL identifier, as if with `SQLIdentifier`
    /// Use this preferentially to ensure table names, column names, and other non-keyword identifiers are appropriately
    /// represented in the database's dialect.
    public mutating func appendInterpolation(ident: Column) {
        self.fragments.append(SQLIdentifier(ident.description))
    }
    
    /// Embed an array of `Strings` as a list of SQL identifiers, using the `joiner` to separate them.
    ///
    /// - Important: This interprets each string as an identifier, _not_ as a literal value!
    ///
    /// Example:
    ///
    ///     "SELECT \(idents: "a", "b", "c", "d", joinedBy: ",") FROM \(ident: "nowhere")"
    ///
    /// Rendered by the SQLite dialect:
    ///
    ///     SELECT "a", "b", "c", "d" FROM "nowhere"
    public mutating func appendInterpolation(idents: [Column]) {
        self.fragments.append(SQLList(idents.map { SQLIdentifier($0.description) }))
    }
    
    public mutating func appendInterpolation(_ idents: Column...) {
        self.fragments.append(SQLList(idents.map { SQLIdentifier($0.description) }))
    }
    
    public var isEmpty: Bool {
        self.fragments.count > 0 ? false : true
    }
}
