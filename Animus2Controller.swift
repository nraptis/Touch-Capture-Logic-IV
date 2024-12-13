//
//  Animus2Controller.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import UIKit

class Animus2Controller {
    
    var releaseGhostTestTouches = [Animus2Touch]()
    
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
            let clone = Animus2Touch()
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
    var animusTouches = [Animus2Touch]()
    var animusTouchCount = 0
    
    // This list retains the touches.
    var purgatoryAnimusTouches = [Animus2Touch]()
    var purgatoryAnimusTouchCount = 0
    
    var tempAnimusTouchCount = 0
    var tempAnimusTouches = [Animus2Touch]()
    
    var releaseAnimusTouches = [Animus2Touch]()
    var releaseAnimusTouchCount = 0
    
    var clock = Float(0.0)
    
    //
    // Any time the list of touches change,
    // we do a pre and post snapshot, then
    // execute the commands...
    //
    @MainActor func snapshot_pre(jiggleViewModel: JiggleViewModel,
                                 jiggleDocument: JiggleDocument,
                                 animationMode: AnimatonMode) {
        for jiggleIndex in 0..<jiggleDocument.jiggleCount {
            let jiggle = jiggleDocument.jiggles[jiggleIndex]
            jiggle.snapshotAnimusBefore(controller: self, animationMode: animationMode)
        }
    }
    
    @MainActor func snapshot_post(jiggleViewModel: JiggleViewModel,
                                  jiggleDocument: JiggleDocument,
                                  animationMode: AnimatonMode) {
        for jiggleIndex in 0..<jiggleDocument.jiggleCount {
            let jiggle = jiggleDocument.jiggles[jiggleIndex]
            jiggle.snapshotAnimusAfterThenReconcileAndPerform(controller: self,
                                                              jiggleViewModel: jiggleViewModel,
                                                              jiggleDocument: jiggleDocument,
                                                              animationMode: animationMode)
        }
    }
    
    @MainActor func update(deltaTime: Float,
                           jiggleViewModel: JiggleViewModel,
                           jiggleDocument: JiggleDocument,
                           isGyroEnabled: Bool,
                           animationMode: AnimatonMode) {
        
        if Animus2Controller.INSANE_VERIFY {
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
        if clock > 99_999_999.0 {
            clock -= 99_999_999.0
        }
        
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
    
    @MainActor func killDragAll(jiggleViewModel: JiggleViewModel,
                                jiggleDocument: JiggleDocument,
                                animationMode: AnimatonMode) {
        snapshot_pre(jiggleViewModel: jiggleViewModel,
                     jiggleDocument: jiggleDocument,
                     animationMode: animationMode)
        flushAnimusTouches_All(jiggleViewModel: jiggleViewModel,
                               jiggleDocument: jiggleDocument,
                               reason: .flushAllKillAllTouches)
        flushPurgatoryAnimusTouches_All(jiggleViewModel: jiggleViewModel,
                                        jiggleDocument: jiggleDocument)
        snapshot_post(jiggleViewModel: jiggleViewModel,
                      jiggleDocument: jiggleDocument,
                      animationMode: animationMode)
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
        
        print("touchesBegan::")
        
        if jiggleDocument.isContinuousDisableGrabEnabled == true {
            switch animationMode {
            case .unknown:
                break
            case .grab:
                break
            case .continuous:
                flushAll(jiggleViewModel: jiggleViewModel,
                         jiggleDocument: jiggleDocument,
                         animationMode: animationMode)
                return
            case .loops:
                break
            }
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
            let animusTouch = Animus2PartsFactory.shared.withdrawAnimusTouch(touch: touch)
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
        
        if jiggleDocument.isContinuousDisableGrabEnabled == true {
            switch animationMode {
            case .unknown:
                break
            case .grab:
                break
            case .continuous:
                flushAll(jiggleViewModel: jiggleViewModel,
                         jiggleDocument: jiggleDocument,
                         animationMode: animationMode)
                return
            case .loops:
                break
            }
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
        
        print("touchesEnded::")
        
        if jiggleDocument.isContinuousDisableGrabEnabled == true {
            switch animationMode {
            case .unknown:
                break
            case .grab:
                break
            case .continuous:
                flushAll(jiggleViewModel: jiggleViewModel,
                         jiggleDocument: jiggleDocument,
                         animationMode: animationMode)
                return
            case .loops:
                break
            }
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
                                  animusTouch: animusTouch,
                                  reason: .touchesEnded)
        }
        
        snapshot_post(jiggleViewModel: jiggleViewModel,
                      jiggleDocument: jiggleDocument,
                      animationMode: animationMode)
        
    }
    
    @MainActor func handleJigglesDidChange(jiggleViewModel: JiggleViewModel,
                                           jiggleDocument: JiggleDocument,
                                           animationMode: AnimatonMode) {
        snapshot_pre(jiggleViewModel: jiggleViewModel,
                     jiggleDocument: jiggleDocument,
                     animationMode: animationMode)
        flushAnimusTouches_Orphaned(jiggleViewModel: jiggleViewModel,
                                    jiggleDocument: jiggleDocument)
        snapshot_post(jiggleViewModel: jiggleViewModel,
                      jiggleDocument: jiggleDocument,
                      animationMode: animationMode)
    }
    
    // Review notes:
    // We really want a way to force all the instructions
    // to un-drag as well... It's redundant, but it makes sense
    // For example, if we resulted in a fling, the fling should
    // be cancelled.
    @MainActor func handleDocumentModeDidChange(jiggleViewModel: JiggleViewModel,
                                                jiggleDocument: JiggleDocument,
                                                animationMode: AnimatonMode) {
        flushAll(jiggleViewModel: jiggleViewModel,
                 jiggleDocument: jiggleDocument,
                 animationMode: animationMode)
    }
    
    @MainActor func applicationWillResignActive(jiggleViewModel: JiggleViewModel,
                                                jiggleDocument: JiggleDocument,
                                                animationMode: AnimatonMode) {
        flushAll(jiggleViewModel: jiggleViewModel,
                 jiggleDocument: jiggleDocument,
                 animationMode: animationMode)
    }
    
    
    
    
    
    
    
    
    @MainActor func removeAnimusTouch(jiggleViewModel: JiggleViewModel,
                                      jiggleDocument: JiggleDocument,
                                      animusTouch: Animus2Touch,
                                      reason: Animus2TouchRemoveReason) -> Bool {
        
        if let aid = animusTouch.touchID {
            print("removeAnimusTouch @ \(animusTouch.touchID), reason = \(reason)")
        } else {
            print("FATAL: We housing unidentified touch...???")
        }
        
        let touchCount = animusTouchesCount(animusTouch)
        
        if touchCount > 1 {
            print("FATAL: We have a touch more than once...")
        }
        
        if touchCount <= 0 {
            print("FATAL: We are removing a touch that's not in the list?!?!")
            return false
        }
        
        
        
        // This should be the single point of where we
        // can stop a continuous grab...
        
        
        var numberRemoved = 0
        var removeLoopIndex = 0
        while removeLoopIndex < animusTouchCount {
            if animusTouches[removeLoopIndex] === animusTouch {
                break
            } else {
                removeLoopIndex += 1
            }
        }
        while removeLoopIndex < animusTouchCount {
            if animusTouches[removeLoopIndex] === animusTouch {
                numberRemoved += 1
            } else {
                animusTouches[removeLoopIndex - numberRemoved] = animusTouches[removeLoopIndex]
            }
            removeLoopIndex += 1
        }
        animusTouchCount -= numberRemoved
        
        
        
        
        
        if numberRemoved > 0 {
            
            // The touch will be out of *this* list...
            
            // Let's see if we were the final touch
            // from a continuous dragging effort...
            switch animusTouch.residency {
            case .unassigned:
                Animus2PartsFactory.shared.depositAnimusTouch(animusTouch)
            case .jiggleContinuous(let jiggle):
                Animus2PartsFactory.shared.depositAnimusTouch(animusTouch)
            case .jiggleGrab:
                purgatoryAnimusTouchesAdd(animusTouch)
            }
            
            return true
        } else {
            return false
        }
    }
    
}
