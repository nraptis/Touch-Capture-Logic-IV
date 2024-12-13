//
//  Animus2TouchPointerBag+Final.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/9/24.
//

import Foundation

extension Animus2TouchPointerBag {
    
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
    
    func countConsiderTouchPointers() -> Int {
        var result = 0
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            if touchPointer.isConsidered {
                result += 1
            }
        }
        return result
    }
    
    // [Touch Routes Verify] 12-10-2024
    //
    // Seems correct; I don't see any possible
    // possible problem with this function.
    // It should not ever change, it's perfect.
    //
    // @Precondition: calculateConsiderTouchPointers
    //
    func getAverageOfValidTouchPointers() -> Animus2TouchPointerAveragesResponse {
        
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
            return Animus2TouchPointerAveragesResponse.invalid
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
            return Animus2TouchPointerAveragesResponse.valid(Math.Point(x: averageX, y: averageY))
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
            return Animus2TouchPointerAveragesResponse.valid(Math.Point(x: averageX, y: averageY))
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
