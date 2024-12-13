//
//  Animus2TouchPointer.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

import Foundation

class Animus2TouchPointer {
    
    //
    // These should always take longer to expire than the regular touch.
    // Otherwise, we may end up out of sync (the touch stayed existing, the pointer poofed)
    //
    static let expireTime = (Animus2Touch.expireTime + Animus2Touch.expireTime * 0.5)
    
    var touchID: ObjectIdentifier
    var x = Float(0.0)
    var y = Float(0.0)
    
    var stationaryTime = Float(0.0)
    var isExpired = false
    
    var isCaptureStartScaleValid = false
    var captureStartDistance = Float(0.0)
    var captureTrackDistance = Float(0.0)
    
    var isCaptureStartRotateValid = false
    var captureStartAngle = Float(0.0)
    var captureTrackAngle = Float(0.0)
    var captureTrackAngleFixed = Float(0.0)
    var captureTrackAngleDifference = Float(0.0)
    
    var actionType = Animus2TouchPointerActionType.detached
    
    var isConsidered = false
    
    init(touchID: ObjectIdentifier) {
        self.touchID = touchID
    }
    
    func update(deltaTime: Float) {
        stationaryTime += deltaTime
        
        if stationaryTime >= Self.expireTime {
            isExpired = true
        }
    }
}
