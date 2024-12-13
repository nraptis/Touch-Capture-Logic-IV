//
//  AnimusController+Flush.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/11/24.
//

import UIKit

extension AnimusController {
    
    //
    // [Touch Routes Verify] 12-10-2024
    // This looks to be right, there's never
    // a need to keep the old "clock" value!!
    //
    @MainActor func flushAll(jiggleViewModel: JiggleViewModel,
                             jiggleDocument: JiggleDocument,
                             animationMode: AnimatonMode) {
        snapshot_pre(jiggleViewModel: jiggleViewModel,
                     jiggleDocument: jiggleDocument,
                     animationMode: animationMode)
        flushPurgatoryAnimusTouches_All(jiggleViewModel: jiggleViewModel,
                                        jiggleDocument: jiggleDocument)
        flushAnimusTouches_All(jiggleViewModel: jiggleViewModel,
                               jiggleDocument: jiggleDocument)
        snapshot_post(jiggleViewModel: jiggleViewModel,
                      jiggleDocument: jiggleDocument,
                      animationMode: animationMode)
        clock = 0.0
    }
    
    //
    // [Touch Routes Verify] 12-11-2024
    // This looks to be right, there's never
    // a need to keep the old "clock" value!!
    //
    @MainActor func flushAllExpired(jiggleViewModel: JiggleViewModel,
                                    jiggleDocument: JiggleDocument,
                                    animationMode: AnimatonMode) {
        
        var isAnyTouchExpired = false
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            if animusTouch.isExpired {
                isAnyTouchExpired = true
            }
        }
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            let animusTouch = purgatoryAnimusTouches[animusTouchIndex]
            if animusTouch.isExpired {
                isAnyTouchExpired = true
            }
        }
        
        if isAnyTouchExpired {
            snapshot_pre(jiggleViewModel: jiggleViewModel,
                         jiggleDocument: jiggleDocument,
                         animationMode: animationMode)
            flushAnimusTouches_Expired(jiggleViewModel: jiggleViewModel,
                                       jiggleDocument: jiggleDocument)
            flushPurgatoryAnimusTouches_Expired(jiggleViewModel: jiggleViewModel,
                                                jiggleDocument: jiggleDocument)
            snapshot_post(jiggleViewModel: jiggleViewModel,
                          jiggleDocument: jiggleDocument,
                          animationMode: animationMode)
        }
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, no change needed.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func flushAnimusTouches_All(jiggleViewModel: JiggleViewModel,
                                           jiggleDocument: JiggleDocument) {
        
        tempAnimusTouchCount = 0
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            tempAnimusTouchesAdd(animusTouch)
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = removeAnimusTouch(jiggleViewModel: jiggleViewModel,
                                  jiggleDocument: jiggleDocument,
                                  animusTouch: animusTouch)
        }
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, no change needed.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    func flushPurgatoryAnimusTouches_All(jiggleViewModel: JiggleViewModel,
                                         jiggleDocument: JiggleDocument) {
        tempAnimusTouchCount = 0
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            let animusTouch = purgatoryAnimusTouches[animusTouchIndex]
            tempAnimusTouchesAdd(animusTouch)
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = purgatoryAnimusTouchesRemove(animusTouch)
        }
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, no change needed.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func flushAnimusTouches_Expired(jiggleViewModel: JiggleViewModel,
                                               jiggleDocument: JiggleDocument) {
        tempAnimusTouchCount = 0
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            if animusTouch.isExpired {
                tempAnimusTouchesAdd(animusTouch)
            }
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = removeAnimusTouch(jiggleViewModel: jiggleViewModel,
                                  jiggleDocument: jiggleDocument,
                                  animusTouch: animusTouch)
        }
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, no change needed.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    func flushPurgatoryAnimusTouches_Expired(jiggleViewModel: JiggleViewModel,
                                             jiggleDocument: JiggleDocument) {
        
        tempAnimusTouchCount = 0
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            let animusTouch = purgatoryAnimusTouches[animusTouchIndex]
            if animusTouch.isExpired {
                tempAnimusTouchesAdd(animusTouch)
            }
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = purgatoryAnimusTouchesRemove(animusTouch)
        }
        
    }
    
    
    // [Touch Routes Verify] 12-11-2024
    // This looks to be right, no change needed.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    @MainActor func flushAnimusTouches_TouchMatch(jiggleViewModel: JiggleViewModel,
                                                  jiggleDocument: JiggleDocument,
                                                  touches: [UITouch]) {
        
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
    }
    
    // [Touch Routes Verify] 12-10-2024
    // This looks to be right, just note the comment.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func flushPurgatoryAnimusTouches_TouchMatch(jiggleViewModel: JiggleViewModel,
                                                           jiggleDocument: JiggleDocument,
                                                           touches: [UITouch]) {
        
        tempAnimusTouchCount = 0
        for touchIndex in 0..<touches.count {
            let touch = touches[touchIndex]
            if let animusTouch = purgatoryAnimusTouchesFind(touch: touch) {
                if tempAnimusTouchesContainsTouch(animusTouch) == false {
                    tempAnimusTouchesAdd(animusTouch)
                }
            }
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = purgatoryAnimusTouchesRemove(animusTouch)
        }
    }
    
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, however, please
    // note. It hinges on "matchesMode" from residency...
    // So, we're assuming that is exactly right!!!
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func flushAnimusTouches_ModeMismatch(jiggleViewModel: JiggleViewModel,
                                                    jiggleDocument: JiggleDocument,
                                                    animationMode: AnimatonMode) {
        tempAnimusTouchCount = 0
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            if !animusTouch.residency.matchesMode(animationMode: animationMode,
                                                  includingUnassigned: true) {
                tempAnimusTouchesAdd(animusTouch)
            }
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = removeAnimusTouch(jiggleViewModel: jiggleViewModel,
                                  jiggleDocument: jiggleDocument,
                                  animusTouch: animusTouch)
        }
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, however, please
    // note. It hinges on "matchesMode" from residency...
    // So, we're assuming that is exactly right!!!
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func flushPurgatoryAnimusTouches_ModeMismatch(jiggleViewModel: JiggleViewModel,
                                                             jiggleDocument: JiggleDocument,
                                                             animationMode: AnimatonMode) {
        tempAnimusTouchCount = 0
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            let animusTouch = purgatoryAnimusTouches[animusTouchIndex]
            if !animusTouch.residency.matchesMode(animationMode: animationMode,
                                                  includingUnassigned: false) {
                tempAnimusTouchesAdd(animusTouch)
            }
        }
        
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            let animusTouch = tempAnimusTouches[animusTouchIndex]
            _ = purgatoryAnimusTouchesRemove(animusTouch)
        }
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, no change
    // should be needed, ever. Not ever.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func flushAnimusTouches_Orphaned(jiggleViewModel: JiggleViewModel,
                                                jiggleDocument: JiggleDocument) {
        tempAnimusTouchCount = 0
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous(let jiggle):
                if jiggleDocument.getJiggleIndex(jiggle) == nil {
                    tempAnimusTouchesAdd(animusTouch)
                }
            case .jiggleGrab(let jiggle):
                if jiggleDocument.getJiggleIndex(jiggle) == nil {
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
    }
    
}
