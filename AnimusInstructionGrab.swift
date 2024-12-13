//
//  AnimusInstructionGrab.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import Foundation

class AnimusInstructionGrab {
    
    // No knowledge of meme bag.
    // It operates on a command, and the list of active touches...
    let pointerBag = AnimusTouchPointerBag(format: .grab)
    let memeBag = AnimusTouchMemeBag(format: .grab)
    
    init() {
        
    }
    
    @MainActor func performMemeCommands(jiggle: Jiggle,
                             jiggleDocument: JiggleDocument,
                             controller: AnimusController) {
        
        // we do them in order..
        for commandIndex in 0..<memeBag.memeCommandCount {
            let command = memeBag.memeCommands[commandIndex]
            
            pointerBag.sync(jiggle: jiggle,
                            controller: controller,
                            command: command,
                            memeBag: memeBag)
            
            switch command.type {
            case .add:
                captureStart(jiggle: jiggle, jiggleDocument: jiggleDocument,
                             controller: controller,
                             command: command)
            case .remove:
                captureStart(jiggle: jiggle,
                             jiggleDocument: jiggleDocument,
                             controller: controller,
                             command: command)
            case .move:
                captureTrack(jiggle: jiggle,
                             jiggleDocument: jiggleDocument,
                             controller: controller,
                             command: command)
            }
        }
    }
    
    @MainActor func captureStart(jiggle: Jiggle,
                                 jiggleDocument: JiggleDocument,
                                 controller: AnimusController,
                                 command: AnimusTouchMemeCommand) {
        _ = pointerBag.captureStart(jiggle: jiggle)
    }
    
    @MainActor func captureTrack(jiggle: Jiggle,
                                 jiggleDocument: JiggleDocument,
                                 controller: AnimusController,
                                 command: AnimusTouchMemeCommand) {
        _ = pointerBag.captureTrack(jiggle: jiggle,
                                    jiggleDocument: jiggleDocument)
    }
    
    func update_Inactive(deltaTime: Float) {
        pointerBag.update(deltaTime: deltaTime)
    }
    
    func update_Active(deltaTime: Float,
                jiggleDocument: JiggleDocument,
                jiggle: Jiggle,
                isGyroEnabled: Bool,
                clock: Float) {
        
        pointerBag.update(deltaTime: deltaTime)
        
    }
    
    
    @MainActor func fling(jiggle: Jiggle,
                          worldScale: Float,
                          jiggleMeasureFactor: Float) {
        
        let jiggleDampenFactorDrag = jiggle.jiggleDampenFactorDrag
        
        
    }
    
}
