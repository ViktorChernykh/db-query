infix operator ~~
infix operator !~
infix operator |=|
infix operator !|=|

import SQLKit

public func + (_ lhs: SQLRaw, _ rhs: SQLRaw) -> SQLRaw {
	.init(lhs.sql + " " + rhs.sql, lhs.binds + rhs.binds)
}

public func == (_ lhs: Column, _ rhs: Column) -> ColumnColumn {
	.init(lhs: lhs, op: " = ", rhs: rhs)
}
public func != (_ lhs: Column, _ rhs: Column) -> ColumnColumn {
	.init(lhs: lhs, op: " != ", rhs: rhs)
}
public func > (_ lhs: Column, _ rhs: Column) -> ColumnColumn {
	.init(lhs: lhs, op: " > ", rhs: rhs)
}
public func < (_ lhs: Column, _ rhs: Column) -> ColumnColumn {
	.init(lhs: lhs, op: " < ", rhs: rhs)
}
public func >= (_ lhs: Column, _ rhs: Column) -> ColumnColumn {
	.init(lhs: lhs, op: " >= ", rhs: rhs)
}
public func <= (_ lhs: Column, _ rhs: Column) -> ColumnColumn {
	.init(lhs: lhs, op: " <= ", rhs: rhs)
}

public func == (_ lhs: Column, _ rhs: Encodable) -> ColumnBind {
	.init(lhs: lhs, op: " = ", rhs: rhs)
}
public func != (_ lhs: Column, _ rhs: Encodable) -> ColumnBind {
	.init(lhs: lhs, op: " != ", rhs: rhs)
}
public func > (_ lhs: Column, _ rhs: Encodable) -> ColumnBind {
	.init(lhs: lhs, op: " > ", rhs: rhs)
}
public func < (_ lhs: Column, _ rhs: Encodable) -> ColumnBind {
	.init(lhs: lhs, op: " < ", rhs: rhs)
}
public func >= (_ lhs: Column, _ rhs: Encodable) -> ColumnBind {
	.init(lhs: lhs, op: " >= ", rhs: rhs)
}
public func <= (_ lhs: Column, _ rhs: Encodable) -> ColumnBind {
	.init(lhs: lhs, op: " <= ", rhs: rhs)
}
public func ~~ (_ lhs: Column, _ rhs: [Encodable]) -> ColumnBinds {
	.init(lhs: lhs, op: " IN ", rhs: rhs)
}
public func !~ (_ lhs: Column, _ rhs: [Encodable]) -> ColumnBinds {
	.init(lhs: lhs, op: " NOT IN ", rhs: rhs)
}

public func |=| (_ lhs: Column, _ rhs: [Encodable]) -> ColumnBinds {
	.init(lhs: lhs, op: " BETWEEN ", rhs: rhs)
}
public func !|=| (_ lhs: Column, _ rhs: [Encodable]) -> ColumnBinds {
	.init(lhs: lhs, op: " NOT BETWEEN ", rhs: rhs)
}

public struct ColumnColumn {
	public let lhs: Column
	public let op: String
	public let rhs: Column
}

public struct ColumnBind {
	public let lhs: Column
	public let op: String
	public let rhs: Encodable
}

public struct ColumnBinds {
	public let lhs: Column
	public let op: String
	public let rhs: [Encodable]
}
