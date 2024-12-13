//
//  Animus2Touch.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import UIKit

class Animus2Touch {
    
    typealias Point = Math.Point
    
    var x = Float(0.0)
    var y = Float(0.0)
    
    //var considerX = Float(0.0)
    //var considerY = Float(0.0)
    
    var touchID: ObjectIdentifier?
    
    var residency = AnimusTouchResidency.unassigned
    
    //TODO: The expire time should be like 10 seconds at least
    static let expireTime = Float(15.0)
    //static let historyExpireTime = Float(0.15)
    static let historyExpireTime = Float(0.40)
    
    
    //var pivotAngle = Float(0.0)
    
    //var isCaptureStartLegal = false
    //var captureStartDistance = Float(0.0)
    //var captureStartAngle = Float(0.0)
    
    //var isCaptureTrackLegal = false
    //var captureTrackFactor = Float(0.0)
    //var captureTrackDistanceAdjusted = Float(0.0)
    //var captureTrackAngle = Float(0.0)
    //var captureTrackAngleDifference = Float(0.0)
    
    var stationaryTime = Float(0.0)
    var isExpired = false
    
    var history = Animus2TouchHistory()
    
    var isAllHistoryExpired: Bool {
        return history.isEveryNodeExpired()
        
    }
    
    var point: Point {
        Point(x: x, y: y)
    }
    
    func update(deltaTime: Float, clock: Float) {
        if isExpired == false {
            stationaryTime += deltaTime
            history.update(deltaTime: deltaTime, clock: clock)
            if stationaryTime >= Self.expireTime {
                isExpired = true
            }
        }
    }
    
    func linkToResidency(residency: AnimusTouchResidency) {
        self.residency = residency
        stationaryTime = 0.0
        isExpired = false
    }
    
    func clearHistory() {
        history.clearHistory()
    }
    
    func recordHistory(clock: Float) {
        history.recordHistory(clock: clock,
                              x: x,
                              y: y)
    }
    
    func read(from animusTouch: Animus2Touch) {
        x = animusTouch.x
        y = animusTouch.y
        
        stationaryTime = animusTouch.stationaryTime
        isExpired = animusTouch.isExpired
        
        touchID = animusTouch.touchID
        residency = animusTouch.residency
        history.read(from: animusTouch.history)
    }
}
