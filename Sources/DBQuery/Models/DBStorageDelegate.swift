//
//  DBStorageDelegate.swift
//  DBQuery
//
//  Created by Victor Chernykh on 28.03.2023.
//

/// Delegate options for DBSessionsMiddleware.
public enum DBStorageDelegate {
	case memory
	case postgres
	case custom(DBSessionProtocol)
}
