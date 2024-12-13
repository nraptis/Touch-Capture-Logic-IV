//
//  AnimusController.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import UIKit

class AnimusController {
    
    var releaseGhostTestTouches = [AnimusTouch]()
    
    func notifyJiggleGrabbed_Grab(animationMode: AnimatonMode, jiggle: Jiggle) {
        print("notifyJiggleGrabbed_Grab(\(animationMode))")
    }
    
    func notifyJiggleUngrabbed_Grab(animationMode: AnimatonMode, jiggle: Jiggle) {
        print("notifyJiggleUngrabbed_Grab(\(animationMode))")
        
        releaseAnimusTouchCount = 0
        
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            let animusTouch = purgatoryAnimusTouches[animusTouchIndex]
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous:
                break
            case .jiggleGrab(let residencyJiggle):
                if residencyJiggle === jiggle {
                    print("Gathering up touch from Purgatory: \(animusTouch.touchID)")
                    releaseAnimusTouchesAddUnique(animusTouch)
                }
            }
        }
        
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous:
                break
            case .jiggleGrab(let residencyJiggle):
                if residencyJiggle === jiggle {
                    print("Fatal Error: Gathering up touch from REGULAR: \(animusTouch.touchID)")
                    releaseAnimusTouchesAddUnique(animusTouch)
                }
            }
        }
        
        print("There are \(releaseAnimusTouchCount) touches to release. They should have all come from purgatory!!!")
        
        // Let's mock the release process:
        
        releaseGhostTestTouches.removeAll()
        for animusTouchIndex in 0..<releaseAnimusTouchCount {
            let animusTouch = releaseAnimusTouches[animusTouchIndex]
            let clone = AnimusTouch()
            clone.read(from: animusTouch)
            releaseGhostTestTouches.append(clone)
        }
        
        
        // Now we remove from purgatory...
        for animusTouchIndex in 0..<releaseAnimusTouchCount {
            let animusTouch = releaseAnimusTouches[animusTouchIndex]
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous:
                break
            case .jiggleGrab(let residencyJiggle):
                if residencyJiggle === jiggle {
                    if let touchID = animusTouch.touchID {
                        jiggle.animusInstructionGrab.pointerBag.removePointersForTouchIfRemove(touchID: touchID)
                    }
                    let touchIDTEMP = animusTouch.touchID
                    if purgatoryAnimusTouchesRemove(animusTouch) {
                        print("*** SUCCESSFUL, expelled from Purgatory: \(touchIDTEMP) TEMP")
                    } else {
                        print("*** FAIL'DDDDD, expelled from Purgatory: \(touchIDTEMP) TEMP")
                    }
                }
            }
        }
    }
    
    func notifyJiggleGrabbed_Continuous(animationMode: AnimatonMode, jiggle: Jiggle) {
        print("notifyJiggleGrabbed_Continuous(\(animationMode))")
    }
    
    func notifyJiggleUngrabbed_Continuous(animationMode: AnimatonMode, jiggle: Jiggle) {
        print("notifyJiggleUngrabbed_Continuous(\(animationMode))")
    }
    
    static let INSANE_VERIFY = true
    
    static let DEBUG_ANIMATION_CONTROLER = true
    
    typealias Point = Math.Point
    typealias Vector = Math.Vector
    
    // This list retains the touches.
    var animusTouches = [AnimusTouch]()
    var animusTouchCount = 0
    
    // This list retains the touches.
    var purgatoryAnimusTouches = [AnimusTouch]()
    var purgatoryAnimusTouchCount = 0
    
    var tempAnimusTouchCount = 0
    var tempAnimusTouches = [AnimusTouch]()
    
    var releaseAnimusTouches = [AnimusTouch]()
    var releaseAnimusTouchCount = 0
    
    var clock = Float(0.0)
    
    @MainActor func update(deltaTime: Float,
                           jiggleViewModel: JiggleViewModel,
                           jiggleDocument: JiggleDocument,
                           isGyroEnabled: Bool,
                           animationMode: AnimatonMode) {
        
        if AnimusController.INSANE_VERIFY {
            for animusTouchIndex1 in 0..<purgatoryAnimusTouchCount {
                let animusTouch1 = purgatoryAnimusTouches[animusTouchIndex1]
                for animusTouchIndex2 in 0..<animusTouchCount {
                    let animusTouch2 = animusTouches[animusTouchIndex2]
                    if animusTouch1 === animusTouch2 {
                        print("Fatal: Purgatory and regular have same touch...")
                    }
                }
            }
        }
        
        clock += deltaTime
        
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            let animusTouch = purgatoryAnimusTouches[animusTouchIndex]
            animusTouch.update(deltaTime: deltaTime, clock: clock)
        }
        
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            animusTouch.update(deltaTime: deltaTime, clock: clock)
        }
        
        flushAllExpired(jiggleViewModel: jiggleViewModel,
                        jiggleDocument: jiggleDocument,
                        animationMode: animationMode)
        
        for jiggleIndex in 0..<jiggleDocument.jiggleCount {
            let jiggle = jiggleDocument.jiggles[jiggleIndex]
            jiggle.updateAnimusInstructions(deltaTime: deltaTime,
                                            jiggleViewModel: jiggleViewModel,
                                            jiggleDocument: jiggleDocument,
                                            controller: self,
                                            animationMode: animationMode,
                                            isGyroEnabled: isGyroEnabled,
                                            clock: clock)
        }
    }
    
    @MainActor func checkContinuousDisabledAndFlushIfNeeded(jiggleViewModel: JiggleViewModel,
                                                            jiggleDocument: JiggleDocument,
                                                            animationMode: AnimatonMode) -> Bool {
        if jiggleDocument.isContinuousDisableGrabEnabled == true {
            switch animationMode {
            case .unknown:
                return false
            case .grab:
                return false
            case .continuous:
                flushAll(jiggleViewModel: jiggleViewModel,
                         jiggleDocument: jiggleDocument,
                         animationMode: animationMode)
                return true
            case .loops:
                return false
            }
        } else {
            return false
        }
    }
    
    @MainActor func touchesBegan(jiggleViewModel: JiggleViewModel,
                                 jiggleDocument: JiggleDocument,
                                 animationMode: AnimatonMode,
                                 touches: [UITouch],
                                 points: [Point],
                                 allTouchCount: Int,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool,
                                 touchTargetTouchSource: TouchTargetTouchSource,
                                 isPrecise: Bool) {
        
        if checkContinuousDisabledAndFlushIfNeeded(jiggleViewModel: jiggleViewModel,
                                                   jiggleDocument: jiggleDocument,
                                                   animationMode: animationMode) {
            _ = jiggleDocument.attemptSelectJiggle(points: points,
                                                   includingFrozen: true,
                                                   nullifySelectionIfWhiff: false,
                                                   displayMode: displayMode,
                                                   isGraphEnabled: isGraphEnabled,
                                                   touchTargetTouchSource: touchTargetTouchSource,
                                                   isPrecise: isPrecise)
            return
        }
        
        snapshot_pre(jiggleViewModel: jiggleViewModel,
                     jiggleDocument: jiggleDocument,
                     animationMode: animationMode)
        
        // The touches began, so let's make sure no dupe:
        flushAnimusTouches_TouchMatch(jiggleViewModel: jiggleViewModel,
                                      jiggleDocument: jiggleDocument,
                                      touches: touches)
        flushPurgatoryAnimusTouches_TouchMatch(jiggleViewModel: jiggleViewModel,
                                               jiggleDocument: jiggleDocument,
                                               touches: touches)
        
        for touchIndex in 0..<touches.count {
            let touch = touches[touchIndex]
            let point = points[touchIndex]
            let animusTouch = AnimusPartsFactory.shared.withdrawAnimusTouch(touch: touch)
            animusTouch.x = point.x
            animusTouch.y = point.y
            addAnimusTouch(animusTouch: animusTouch)
        }
        
        linkAnimusTouches(jiggleViewModel: jiggleViewModel,
                          jiggleDocument: jiggleDocument,
                          animationMode: animationMode,
                          displayMode: displayMode,
                          isGraphEnabled: isGraphEnabled,
                          touchTargetTouchSource: touchTargetTouchSource,
                          isPrecise: isPrecise)
        recordHistoryForTouches(touches: touches)
        
        let shouldAttemptToSelectJiggle: Bool
        switch animationMode {
        case .loops:
            shouldAttemptToSelectJiggle = true
        default:
            shouldAttemptToSelectJiggle = false
        }
        
        if shouldAttemptToSelectJiggle {
            _ = jiggleDocument.attemptSelectJiggle(points: points,
                                                   includingFrozen: true,
                                                   nullifySelectionIfWhiff: false,
                                                   displayMode: displayMode,
                                                   isGraphEnabled: isGraphEnabled,
                                                   touchTargetTouchSource: touchTargetTouchSource,
                                                   isPrecise: isPrecise)
        }
        
        snapshot_post(jiggleViewModel: jiggleViewModel,
                      jiggleDocument: jiggleDocument,
                      animationMode: animationMode)
        
    }
    
    @MainActor func touchesMoved(jiggleViewModel: JiggleViewModel,
                                 jiggleDocument: JiggleDocument,
                                 animationMode: AnimatonMode,
                                 touches: [UITouch],
                                 points: [Point],
                                 allTouchCount: Int,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool,
                                 touchTargetTouchSource: TouchTargetTouchSource,
                                 isPrecise: Bool) {
        
        if checkContinuousDisabledAndFlushIfNeeded(jiggleViewModel: jiggleViewModel,
                                                   jiggleDocument: jiggleDocument,
                                                   animationMode: animationMode) {
            return
        }
        
        snapshot_pre(jiggleViewModel: jiggleViewModel,
                     jiggleDocument: jiggleDocument,
                     animationMode: animationMode)
        
        for touchIndex in 0..<touches.count {
            let touch = touches[touchIndex]
            let point = points[touchIndex]
            for animusTouchIndex in 0..<animusTouchCount {
                let animusTouch = animusTouches[animusTouchIndex]
                if animusTouch.touchID == ObjectIdentifier(touch) {
                    if (animusTouch.x != point.x) || (animusTouch.y != point.y) {
                        animusTouch.x = point.x
                        animusTouch.y = point.y
                        animusTouch.stationaryTime = 0.0
                    }
                }
            }
        }
        
        linkAnimusTouches(jiggleViewModel: jiggleViewModel,
                          jiggleDocument: jiggleDocument,
                          animationMode: animationMode,
                          displayMode: displayMode,
                          isGraphEnabled: isGraphEnabled,
                          touchTargetTouchSource: touchTargetTouchSource,
                          isPrecise: isPrecise)
        
        recordHistoryForTouches(touches: touches)
        
        snapshot_post(jiggleViewModel: jiggleViewModel,
                      jiggleDocument: jiggleDocument,
                      animationMode: animationMode)
        
    }
    
    @MainActor func touchesEnded(jiggleViewModel: JiggleViewModel,
                                 jiggleDocument: JiggleDocument,
                                 animationMode: AnimatonMode,
                                 touches: [UITouch],
                                 points: [Point],
                                 allTouchCount: Int,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) {
        
        if checkContinuousDisabledAndFlushIfNeeded(jiggleViewModel: jiggleViewModel,
                                                   jiggleDocument: jiggleDocument,
                                                   animationMode: animationMode) {
            return
        }
        
        snapshot_pre(jiggleViewModel: jiggleViewModel,
                     jiggleDocument: jiggleDocument,
                     animationMode: animationMode)
        
        tempAnimusTouchCount = 0
        for touchIndex in 0..<touches.count {
            let touch = touches[touchIndex]
            if let animusTouch = animusTouchesFind(touch: touch) {
                if tempAnimusTouchesContainsTouch(animusTouch) == false {
                    tempAnimusTouchesAdd(animusTouch)
                }
            }
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = removeAnimusTouch(jiggleViewModel: jiggleViewModel,
                                  jiggleDocument: jiggleDocument,
                                  animusTouch: animusTouch)
        }
        
        snapshot_post(jiggleViewModel: jiggleViewModel,
                      jiggleDocument: jiggleDocument,
                      animationMode: animationMode)
        
    }
    
}
