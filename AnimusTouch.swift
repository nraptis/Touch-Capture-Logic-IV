//
//  AnimusTouch.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import UIKit

class AnimusTouch {
    
    typealias Point = Math.Point
    
    var x = Float(0.0)
    var y = Float(0.0)
    
    var touchID: ObjectIdentifier?
    
    var residency = AnimusTouchResidency.unassigned
    
    //TODO: The expire time should be like 8 seconds at least
    static let expireTime = Float(8.0)
    //static let historyExpireTime = Float(0.15)
    static let historyExpireTime = Float(0.40)
    
    var stationaryTime = Float(0.0)
    var isExpired = false
    
    var history = AnimusTouchHistory()
    
    //TODO: This is only used for test render
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
    
    //TODO: This is only used for test
    func read(from animusTouch: AnimusTouch) {
        x = animusTouch.x
        y = animusTouch.y
        
        stationaryTime = animusTouch.stationaryTime
        isExpired = animusTouch.isExpired
        
        touchID = animusTouch.touchID
        residency = animusTouch.residency
        history.read(from: animusTouch.history)
    }
}
