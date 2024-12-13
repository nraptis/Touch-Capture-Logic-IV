//
//  AnimusTouchPointerBag+Final.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/9/24.
//

import Foundation

extension AnimusTouchPointerBag {
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; All we are doing here
    // is updating each touch pointer, then
    // removing any that have expired.
    //
    func update(deltaTime: Float) {
        
        // Update each pointer...
        for pointerIndex in 0..<touchPointerCount {
            let pointer = touchPointers[pointerIndex]
            pointer.update(deltaTime: deltaTime)
        }
        
        // Add expired pointers to the temp list...
        tempTouchPointerCount = 0
        for pointerIndex in 0..<touchPointerCount {
            let pointer = touchPointers[pointerIndex]
            if pointer.isExpired {
                tempTouchPointersAdd(pointer)
            }
        }
        
        // Remove all pointers from the temp list...
        for pointerIndex in 0..<tempTouchPointerCount {
            let pointer = tempTouchPointers[pointerIndex]
            _ = touchPointersRemove(pointer)
        }
    }
    
    
    // [Touch Routes Verify] 12-10-2024
    //
    // Seems correct; I don't see any possible
    // possible problem with this function.
    // It should not ever change, it's perfect.
    //
    // @Precondition: actionType is proper
    //
    func calculateConsiderTouchPointers() {
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            switch touchPointer.actionType {
            case .detached:
                touchPointer.isConsidered = false
            case .retained(let x, let y):
                touchPointer.isConsidered = true
                touchPointer.x = x
                touchPointer.y = y
            case .add(let x, let y):
                touchPointer.isConsidered = true
                touchPointer.x = x
                touchPointer.y = y
            case .remove:
                touchPointer.isConsidered = false
            case .move(let x, let y):
                touchPointer.isConsidered = true
                touchPointer.x = x
                touchPointer.y = y
            }
        }
    }
    
    // [Touch Routes Verify] 12-10-2024
    //
    // Seems correct; I don't see any possible
    // possible problem with this function.
    // It should not ever change, it's perfect.
    //
    // @Precondition: calculateConsiderTouchPointers
    //
    func getAverageOfValidTouchPointers() -> AnimusTouchPointerAveragesResponse {
        
        // Here we are simply counting the considered pointers.
        // It should have been calculated before this...!!!!!!!!
        // We consider "add," "remove," and "retained"
        // We do not consider "detached" or "remove"
        var validTouchPointerCount = 0
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            if touchPointer.isConsidered {
                validTouchPointerCount += 1
            }
        }
        
        // We break this down into 3 cases, which is over-kill.
        if validTouchPointerCount <= 0 {
            // There were no valid touches.
            // The average of 0 items is nonsense.
            return AnimusTouchPointerAveragesResponse.invalid
        } else if validTouchPointerCount == 1 {
            // With just 1 valid point,
            // there is no need to divide.
            var averageX = Float(0.0)
            var averageY = Float(0.0)
            for touchPointerIndex in 0..<touchPointerCount {
                let touchPointer = touchPointers[touchPointerIndex]
                if touchPointer.isConsidered {
                    averageX = touchPointer.x
                    averageY = touchPointer.y
                }
            }
            return AnimusTouchPointerAveragesResponse.valid(Math.Point(x: averageX, y: averageY))
        } else {
            // We sum up the values and
            // divide by the count.
            var averageX = Float(0.0)
            var averageY = Float(0.0)
            for touchPointerIndex in 0..<touchPointerCount {
                let touchPointer = touchPointers[touchPointerIndex]
                if touchPointer.isConsidered {
                    averageX += touchPointer.x
                    averageY += touchPointer.y
                }
            }
            let validTouchPointerCountf = Float(validTouchPointerCount)
            averageX /= validTouchPointerCountf
            averageY /= validTouchPointerCountf
            return AnimusTouchPointerAveragesResponse.valid(Math.Point(x: averageX, y: averageY))
        }
    }
    
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; We are using the same
    // logic in many places, it's no different.
    //
    func touchPointersAdd(_ pointer: AnimusTouchPointer) {
        if AnimusController.INSANE_VERIFY {
            if touchPointersContains(pointer) {
                print("FATAL ERROR: We're adding the same touch pointer which already exists...")
            }
        }
        
        while touchPointers.count <= touchPointerCount {
            touchPointers.append(pointer)
        }
        touchPointers[touchPointerCount] = pointer
        touchPointerCount += 1
    }
    
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; I've read each line.
    // Each line is exactly as it should be.
    //
    func touchPointersCount(_ pointer: AnimusTouchPointer) -> Int {
        var result = 0
        for pointerIndex in 0..<touchPointerCount {
            if pointer === touchPointers[pointerIndex] {
                result += 1
            }
        }
        return result
    }
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; We are using the same
    // logic in many places, I'm never seeing
    // the fatal warnings show up in practice.
    //
    func touchPointersRemove(_ pointer: AnimusTouchPointer) -> Bool {
        
        if AnimusController.INSANE_VERIFY {
            let touchCount = touchPointersCount(pointer)
            if touchCount > 1 {
                print("FATAL: We have a Touch Pointer more than once...")
            }
            if touchCount <= 0 {
                print("FATAL: We are removing a Touch Pointer that's not in the list?!?!")
                return false
            }
        }
        
        var numberRemoved = 0
        var removeLoopIndex = 0
        while removeLoopIndex < touchPointerCount {
            if touchPointers[removeLoopIndex] === pointer {
                break
            } else {
                removeLoopIndex += 1
            }
        }
        while removeLoopIndex < touchPointerCount {
            if touchPointers[removeLoopIndex] === pointer {
                numberRemoved += 1
            } else {
                touchPointers[removeLoopIndex - numberRemoved] = touchPointers[removeLoopIndex]
            }
            removeLoopIndex += 1
        }
        touchPointerCount -= numberRemoved
        AnimusPartsFactory.shared.depositAnimusTouchPointer(pointer)
        if numberRemoved > 0 {
            return true
        } else {
            return false
        }
    }
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; I've read each line.
    // Each line is exactly as it should be.
    //
    func sync_DetachAllTouchPointers() {
        for pointerIndex in 0..<touchPointerCount {
            let pointer = touchPointers[pointerIndex]
            pointer.actionType = .detached
        }
    }
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; I've read each line.
    // Each line is exactly as it should be.
    //
    func touchPointersFind(touchID: ObjectIdentifier) -> AnimusTouchPointer? {
        for pointerIndex in 0..<touchPointerCount {
            if touchPointers[pointerIndex].touchID == touchID {
                return touchPointers[pointerIndex]
            }
        }
        return nil
    }
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; I've read each line.
    // Each line is exactly as it should be.
    //
    func touchPointersContains(_ pointer: AnimusTouchPointer) -> Bool {
        for pointerIndex in 0..<touchPointerCount {
            if touchPointers[pointerIndex] === pointer {
                return true
            }
        }
        return false
    }
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; I've read each line.
    // Each line is exactly as it should be.
    // We can remove the insane check later.
    //
    func tempTouchPointersAdd(_ pointer: AnimusTouchPointer) {
        if AnimusController.INSANE_VERIFY {
            if tempTouchPointersContains(pointer) {
                print("FATAL ERROR: We're adding the same purgatory touch which is in regular touches...")
            }
        }
        
        while tempTouchPointers.count <= tempTouchPointerCount {
            tempTouchPointers.append(pointer)
        }
        tempTouchPointers[tempTouchPointerCount] = pointer
        tempTouchPointerCount += 1
    }
    
    // [Touch Routes Verify] 12-13-2024
    //
    // Seems correct; I've read each line.
    // Each line is exactly as it should be.
    //
    func tempTouchPointersContains(_ pointer: AnimusTouchPointer) -> Bool {
        for pointerIndex in 0..<tempTouchPointerCount {
            if tempTouchPointers[pointerIndex] === pointer {
                return true
            }
        }
        return false
    }
}
