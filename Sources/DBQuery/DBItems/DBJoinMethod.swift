//
//  DBJoinMethod.swift
//  DBQuery
//
//  Created by Victor Chernykh on 04.09.2022.
//

public enum DBJoinMethod {
    case cross
    case full
    case inner
    case left
    case right
    
    public func serialize() -> String {
        switch self {
        case .cross: return " CROSS "
        case .full: return " FULL "
        case .inner: return " INNER "
        case .left: return " LEFT "
        case .right: return " RIGHT "
        }
    }
}
