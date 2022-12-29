//
//  DBItem.swift
//  DBQuery
//
//  Created by Victor Chernykh on 05.09.2022.
//

public enum DBItem: String {
	case begin = "BEGIN;"
	case beginRepeatableRead = "BEGIN ISOLATION LEVEL REPEATABLE READ;"
	case beginSerializable = "BEGIN ISOLATION LEVEL SERIALIZABLE;"
	case end = "END;"
	case rollback = "ROLLBACK;"
}
