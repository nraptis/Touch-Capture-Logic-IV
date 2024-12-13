//
//  AnimusPartsFactory.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import UIKit

class AnimusPartsFactory {
    
    nonisolated(unsafe) static let shared = AnimusPartsFactory()
    
    private init() {
        
    }
    
    ////////////////
    ///
    ///
    private var animusTouches = [AnimusTouch]()
    var animusTouchCount = 0
    func depositAnimusTouch(_ animusTouch: AnimusTouch) {
        
        if AnimusController.INSANE_VERIFY {
            for checkIndex in 0..<animusTouchCount {
                if animusTouches[checkIndex] === animusTouch {
                    print("FATAL!!! The same touch was added to AnimusPartsFactory twice...")
                    fatalError("WOWOWOWOWOW????")
                }
            }
        }
        
        animusTouch.touchID = nil
        animusTouch.history.clearHistory()
        animusTouch.stationaryTime = .zero
        animusTouch.residency = .unassigned
        animusTouch.isExpired = false
        
        while animusTouches.count <= animusTouchCount {
            animusTouches.append(animusTouch)
        }
        animusTouches[animusTouchCount] = animusTouch
        animusTouchCount += 1
    }
    
    func withdrawAnimusTouch(touch: UITouch) -> AnimusTouch {
        if animusTouchCount > 0 {
            animusTouchCount -= 1
            let result = animusTouches[animusTouchCount]
            result.touchID = ObjectIdentifier(touch)
            return result
        }
        let result = AnimusTouch()
        result.touchID = ObjectIdentifier(touch)
        return result
    }
    ///
    ///
    ////////////////
    
    
    
    ////////////////
    ///
    ///
    private var animusTouchMemes = [AnimusTouchMeme]()
    var animusTouchMemeCount = 0
    func depositAnimusTouchMeme(_ animusTouchMeme: AnimusTouchMeme) {
        if AnimusController.INSANE_VERIFY {
            for checkIndex in 0..<animusTouchMemeCount {
                if animusTouchMemes[checkIndex] === animusTouchMeme {
                    print("FATAL!!! The same meme was added to AnimusPartsFactory twice...")
                    fatalError("WOWOWOWOWOW????")
                }
            }
        }
        
        while animusTouchMemes.count <= animusTouchMemeCount {
            animusTouchMemes.append(animusTouchMeme)
        }
        animusTouchMemes[animusTouchMemeCount] = animusTouchMeme
        animusTouchMemeCount += 1
    }
    
    func withdrawAnimusTouchMeme(touchID: ObjectIdentifier,
                                 x: Float,
                                 y: Float) -> AnimusTouchMeme {
        if animusTouchMemeCount > 0 {
            animusTouchMemeCount -= 1
            let result = animusTouchMemes[animusTouchMemeCount]
            result.touchID = touchID
            result.x = x
            result.y = y
            return result
        }
        let result = AnimusTouchMeme(x: x,
                                      y: y,
                                      touchID: touchID)
        return result
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var animusTouchMemeCommands = [AnimusTouchMemeCommand]()
    var animusTouchMemeCommandCount = 0
    func depositAnimusTouchMemeCommand(_ animusTouchMemeCommand: AnimusTouchMemeCommand) {
        if AnimusController.INSANE_VERIFY {
            for checkIndex in 0..<animusTouchMemeCommandCount {
                if animusTouchMemeCommands[checkIndex] === animusTouchMemeCommand {
                    print("FATAL!!! The same MemeCommand was added to AnimusPartsFactory twice...")
                    fatalError("WOWOWOWOWOW????")
                }
            }
        }
        
        while animusTouchMemeCommands.count <= animusTouchMemeCommandCount {
            animusTouchMemeCommands.append(animusTouchMemeCommand)
        }
        animusTouchMemeCommands[animusTouchMemeCommandCount] = animusTouchMemeCommand
        animusTouchMemeCommandCount += 1
    }
    
    func withdrawAnimusTouchMemeCommand() -> AnimusTouchMemeCommand {
        if animusTouchMemeCommandCount > 0 {
            animusTouchMemeCommandCount -= 1
            let result = animusTouchMemeCommands[animusTouchMemeCommandCount]
            return result
        }
        let result = AnimusTouchMemeCommand()
        return result
    }
    ///
    ///
    ////////////////

    
    ////////////////
    ///
    ///
    private var animusTouchPointers = [AnimusTouchPointer]()
    var animusTouchPointerCount = 0
    func depositAnimusTouchPointer(_ animusTouchPointer: AnimusTouchPointer) {
        if AnimusController.INSANE_VERIFY {
            for checkIndex in 0..<animusTouchPointerCount {
                if animusTouchPointers[checkIndex] === animusTouchPointer {
                    print("FATAL!!! The same Pointer was added to AnimusPartsFactory twice...")
                    fatalError("WOWOWOWOWOW????")
                }
            }
        }
        
        animusTouchPointer.isExpired = false
        animusTouchPointer.stationaryTime = .zero
        animusTouchPointer.actionType = .detached
        animusTouchPointer.isConsidered = false
        animusTouchPointer.isCaptureStartScaleValid = false
        animusTouchPointer.isCaptureStartRotateValid = false
        
        while animusTouchPointers.count <= animusTouchPointerCount {
            animusTouchPointers.append(animusTouchPointer)
        }
        animusTouchPointers[animusTouchPointerCount] = animusTouchPointer
        animusTouchPointerCount += 1
    }
    
    func withdrawAnimusTouchPointer(touchID: ObjectIdentifier) -> AnimusTouchPointer {
        if animusTouchPointerCount > 0 {
            animusTouchPointerCount -= 1
            let result = animusTouchPointers[animusTouchPointerCount]
            result.touchID = touchID
            return result
        }
        let result = AnimusTouchPointer(touchID: touchID)
        return result
    }
    ///
    ///
    ////////////////
    
    
}
