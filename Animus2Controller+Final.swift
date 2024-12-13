//
//  Animus2Controller+Final.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import UIKit

extension Animus2Controller {
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // Chance that this could screw up!!!!!!!!!
    //
    func animusTouchesContainsTouch(_ animusTouch: Animus2Touch) -> Bool {
        for animusTouchIndex in 0..<animusTouchCount {
            if animusTouches[animusTouchIndex] === animusTouch {
                return true
            }
        }
        return false
    }
    
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // Chance that this could screw up!!!!!!!!!
    //
    func addAnimusTouch(animusTouch: Animus2Touch) {
        
        if Animus2Controller.INSANE_VERIFY {
            if animusTouchesContainsTouch(animusTouch) {
                print("FATAL ERROR: We're adding the same animus touch twice...")
            }
        }
        
        if Animus2Controller.INSANE_VERIFY {
            if purgatoryAnimusTouchesContainsTouch(animusTouch) {
                print("FATAL ERROR: We're adding the same animus touch which is in purgatory...")
            }
        }
        
        if Animus2Controller.INSANE_VERIFY {
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous:
                print("FATAL ERROR: We're adding a touch, which has residency => jiggleContinuous...")
            case .jiggleGrab:
                print("FATAL ERROR: We're adding a touch, which has residency => jiggleGrab...")
            }
        }
        
        while animusTouches.count <= animusTouchCount {
            animusTouches.append(animusTouch)
        }
        animusTouches[animusTouchCount] = animusTouch
        animusTouchCount += 1
    }
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // Chance that this could screw up!!!!!!!!!
    //
    func releaseAnimusTouchesContainsTouch(_ animusTouch: Animus2Touch) -> Bool {
        for animusTouchIndex in 0..<releaseAnimusTouchCount {
            if releaseAnimusTouches[animusTouchIndex] === animusTouch {
                return true
            }
        }
        return false
    }
    
    func purgatoryAnimusTouchesAdd(_ animusTouch: Animus2Touch) {
        
        if Animus2Controller.INSANE_VERIFY {
            if animusTouchesContainsTouch(animusTouch) {
                print("FATAL ERROR: We're adding the same purgatory touch twice...")
            }
        }
        
        if Animus2Controller.INSANE_VERIFY {
            if purgatoryAnimusTouchesContainsTouch(animusTouch) {
                print("FATAL ERROR: We're adding the same purgatory touch which is in regular touches...")
            }
        }
        
        if Animus2Controller.INSANE_VERIFY {
            switch animusTouch.residency {
            case .jiggleContinuous:
                print("FATAL ERROR: We're adding to purgatory a touch with residency of jiggleContinuous...")
            case .jiggleGrab:
                break
            case .unassigned:
                print("FATAL ERROR: We're adding to purgatory a touch with residency of unassigned...")
            }
        }
        
        while purgatoryAnimusTouches.count <= purgatoryAnimusTouchCount {
            purgatoryAnimusTouches.append(animusTouch)
        }
        purgatoryAnimusTouches[purgatoryAnimusTouchCount] = animusTouch
        purgatoryAnimusTouchCount += 1
    }
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // Chance that this could screw up!!!!!!!!!
    //
    func purgatoryAnimusTouchesContainsTouch(_ animusTouch: Animus2Touch) -> Bool {
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            if purgatoryAnimusTouches[animusTouchIndex] === animusTouch {
                return true
            }
        }
        return false
    }
    
    // [Touch Routes Verify] 12-9-2024
    //
    // Seems correct; I don't see any possible
    // problem with this one...
    //
    func purgatoryAnimusTouchesFind(touch: UITouch) -> Animus2Touch? {
        let touchObjectIdentifier = ObjectIdentifier(touch)
        return purgatoryAnimusTouchesFind(touchID: touchObjectIdentifier)
    }
    
    // [Touch Routes Verify] 12-9-2024
    //
    // Seems correct; I don't see any possible
    // problem with this one...
    //
    func purgatoryAnimusTouchesFind(touchID: ObjectIdentifier) -> Animus2Touch? {
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            if purgatoryAnimusTouches[animusTouchIndex].touchID == touchID {
                return purgatoryAnimusTouches[animusTouchIndex]
            }
        }
        return nil
    }
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // TODO: We don't even need this
    //
    func purgatoryAnimusTouchesCount(_ animusTouch: Animus2Touch) -> Int {
        var result = 0
        for animusTouchIndex in 0..<purgatoryAnimusTouchCount {
            if animusTouch === purgatoryAnimusTouches[animusTouchIndex] {
                result += 1
            }
        }
        return result
    }
    
    // [Touch Routes Verify] 12-8-2024
    //
    // Seems correct; I don't see any possible
    //
    func purgatoryAnimusTouchesRemove(_ animusTouch: Animus2Touch) -> Bool {
        
        if Animus2Controller.INSANE_VERIFY {
            
            let touchCount = purgatoryAnimusTouchesCount(animusTouch)
            
            if touchCount > 1 {
                print("FATAL: We have a Purgatory touch more than once...")
            }
            
            if touchCount <= 0 {
                print("FATAL: We are removing a Purgatory touch that's not in the list?!?!")
                return false
            }
        }
        
        var numberRemoved = 0
        var removeLoopIndex = 0
        while removeLoopIndex < purgatoryAnimusTouchCount {
            if purgatoryAnimusTouches[removeLoopIndex] === animusTouch {
                break
            } else {
                removeLoopIndex += 1
            }
        }
        while removeLoopIndex < purgatoryAnimusTouchCount {
            if purgatoryAnimusTouches[removeLoopIndex] === animusTouch {
                numberRemoved += 1
            } else {
                purgatoryAnimusTouches[removeLoopIndex - numberRemoved] = purgatoryAnimusTouches[removeLoopIndex]
            }
            removeLoopIndex += 1
        }
        purgatoryAnimusTouchCount -= numberRemoved
        
        if numberRemoved > 0 {
            Animus2PartsFactory.shared.depositAnimusTouch(animusTouch)
            return true
        } else {
            return false
        }
    }
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // TODO: We don't even need this
    //
    func animusTouchesCount(_ animusTouch: Animus2Touch) -> Int {
        var result = 0
        for animusTouchIndex in 0..<animusTouchCount {
            if animusTouch === animusTouches[animusTouchIndex] {
                result += 1
            }
        }
        return result
    }
    
    func animusTouchesCount(jiggle: Jiggle, format: AnimusTouchFormat) -> Int {
        var result = 0
        for animusTouchIndex in 0..<animusTouchCount {
            let animusTouch = animusTouches[animusTouchIndex]
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous(let residencyJiggle):
                if residencyJiggle === jiggle {
                    switch format {
                    case .grab:
                        break
                    case .continuous:
                        result += 1
                    }
                }
            case .jiggleGrab(let residencyJiggle):
                if residencyJiggle === jiggle {
                    switch format {
                    case .grab:
                        result += 1
                    case .continuous:
                        break
                    }
                }
            }
        }
        return result
    }
    
    func releaseAnimusTouchesAddUnique(_ animusTouch: Animus2Touch) {
        if releaseAnimusTouchesContainsTouch(animusTouch) == false {
            
            while releaseAnimusTouches.count <= releaseAnimusTouchCount {
                releaseAnimusTouches.append(animusTouch)
            }
            releaseAnimusTouches[releaseAnimusTouchCount] = animusTouch
            releaseAnimusTouchCount += 1
        }
    }
    
    
    
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // TODO: We can remove the "insane verify" after March
    //
    func tempAnimusTouchesAdd(_ animusTouch: Animus2Touch) {
        if Animus2Controller.INSANE_VERIFY {
            if tempAnimusTouchesContainsTouch(animusTouch) {
                print("FATAL ERROR: We're adding the same temp touch twice...")
            }
        }
        
        while tempAnimusTouches.count <= tempAnimusTouchCount {
            tempAnimusTouches.append(animusTouch)
        }
        tempAnimusTouches[tempAnimusTouchCount] = animusTouch
        tempAnimusTouchCount += 1
    }
    
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // problem with this one...
    //
    func tempAnimusTouchesContainsTouch(_ animusTouch: Animus2Touch) -> Bool {
        for animusTouchIndex in 0..<tempAnimusTouchCount {
            if tempAnimusTouches[animusTouchIndex] === animusTouch {
                return true
            }
        }
        return false
    }
    
    // [Touch Routes Verify] 12-7-2024
    //
    // Seems correct; I don't see any possible
    // problem with this one...
    //
    func animusTouchesFind(touch: UITouch) -> Animus2Touch? {
        let touchObjectIdentifier = ObjectIdentifier(touch)
        return animusTouchesFind(touchID: touchObjectIdentifier)
    }
    
    // [Touch Routes Verify] 12-8-2024
    //
    // Seems correct; I don't see any possible
    // problem with this one...
    //
    func animusTouchesFind(touchID: ObjectIdentifier) -> Animus2Touch? {
        for animusTouchIndex in 0..<animusTouchCount {
            if animusTouches[animusTouchIndex].touchID == touchID {
                return animusTouches[animusTouchIndex]
            }
        }
        return nil
    }
    
    
    // [Touch Routes Verify] 12-7-2024
    //
    // We've explored both alternatives.
    // 1.) Only Recording history for a linked touch.
    // 2.) Recording history for all the touches.
    //
    func recordHistoryForTouches(touches: [UITouch]) {
        for touchIndex in 0..<touches.count {
            let touch = touches[touchIndex]
            if let animusTouch = animusTouchesFind(touch: touch) {
                animusTouch.recordHistory(clock: clock)
            }
        }
    }
    
    // [Touch Routes Verify] 12-7-2024
    //
    // We attempt to link every unassigned
    // touch based on the animaton mode.
    //
    @MainActor func linkAnimusTouches(jiggleViewModel: JiggleViewModel,
                                      jiggleDocument: JiggleDocument,
                                      animationMode: AnimatonMode,
                                      displayMode: DisplayMode,
                                      isGraphEnabled: Bool,
                                      touchTargetTouchSource: TouchTargetTouchSource,
                                      isPrecise: Bool) {
        
        switch animationMode {
        case .unknown:
            // [Touch Routes Verify] 12-7-2024
            // We will never link a touch for "unknown" animation mode.
            break
        case .grab:
            // [Touch Routes Verify] 12-7-2024
            // In the case that we are in grab mode...
            
            // We loop through all the touches...
            for animusTouchIndex in 0..<animusTouchCount {
                let animusTouch = animusTouches[animusTouchIndex]
                
                // If the touch is unassigned, we
                // attempt to link it to "grab" mode...
                switch animusTouch.residency {
                case .unassigned:
                    _ = attemptLinkingTouchToJiggle_Grab(animusTouch: animusTouch,
                                                          jiggleViewModel: jiggleViewModel,
                                                          jiggleDocument: jiggleDocument,
                                                          displayMode: displayMode,
                                                          isGraphEnabled: isGraphEnabled,
                                                          touchTargetTouchSource: touchTargetTouchSource,
                                                          isPrecise: isPrecise)
                default:
                    break
                }
            }
            
        case .continuous:
            // [Touch Routes Verify] 12-7-2024
            // In the case that we are in continuous mode...
            
            // We loop through all the touches...
            for animusTouchIndex in 0..<animusTouchCount {
                let animusTouch = animusTouches[animusTouchIndex]
                
                // If the touch is unassigned, we
                // attempt to link it to "continuous" mode...
                switch animusTouch.residency {
                case .unassigned:
                    _ = attemptLinkingTouchToJiggle_Continuous(animusTouch: animusTouch,
                                                                jiggleViewModel: jiggleViewModel,
                                                                jiggleDocument: jiggleDocument,
                                                                displayMode: displayMode,
                                                                isGraphEnabled: isGraphEnabled,
                                                                touchTargetTouchSource: touchTargetTouchSource,
                                                                isPrecise: isPrecise)
                    
                default:
                    break
                }
            }
        case .loops:
            // [Touch Routes Verify] 12-7-2024
            // We will never link a touch for "loops" animation mode.
            break
        }
    }
    
    
    
    
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, we share logic.
    @MainActor func handleAnimationModeDidChange(jiggleViewModel: JiggleViewModel,
                                                 jiggleDocument: JiggleDocument,
                                                 animationMode: AnimatonMode) {
        handleDocumentModeDidChange(jiggleViewModel: jiggleViewModel,
                                    jiggleDocument: jiggleDocument,
                                    animationMode: animationMode)
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, note the usage.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func attemptLinkingTouchToJiggle_Grab(animusTouch: Animus2Touch,
                                                     jiggleViewModel: JiggleViewModel,
                                                     jiggleDocument: JiggleDocument,
                                                     displayMode: DisplayMode,
                                                     isGraphEnabled: Bool,
                                                     touchTargetTouchSource: TouchTargetTouchSource,
                                                     isPrecise: Bool) -> Bool {
        if Animus2Controller.INSANE_VERIFY {
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous:
                print("Fatal Error: Trying to link Continuous to Grab...")
                return false
            case .jiggleGrab:
                print("Fatal Error: Trying to link Grab to Grab...")
                return false
            }
        }
        
        if let indexOfJiggleToSelect = jiggleDocument.getIndexOfJiggleToSelect(points: [animusTouch.point],
                                                                               includingFrozen: true,
                                                                               touchTargetTouchSource: touchTargetTouchSource) {
            if let jiggle = jiggleDocument.getJiggle(indexOfJiggleToSelect) {
                animusTouch.linkToResidency(residency: .jiggleGrab(jiggle))
                jiggleDocument.switchSelectedJiggle(newSelectedJiggleIndex: indexOfJiggleToSelect,
                                                    displayMode: displayMode,
                                                    isGraphEnabled: isGraphEnabled,
                                                    isPrecise: isPrecise)
                return true
            }
        }
        return false
    }
    
    // [Touch Routes Verify] 12-9-2024
    // This looks to be right, note the usage.
    //
    // Usage note: This *MUST* be called in the following manner:
    // 1.) snapshot_pre(...)
    // 2.) *THIS*
    // 3.) snapshot_post(...)
    //
    @MainActor func attemptLinkingTouchToJiggle_Continuous(animusTouch: Animus2Touch,
                                                           jiggleViewModel: JiggleViewModel,
                                                           jiggleDocument: JiggleDocument,
                                                           displayMode: DisplayMode,
                                                           isGraphEnabled: Bool,
                                                           touchTargetTouchSource: TouchTargetTouchSource,
                                                           isPrecise: Bool) -> Bool {
        
        if Animus2Controller.INSANE_VERIFY {
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous:
                print("Fatal Error: Trying to link Continuous to Continuous...")
                return false
            case .jiggleGrab:
                print("Fatal Error: Trying to link Grab to Continuous...")
                return false
            }
        }
        
        if let indexOfJiggleToSelect = jiggleDocument.getIndexOfJiggleToSelect(points: [animusTouch.point],
                                                                               includingFrozen: true,
                                                                               touchTargetTouchSource: touchTargetTouchSource) {
            if let jiggle = jiggleDocument.getJiggle(indexOfJiggleToSelect) {
                animusTouch.linkToResidency(residency: .jiggleContinuous(jiggle))
                jiggleDocument.switchSelectedJiggle(newSelectedJiggleIndex: indexOfJiggleToSelect,
                                                    displayMode: displayMode,
                                                    isGraphEnabled: isGraphEnabled,
                                                    isPrecise: isPrecise)
                return true
            }
        }
        return false
    }
    
    
    
    
    
}
