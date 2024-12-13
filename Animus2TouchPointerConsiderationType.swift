//
//  Animus2TouchPointerActionType.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

import Foundation

enum Animus2TouchPointerActionType {
    case detached
    case retained(Float, Float)
    case add(Float, Float)
    case remove
    case move(Float, Float)
    
    var isDetachedOrRetained: Bool {
        switch self {
        case .detached:
            return true
        case .retained:
            return true
        default:
            return false
        }
    }
    
}
