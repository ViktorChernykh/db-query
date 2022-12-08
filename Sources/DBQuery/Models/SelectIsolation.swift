//
//  SelectIsolation.swift
//  DBQuery
//
//  Created by Victor Chernykh on 21.11.2022.
//

public enum SelectIsolation: String {
    case update = "UPDATE"
    case noKeyUpdate = "NO KEY UPDATE"
    case share = "SHARE"
    case keyShare = "KEY SHARE"
}
