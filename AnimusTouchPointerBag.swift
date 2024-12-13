//
//  AnimusTouchPointerBag.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

import Foundation

class AnimusTouchPointerBag {
    
    static let DISABLE_POSITION = true
    static let DISABLE_SCALE = true
    static let DISABLE_ROTATION = false
    
    static let captureTrackDistanceThreshold = Float(8.0)
    static let captureTrackDistanceThresholdSquared = (captureTrackDistanceThreshold * captureTrackDistanceThreshold)
    
    typealias Point = Math.Point
    
    var touchPointerCount = 0
    var touchPointers = [AnimusTouchPointer]()
    
    var tempTouchPointerCount = 0
    var tempTouchPointers = [AnimusTouchPointer]()
    
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
            case .remove:
                _ = touchPointersRemove(touchPointer)
                print("(Remove) Pointer Bag, Remove: \(touchID)")
            default:
                break
            }
        }
    }
    
    let format: AnimusTouchFormat
    init(format: AnimusTouchFormat) {
        self.format = format
    }
    
    @MainActor func continuousRegisterAllStartValues(jiggle: Jiggle,
                                          jiggleDocument: JiggleDocument) {
        registerContinuousStartPosition(jiggle: jiggle,
                                        jiggleDocument: jiggleDocument)
        registerContinuousStartScale(jiggle: jiggle,
                                     jiggleDocument: jiggleDocument)
        registerContinuousStartRotation(jiggle: jiggle,
                                        jiggleDocument: jiggleDocument)
    }
    
    func sync_GatherFromAnimusTouches(jiggle: Jiggle, controller: AnimusController) {
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
                                controller: AnimusController,
                                command: AnimusTouchMemeCommand) {
        
        for chunkIndex in 0..<command.chunkCount {
            let chunk = command.chunks[chunkIndex]
            switch chunk {
            case .add(let commandChunktouchID, let x, let y):
                if let touchPointer = touchPointersFind(touchID: commandChunktouchID) {
                    
                    if AnimusController.INSANE_VERIFY {
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
                    if AnimusController.INSANE_VERIFY {
                        if controller.animusTouchesFind(touchID: commandChunktouchID) == nil {
                            print("Fatal: Inconsistent [C]: We're adding a pointer, which is not contained in the touch pointer bag or the animation controller...")
                        }
                    }
                    
                    let newTouchPointer = AnimusPartsFactory.shared.withdrawAnimusTouchPointer(touchID: commandChunktouchID)
                    newTouchPointer.actionType = .add(x, y)
                    newTouchPointer.x = x
                    newTouchPointer.y = y
                    touchPointersAdd(newTouchPointer)
                }
            case .remove(let commandChunktouchID):
                
                
                if AnimusController.INSANE_VERIFY {
                    if controller.animusTouchesFind(touchID: commandChunktouchID) != nil {
                        print("FATAL: [Remove A] We're removing a pointer, but it's contained in the animus controller. It could be the same pointer for 2 touches...")
                    }
                }
                
                if let touchPointer = touchPointersFind(touchID: commandChunktouchID) {
                    
                    if AnimusController.INSANE_VERIFY {
                        if !touchPointer.actionType.isDetachedOrRetained {
                            print("FATAL: [H3] We're assigning 2 commands (add case a) to the same pointer...")
                        }
                    }
                    
                    touchPointer.actionType = .remove
                    touchPointer.stationaryTime = 0.0
                    touchPointer.isExpired = false
                    
                } else {
                    if AnimusController.INSANE_VERIFY {
                        print("Fatal: Inconsistent [D]: We're removing a pointer, which doesn't exist in the pointer bag...")
                    }
                    
                    let newTouchPointer = AnimusPartsFactory.shared.withdrawAnimusTouchPointer(touchID: commandChunktouchID)
                    newTouchPointer.actionType = .remove
                    touchPointersAdd(newTouchPointer)
                }
            case .move(let commandChunktouchID, _, _, let x2, let y2):
                if let touchPointer = touchPointersFind(touchID: commandChunktouchID) {
                    
                    if AnimusController.INSANE_VERIFY {
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
                    if AnimusController.INSANE_VERIFY {
                        print("Fatal: Inconsistent [E]: We're moving a pointer, which doesn't exist in the pointer bag...")
                    }
                    let newTouchPointer = AnimusPartsFactory.shared.withdrawAnimusTouchPointer(touchID: commandChunktouchID)
                    newTouchPointer.actionType = .move(x2, y2)
                    newTouchPointer.x = x2
                    newTouchPointer.y = y2
                    touchPointersAdd(newTouchPointer)
                }
            }
        }
    }
    
    func sync(jiggle: Jiggle,
              controller: AnimusController,
              command: AnimusTouchMemeCommand,
              memeBag: AnimusTouchMemeBag) {
        
        if AnimusController.INSANE_VERIFY {
            
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
        
        if !isCaptureValid {
            return false
        }
        
        calculateConsiderTouchPointers()
        let avaragesResponse = getAverageOfValidTouchPointers()
        let averageX: Float
        let averageY: Float
        switch avaragesResponse {
        case .invalid:
            // In practice this doesn't happen, but if
            // it does, it just means the drag bliffs.
            // I've tested it with an invalid response
            // and it's not a life-ending thing. Nor
            // does it appear to even happen. Therefore,
            // this requires no more thought. It's fine!
            isCaptureValid = false
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

}
