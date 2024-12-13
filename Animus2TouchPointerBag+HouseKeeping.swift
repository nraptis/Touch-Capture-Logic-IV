//
//  Animus2TouchPointerBag+HouseKeeping.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/11/24.
//

import Foundation

extension Animus2TouchPointerBag {
    
    func sync_DetachAllTouchPointers() {
        for pointerIndex in 0..<touchPointerCount {
            let pointer = touchPointers[pointerIndex]
            pointer.actionType = .detached
        }
    }
    
    
    func touchPointersFind(touchID: ObjectIdentifier) -> Animus2TouchPointer? {
        for pointerIndex in 0..<touchPointerCount {
            if touchPointers[pointerIndex].touchID == touchID {
                return touchPointers[pointerIndex]
            }
        }
        return nil
    }
    
    func touchPointersContains(_ pointer: Animus2TouchPointer) -> Bool {
        for pointerIndex in 0..<touchPointerCount {
            if touchPointers[pointerIndex] === pointer {
                return true
            }
        }
        return false
    }
    
}
