//
//  Animus2TouchPointerBag.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

import Foundation

class Animus2TouchPointerBag {
    
    static let DISABLE_POSITION = true
    static let DISABLE_SCALE = true
    static let DISABLE_ROTATION = false
    
    static let captureTrackDistanceThreshold = Float(8.0)
    static let captureTrackDistanceThresholdSquared = (captureTrackDistanceThreshold * captureTrackDistanceThreshold)
    
    typealias Point = Math.Point
    
    var touchPointerCount = 0
    var touchPointers = [Animus2TouchPointer]()
    
    var tempTouchPointerCount = 0
    var tempTouchPointers = [Animus2TouchPointer]()
    
    var objectIdentifiers = [ObjectIdentifier]()
    var objectIdentifierCount = 0
    
    var isCaptureValid = false
    
    // Position Tracking
    var captureStartAverageTouchPointerPosition = Point(x: 0.0, y: 0.0)
    var captureStartJiggleAnimationCursorPosition = Point(x: 0.0, y: 0.0)
    var captureStartCursorFalloffDistance_R1 = Float(0.0)
    var captureStartCursorFalloffDistance_R2 = Float(0.0)
    var captureStartCursorFalloffDistance_R3 = Float(0.0)
    
    // Scale Tracking
    var captureStartJiggleAnimationCursorScale = Float(1.0)
    var captureStartCursorFalloffScale_U1 = Float(0.0)
    var captureStartCursorFalloffScale_U2 = Float(0.0)
    var captureStartCursorFalloffScale_U3 = Float(0.0)
    var captureStartCursorFalloffScale_D1 = Float(0.0)
    var captureStartCursorFalloffScale_D2 = Float(0.0)
    var captureStartCursorFalloffScale_D3 = Float(0.0)
    
    // Rotation Tracking
    var captureStartJiggleAnimationCursorRotation = Float(0.0)
    var captureStartCursorFalloffRotation_U1 = Float(0.0)
    var captureStartCursorFalloffRotation_U2 = Float(0.0)
    var captureStartCursorFalloffRotation_U3 = Float(0.0)
    var captureStartCursorFalloffRotation_D1 = Float(0.0)
    var captureStartCursorFalloffRotation_D2 = Float(0.0)
    var captureStartCursorFalloffRotation_D3 = Float(0.0)
    
    
    func removePointersForTouchIfRemove(touchID: ObjectIdentifier) {
        
        tempTouchPointerCount = 0
        for pointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[pointerIndex]
            if touchPointer.touchID == touchID {
                tempTouchPointersAdd(touchPointer)
            }
        }
        
        for pointerIndex in 0..<tempTouchPointerCount {
            let touchPointer = tempTouchPointers[pointerIndex]
            switch touchPointer.actionType {
            case .detached:
                _ = touchPointersRemove(touchPointer)
                print("(Detached) Pointer Bag, Remove: \(touchID)")
            case .retained(_, _):
                print("(Retained) Pointer Bag, NOT Remove: \(touchID)")
                break
            case .add(_, _):
                print("(Add) Pointer Bag, NOT Remove: \(touchID)")
                break
            case .remove:
                _ = touchPointersRemove(touchPointer)
                print("(Remove) Pointer Bag, Remove: \(touchID)")
            case .move(_, _):
                print("(Move) Pointer Bag, NOT Remove: \(touchID)")
                break
            }
            
        }
        
    }
    
    let format: AnimusTouchFormat
    init(format: AnimusTouchFormat) {
        self.format = format
    }
    
    func sync_GatherFromAnimusTouches(jiggle: Jiggle, controller: Animus2Controller) {
        for animusTouchIndex in 0..<controller.animusTouchCount {
            let animusTouch = controller.animusTouches[animusTouchIndex]
            guard let touchID = animusTouch.touchID else {
                print("Fatal Error: Syncing animus touch with no touchID to pointer bag...!!!")
                continue
            }
            
            switch animusTouch.residency {
            case .unassigned:
                break
            case .jiggleContinuous(let residencyJiggle):
                if residencyJiggle === jiggle {
                    switch format {
                    case .grab:
                        break
                    case .continuous:
                        if let touchPointer = touchPointersFind(touchID: touchID) {
                            touchPointer.actionType = .retained(animusTouch.x, animusTouch.y)
                            touchPointer.stationaryTime = 0.0
                            touchPointer.isExpired = false
                        }
                    }
                }
            case .jiggleGrab(let residencyJiggle):
                if residencyJiggle === jiggle {
                    switch format {
                    case .grab:
                        if let touchPointer = touchPointersFind(touchID: touchID) {
                            touchPointer.actionType = .retained(animusTouch.x, animusTouch.y)
                            touchPointer.stationaryTime = 0.0
                            touchPointer.isExpired = false
                        }
                    case .continuous:
                        break
                    }
                }
            }
        }
    }
    
    func sync_gatherFromCommand(jiggle: Jiggle,
                                controller: Animus2Controller,
                                command: Animus2TouchMemeCommand) {
        
        for chunkIndex in 0..<command.chunkCount {
            let chunk = command.chunks[chunkIndex]
            switch chunk {
            case .add(let commandChunktouchID, let x, let y):
                if let touchPointer = touchPointersFind(touchID: commandChunktouchID) {
                    
                    if Animus2Controller.INSANE_VERIFY {
                        if !touchPointer.actionType.isDetachedOrRetained {
                            print("FATAL: [H1] We're assigning 2 commands (add case a) to the same pointer...")
                        }
                    }
                    
                    // In this case, the UITouch has the exact
                    // same memory address as a previous touch.
                    // which we are still holding on to. We're
                    // then simply over-writing this touch.
                    
                    touchPointer.actionType = .add(x, y)
                    touchPointer.x = x
                    touchPointer.y = y
                    touchPointer.stationaryTime = 0.0
                    touchPointer.isExpired = false
                    
                } else {
                    if Animus2Controller.INSANE_VERIFY {
                        if controller.animusTouchesFind(touchID: commandChunktouchID) == nil {
                            print("Fatal: Inconsistent [C]: We're adding a pointer, which is not contained in the touch pointer bag or the animation controller...")
                        }
                    }
                    
                    let newTouchPointer = Animus2PartsFactory.shared.withdrawAnimusTouchPointer(touchID: commandChunktouchID)
                    newTouchPointer.actionType = .add(x, y)
                    newTouchPointer.x = x
                    newTouchPointer.y = y
                    touchPointersAdd(newTouchPointer)
                }
            case .remove(let commandChunktouchID):
                
                
                if Animus2Controller.INSANE_VERIFY {
                    if controller.animusTouchesFind(touchID: commandChunktouchID) != nil {
                        print("FATAL: [Remove A] We're removing a pointer, but it's contained in the animus controller. It could be the same pointer for 2 touches...")
                    }
                }
                
                if let touchPointer = touchPointersFind(touchID: commandChunktouchID) {
                    
                    if Animus2Controller.INSANE_VERIFY {
                        if !touchPointer.actionType.isDetachedOrRetained {
                            print("FATAL: [H3] We're assigning 2 commands (add case a) to the same pointer...")
                        }
                    }
                    
                    touchPointer.actionType = .remove
                    touchPointer.stationaryTime = 0.0
                    touchPointer.isExpired = false
                    
                } else {
                    if Animus2Controller.INSANE_VERIFY {
                        print("Fatal: Inconsistent [D]: We're removing a pointer, which doesn't exist in the pointer bag...")
                    }
                    
                    let newTouchPointer = Animus2PartsFactory.shared.withdrawAnimusTouchPointer(touchID: commandChunktouchID)
                    newTouchPointer.actionType = .remove
                    touchPointersAdd(newTouchPointer)
                }
            case .move(let commandChunktouchID, _, _, let x2, let y2):
                if let touchPointer = touchPointersFind(touchID: commandChunktouchID) {
                    
                    if Animus2Controller.INSANE_VERIFY {
                        if !touchPointer.actionType.isDetachedOrRetained {
                            print("FATAL: [H5] We're assigning 2 commands (move case a) to the same pointer...")
                        }
                    }
                    
                    touchPointer.actionType = .move(x2, y2)
                    touchPointer.x = x2
                    touchPointer.y = y2
                    touchPointer.stationaryTime = 0.0
                    touchPointer.isExpired = false
                    
                } else {
                    if Animus2Controller.INSANE_VERIFY {
                        print("Fatal: Inconsistent [E]: We're moving a pointer, which doesn't exist in the pointer bag...")
                    }
                    let newTouchPointer = Animus2PartsFactory.shared.withdrawAnimusTouchPointer(touchID: commandChunktouchID)
                    newTouchPointer.actionType = .move(x2, y2)
                    newTouchPointer.x = x2
                    newTouchPointer.y = y2
                    touchPointersAdd(newTouchPointer)
                }
            }
        }
    }
    
    func sync(jiggle: Jiggle,
              controller: Animus2Controller,
              command: Animus2TouchMemeCommand,
              memeBag: Animus2TouchMemeBag) {
        
        if Animus2Controller.INSANE_VERIFY {
            
            // A scenario that makes no sense:
            
            for animusTouchIndex in 0..<controller.animusTouchCount {
                let animusTouch = controller.animusTouches[animusTouchIndex]
                guard let touchID = animusTouch.touchID else { continue }
                
                switch animusTouch.residency {
                case .unassigned:
                    break
                case .jiggleContinuous(let residencyJiggle):
                    if residencyJiggle === jiggle {
                        switch format {
                        case .grab:
                            break
                        case .continuous:
                            if touchPointersFind(touchID: touchID) === nil {
                                
                                // In this case, we need an add command with the meme BEFORE any other command...
                                for cmdIndex in 0..<memeBag.memeCommandCount {
                                    let mmc = memeBag.memeCommands[cmdIndex]
                                    switch mmc.type {
                                    case .add:
                                        if mmc.containsTouch(touchID: touchID) {
                                            break
                                        }
                                    case .remove:
                                        if mmc.containsTouch(touchID: touchID) {
                                            print("FATAL: Inconsistent [B]: The touch pointer should NOT exist in the command.")
                                            memeBag.printMemes()
                                            memeBag.printCommands()
                                        }
                                    case .move:
                                        if mmc.containsTouch(touchID: touchID) {
                                            print("FATAL: Inconsistent [B]: The touch pointer should NOT exist in the command.")
                                            memeBag.printMemes()
                                            memeBag.printCommands()
                                        }
                                    }
                                }
                            }
                        }
                    }
                case .jiggleGrab(let residencyJiggle):
                    if residencyJiggle === jiggle {
                        switch format {
                        case .grab:
                            if touchPointersFind(touchID: touchID) === nil {
                                
                                // In this case, we need an add command with the meme BEFORE any other command...
                                for cmdIndex in 0..<memeBag.memeCommandCount {
                                    let mmc = memeBag.memeCommands[cmdIndex]
                                    switch mmc.type {
                                    case .add:
                                        if mmc.containsTouch(touchID: touchID) {
                                            break
                                        }
                                    case .remove:
                                        if mmc.containsTouch(touchID: touchID) {
                                            print("FATAL: Inconsistent [B]: The touch pointer should NOT exist in the command.")
                                            memeBag.printMemes()
                                            memeBag.printCommands()
                                        }
                                    case .move:
                                        if mmc.containsTouch(touchID: touchID) {
                                            print("FATAL: Inconsistent [B]: The touch pointer should NOT exist in the command.")
                                            memeBag.printMemes()
                                            memeBag.printCommands()
                                        }
                                    }
                                }
                            }
                        case .continuous:
                            break
                        }
                    }
                }
            }
        }
        
        sync_DetachAllTouchPointers()
        
        sync_GatherFromAnimusTouches(jiggle: jiggle,
                                     controller: controller)
        
        sync_gatherFromCommand(jiggle: jiggle,
                               controller: controller,
                               command: command)
        
    }
    
    func captureStart(jiggle: Jiggle) -> Bool {
        
        calculateConsiderTouchPointers()
        let avaragesResponse = getAverageOfValidTouchPointers()
        
        let averageX: Float
        let averageY: Float
        switch avaragesResponse {
        case .invalid:
            isCaptureValid = false
            return false
        case .valid(let point):
            isCaptureValid = true
            averageX = point.x
            averageY = point.y
        }
        
        captureStart_Position(jiggle: jiggle,
                              cursorX: jiggle.animationCursorX,
                              cursorY: jiggle.animationCursorY,
                              averageX: averageX,
                              averageY: averageY)
        captureStart_PrepareScale(jiggle: jiggle,
                                  averageX: averageX,
                                  averageY: averageY)
        captureStart_Scale(jiggle: jiggle,
                           scale: jiggle.animationCursorScale)
        captureStart_PrepareRotate(jiggle: jiggle,
                                   averageX: averageX,
                                   averageY: averageY)
        captureStart_Rotate(jiggle: jiggle,
                            rotation: jiggle.animationCursorRotation)
        return true
    }
    
    @MainActor func captureTrack(jiggle: Jiggle,
                                 jiggleDocument: JiggleDocument) -> Bool {
        
        if !isCaptureValid { return false }
        
        calculateConsiderTouchPointers()
        let avaragesResponse = getAverageOfValidTouchPointers()
        
        let averageX: Float
        let averageY: Float
        switch avaragesResponse {
        case .invalid:
            isCaptureValid = false
            print("FATAL: The capture is not valid... This is on \"move\" so it shouldn't happen!")
            return false
        case .valid(let point):
            averageX = point.x
            averageY = point.y
        }
        
        captureTrack_Position(jiggle: jiggle,
                              jiggleDocument: jiggleDocument,
                              averageX: averageX,
                              averageY: averageY)
        
        let scaleResponse = captureTrack_PrepareScale(jiggle: jiggle,
                                                      averageX: averageX,
                                                      averageY: averageY)
        
        switch scaleResponse {
            
        case .invalid:
            break
        case .valid(let scaleData):
            captureTrack_Scale(jiggle: jiggle,
                               jiggleDocument: jiggleDocument,
                               scaleData: scaleData,
                               averageX: averageX,
                               averageY: averageY)
        }
        
        let rotateResponse = captureTrack_PrepareRotate(jiggle: jiggle, averageX: averageX,
                                                        averageY: averageY)
        if rotateResponse {
            captureTrack_Rotate(jiggle: jiggle,
                                jiggleDocument: jiggleDocument,
                                averageX: averageX,
                                averageY: averageY)
        }
        
        return true
    }
    
    func update(deltaTime: Float) {
        
        tempTouchPointerCount = 0
        for pointerIndex in 0..<touchPointerCount {
            let pointer = touchPointers[pointerIndex]
            pointer.update(deltaTime: deltaTime)
            if pointer.isExpired {
                tempTouchPointersAdd(pointer)
            }
        }
        
        for pointerIndex in 0..<tempTouchPointerCount {
            let pointer = tempTouchPointers[pointerIndex]
            _ = touchPointersRemove(pointer)
        }
    }
    
    func touchPointersAdd(_ pointer: Animus2TouchPointer) {
        if Animus2Controller.INSANE_VERIFY {
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
    
    
    func touchPointersCount(_ pointer: Animus2TouchPointer) -> Int {
        var result = 0
        for pointerIndex in 0..<touchPointerCount {
            if pointer === touchPointers[pointerIndex] {
                result += 1
            }
        }
        return result
    }
    
    func touchPointersRemove(_ pointer: Animus2TouchPointer) -> Bool {
        
        if Animus2Controller.INSANE_VERIFY {
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
        
        if numberRemoved > 0 {
            Animus2PartsFactory.shared.depositAnimusTouchPointer(pointer)
            return true
        } else {
            return false
        }
    }
    
    func tempTouchPointersAdd(_ pointer: Animus2TouchPointer) {
        if Animus2Controller.INSANE_VERIFY {
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
    
    func tempTouchPointersContains(_ pointer: Animus2TouchPointer) -> Bool {
        for pointerIndex in 0..<tempTouchPointerCount {
            if tempTouchPointers[pointerIndex] === pointer {
                return true
            }
        }
        return false
    }
    
    
    // [Touch Routes Verify] 12-12-2024
    //
    // Seems correct; I don't see any possible
    // Chance that this could screw up!!!!!!!!!
    //
    func addObjectIdentifierUnique(objectIdentifier: ObjectIdentifier) {
        if !objectIdentifiersContains(objectIdentifier) {
            while objectIdentifiers.count <= objectIdentifierCount {
                objectIdentifiers.append(objectIdentifier)
            }
            objectIdentifiers[objectIdentifierCount] = objectIdentifier
            objectIdentifierCount += 1
        }
    }
    
    // [Touch Routes Verify] 12-12-2024
    //
    // Seems correct; I don't see any possible
    // Chance that this could screw up!!!!!!!!!
    //
    func objectIdentifiersContains(_ objectIdentifier: ObjectIdentifier) -> Bool {
        for objectIdentifierIndex in 0..<objectIdentifierCount {
            if objectIdentifiers[objectIdentifierIndex] == objectIdentifier {
                return true
            }
        }
        return false
    }
    
    // [Touch Routes Verify] 12-12-2024
    //
    // Seems correct; I don't see any possible
    // Chance that this could screw up!!!!!!!!!
    //
    func removeObjectIdentifier(objectIdentifier: ObjectIdentifier) -> Bool {
        var numberRemoved = 0
        var removeLoopIndex = 0
        while removeLoopIndex < objectIdentifierCount {
            if objectIdentifiers[removeLoopIndex] == objectIdentifier {
                break
            } else {
                removeLoopIndex += 1
            }
        }
        while removeLoopIndex < objectIdentifierCount {
            if objectIdentifiers[removeLoopIndex] == objectIdentifier {
                numberRemoved += 1
            } else {
                objectIdentifiers[removeLoopIndex - numberRemoved] = objectIdentifiers[removeLoopIndex]
            }
            removeLoopIndex += 1
        }
        objectIdentifierCount -= numberRemoved
        
        if numberRemoved > 0 {
            
            return true
        } else {
            return false
        }
    }
    
}
