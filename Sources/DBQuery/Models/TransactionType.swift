//
//  TransactionType.swift
//  DBQuery
//
//  Created by Victor Chernykh on 21.11.2022.
//

public enum TransactionType: String {
    case readCommitted = "ISOLATION LEVEL READ COMMITTED"
    case repeatableRead = "ISOLATION LEVEL REPEATABLE READ"
    case serializable = "ISOLATION LEVEL SERIALIZABLE"
}
