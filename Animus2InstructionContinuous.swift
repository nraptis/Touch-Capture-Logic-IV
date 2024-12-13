//
//  Animus2InstructionContinuous.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import Foundation

class Animus2InstructionContinuous {
    
    static let userContinuousAngleMin = Float(-180.0)
    static let userContinuousAngleMax = Float(180.0)
    static let userContinuousAngleDefault = Float(0.0)
    
    static let userContinuousDurationMin = Float(0.0)
    static let userContinuousDurationMax = Float(100.0)
    static let userContinuousDurationDefault = Float(62.0)
    
    static let userContinuousPowerMin = Float(0.0)
    static let userContinuousPowerMax = Float(100.0)
    static let userContinuousPowerDefault = Float(25.0)
    
    static let userContinuousSwoopMin = Float(-100.0)
    static let userContinuousSwoopMax = Float(100.0)
    static let userContinuousSwoopDefault = Float(0.0)
    
    static let userContinuousFrameOffsetMin = Float(0.0)
    static let userContinuousFrameOffsetMax = Float(100.0)
    static let userContinuousFrameOffsetDefault = Float(0.0)
    
    static let userContinuousScaleMin = Float(-100.0)
    static let userContinuousScaleMax = Float(100.0)
    static let userContinuousStartScaleDefault = Float(0.0)
    static let userContinuousEndScaleDefault = Float(0.0)
    
    static let userContinuousRotationMin = Float(-180.0)
    static let userContinuousRotationMax = Float(180.0)
    static let userContinuousStartRotationDefault = Float(0.0)
    static let userContinuousEndRotationDefault = Float(0.0)
    
    static let continuousDurationMin = Float(0.2088)
    static let continuousDurationMax = Float(1.887)
    
    var continuousFrame = Float(0.0)
    
    
    // No knowledge of meme bag.
    // It operates on a command, and the list of active touches...
    let pointerBag = Animus2TouchPointerBag(format: .continuous)
    let memeBag = Animus2TouchMemeBag(format: .continuous)
    
    init() {
        
    }
    
    @MainActor func performMemeCommands(jiggle: Jiggle,
                                        jiggleDocument: JiggleDocument,
                                        controller: Animus2Controller) {
        
        // we do them in order..
        for commandIndex in 0..<memeBag.memeCommandCount {
            let command = memeBag.memeCommands[commandIndex]
            
            pointerBag.sync(jiggle: jiggle,
                            controller: controller,
                            command: command,
                            memeBag: memeBag)
            
            switch command.type {
            case .add:
                captureStart(jiggle: jiggle,
                             jiggleDocument: jiggleDocument,
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
    
    func captureStart(jiggle: Jiggle,
                      jiggleDocument: JiggleDocument,
                      controller: Animus2Controller,
                      command: Animus2TouchMemeCommand) {
        _ = pointerBag.captureStart(jiggle: jiggle)
    }
    
    @MainActor func captureTrack(jiggle: Jiggle,
                      jiggleDocument: JiggleDocument,
                      controller: Animus2Controller,
                      command: Animus2TouchMemeCommand) {
        _ = pointerBag.captureTrack(jiggle: jiggle,
                                    jiggleDocument: jiggleDocument)
    }
    
    func snapToAnimationStartFrame(jiggle: Jiggle) {
        
        var _continuousDurationPercent = (jiggle.continuousDuration - Self.userContinuousDurationMin) / (Self.userContinuousDurationMax - Self.userContinuousDurationMin)
        if _continuousDurationPercent > 1.0 { _continuousDurationPercent = 1.0 }
        if _continuousDurationPercent < 0.0 { _continuousDurationPercent = 0.0 }
        _continuousDurationPercent = (1.0 - _continuousDurationPercent)
        let percentLHS = _continuousDurationPercent * 0.35
        let percentRHS = (_continuousDurationPercent * _continuousDurationPercent) * 0.65
        _continuousDurationPercent = percentLHS + percentRHS
        if _continuousDurationPercent > 1.0 { _continuousDurationPercent = 1.0 }
        if _continuousDurationPercent < 0.0 { _continuousDurationPercent = 0.0 }
        
        let _continuousDuration = Self.continuousDurationMin + (Self.continuousDurationMax - Self.continuousDurationMin) * _continuousDurationPercent
        
        let __continuousFrameOffset = (jiggle.continuousFrameOffset - Self.userContinuousFrameOffsetMin) / (Self.userContinuousFrameOffsetMax - Self.userContinuousFrameOffsetMin)
        
        if __continuousFrameOffset == 0.0 {
            print("offset is 0, we start at 0...")
            continuousFrame = 0.0
        } else {
            continuousFrame = _continuousDuration - (_continuousDuration * __continuousFrameOffset)
            print("offset is \(__continuousFrameOffset) pct, we start at \(continuousFrame) / \(_continuousDuration)...")
        }
    }
    
    func update_Inactive(deltaTime: Float) {
        pointerBag.update(deltaTime: deltaTime)
        continuousFrame = 0.0
    }
    
    func update_Active(deltaTime: Float,
                jiggleDocument: JiggleDocument,
                jiggle: Jiggle,
                isGyroEnabled: Bool,
                clock: Float) {
        
        pointerBag.update(deltaTime: deltaTime)
        
        
        if !jiggle.isCaptureActiveContinuous {
            
            var _continuousDurationPercent = (jiggle.continuousDuration - Self.userContinuousDurationMin) / (Self.userContinuousDurationMax - Self.userContinuousDurationMin)
            if _continuousDurationPercent > 1.0 { _continuousDurationPercent = 1.0 }
            if _continuousDurationPercent < 0.0 { _continuousDurationPercent = 0.0 }
            
            _continuousDurationPercent = (1.0 - _continuousDurationPercent)
            
            let percentLHS = _continuousDurationPercent * 0.35
            let percentRHS = (_continuousDurationPercent * _continuousDurationPercent) * 0.65
            
            _continuousDurationPercent = percentLHS + percentRHS
            
            if _continuousDurationPercent > 1.0 { _continuousDurationPercent = 1.0 }
            if _continuousDurationPercent < 0.0 { _continuousDurationPercent = 0.0 }
            
            let _continuousDuration = Self.continuousDurationMin + (Self.continuousDurationMax - Self.continuousDurationMin) * _continuousDurationPercent
            
            if _continuousDuration > Math.epsilon {
                
                continuousFrame += deltaTime
                if continuousFrame >= _continuousDuration {
                    continuousFrame -= _continuousDuration
                }
                
                var percentLinearBase = continuousFrame / _continuousDuration
                if percentLinearBase > 1.0 { percentLinearBase = 1.0 }
                if percentLinearBase < 0.0 { percentLinearBase = 0.0 }
                
                var _continuousAngle = (jiggle.continuousAngle - Self.userContinuousAngleMin) / (Self.userContinuousAngleMax - Self.userContinuousAngleMin)
                
                if _continuousAngle < 0.0 { _continuousAngle = 0.0 }
                if _continuousAngle > 1.0 { _continuousAngle = 1.0 }
                
                _continuousAngle *= Math.pi2
                
                let dirX = sinf(_continuousAngle)
                let dirY = -cosf(_continuousAngle)
                
                let swoopDirX = sinf(_continuousAngle + Math.pi_2)
                let swoopDirY = -cosf(_continuousAngle + Math.pi_2)
                
                let _continuousPower = (jiggle.continuousPower - Self.userContinuousPowerMin) / (Self.userContinuousPowerMax - Self.userContinuousPowerMin)
                
                let _continuousSwoop = (jiggle.continuousSwoop - Self.userContinuousSwoopMin) / (Self.userContinuousSwoopMax - Self.userContinuousSwoopMin)
                
                let _continuousStartScale = (jiggle.continuousStartScale - Self.userContinuousScaleMin) / (Self.userContinuousScaleMax - Self.userContinuousScaleMin)
                let _continuousEndScale = (jiggle.continuousEndScale - Self.userContinuousScaleMin) / (Self.userContinuousScaleMax - Self.userContinuousScaleMin)
                
                let _continuousStartRotation = (jiggle.continuousStartRotation - Self.userContinuousRotationMin) / (Self.userContinuousRotationMax - Self.userContinuousRotationMin)
                let _continuousEndRotation = (jiggle.continuousEndRotation - Self.userContinuousRotationMin) / (Self.userContinuousRotationMax - Self.userContinuousRotationMin)
                
                
                
                /*
                var fixedRotation = fmodf(newRotation, Math.pi2)
                if fixedRotation > Math.pi { fixedRotation -= Math.pi2 }
                if fixedRotation < Math._pi { fixedRotation += Math.pi2 }
                let rotationU2 = Jiggle.animationCursorFalloffRotation_U2
                let rotationD2 = Jiggle.animationCursorFalloffRotation_D2
                var rotationPercent = Float(fixedRotation - rotationD2) / (rotationU2 - rotationD2)
                if rotationPercent > 1.0 { rotationPercent = 1.0 }
                if rotationPercent < 0.0 { rotationPercent = 0.0 }
                let angleMin = Animus2InstructionContinuous.userContinuousAngleMin
                let angleMax = Animus2InstructionContinuous.userContinuousAngleMax
                jiggle.continuousStartRotation = angleMin + (angleMax - angleMin) * rotationPercent
                jiggleDocument.animationContinuousRotationPublisher.send(())
                */
                
                let measurePercentLinear = Jiggle.getMeasurePercentLinear(measuredSize: jiggle.measuredSize)
                let distanceR2 = Jiggle.getAnimationCursorFalloffDistance_R2(measurePercentLinear: measurePercentLinear)
                
                let startX = dirX * distanceR2 * _continuousPower
                let startY = dirY * distanceR2 * _continuousPower
                
                let endX = -startX
                let endY = -startY
                
                let diffX = (endX - startX)
                let diffY = (endY - startY)
                
                let distanceSquared = diffX * diffX + diffY * diffY
                let distance: Float
                if distanceSquared > Math.epsilon {
                    distance = sqrtf(distanceSquared)
                } else {
                    distance = 0.0
                }
                
                let startScale: Float
                if _continuousStartScale > 0.5 {
                    var _scalePercent = (_continuousStartScale - 0.5) * 2.0
                    if _scalePercent > 1.0 { _scalePercent = 1.0 }
                    if _scalePercent < 0.0 { _scalePercent = 0.0 }
                    startScale = 1.0 + (Jiggle.animationCursorFalloffScale_U2 - 1.0) * _scalePercent
                } else if _continuousStartScale < 0.5 {
                    var _scalePercent = 1.0 - (_continuousStartScale) * 2.0
                    if _scalePercent > 1.0 { _scalePercent = 1.0 }
                    if _scalePercent < 0.0 { _scalePercent = 0.0 }
                    startScale = 1.0 - (1.0 - Jiggle.animationCursorFalloffScale_D2) * _scalePercent
                } else {
                    startScale = 1.0
                }
                
                let endScale: Float
                if _continuousEndScale > 0.5 {
                    var _scalePercent = (_continuousEndScale - 0.5) * 2.0
                    if _scalePercent > 1.0 { _scalePercent = 1.0 }
                    if _scalePercent < 0.0 { _scalePercent = 0.0 }
                    endScale = 1.0 + (Jiggle.animationCursorFalloffScale_U2 - 1.0) * _scalePercent
                } else if _continuousEndScale < 0.5 {
                    var _scalePercent = 1.0 - (_continuousEndScale) * 2.0
                    if _scalePercent > 1.0 { _scalePercent = 1.0 }
                    if _scalePercent < 0.0 { _scalePercent = 0.0 }
                    endScale = 1.0 - (1.0 - Jiggle.animationCursorFalloffScale_D2) * _scalePercent
                } else {
                    endScale = 1.0
                }
                
                let rotationU2 = Jiggle.animationCursorFalloffRotation_U2
                let rotationD2 = Jiggle.animationCursorFalloffRotation_D2
                
                let startRotation: Float = rotationD2 + (rotationU2 - rotationD2) * _continuousStartRotation
                let endRotation: Float = rotationD2 + (rotationU2 - rotationD2) * _continuousEndRotation
                
                let __continuousFrameOffset = (jiggle.continuousFrameOffset - Self.userContinuousFrameOffsetMin) / (Self.userContinuousFrameOffsetMax - Self.userContinuousFrameOffsetMin)
                var __MOVangle = percentLinearBase * Math.pi2 + __continuousFrameOffset * Math.pi2
                __MOVangle -= Math.pi_2
                if __MOVangle > Math.pi2 {
                    __MOVangle -= Math.pi2
                }
                if __MOVangle < 0.0 {
                    __MOVangle += Math.pi2
                }
                var percent = sinf(__MOVangle)
                
                percent = (1.0 + percent) * 0.5
                if percent > 1.0 { percent = 1.0 }
                if percent < 0.0 { percent = 0.0 }
                
                let centerX = startX + (endX - startX) * percent
                let centerY = startY + (endY - startY) * percent
                
                let swoopPercent = sinf(__MOVangle + Math.pi_2)
                let swoopArmLength = (distance * 0.5) * (-1.0 + _continuousSwoop * 2.0)
                let swoopX = swoopDirX * swoopArmLength * swoopPercent
                let swoopY = swoopDirY * swoopArmLength * swoopPercent
                
                jiggle.animationCursorX = centerX + swoopX
                jiggle.animationCursorY = centerY + swoopY
                jiggle.animationCursorScale = startScale + (endScale - startScale) * percent
                jiggle.animationCursorRotation = startRotation + (endRotation - startRotation) * percent
                
            } else {
                jiggle.animationCursorX = 0.0
                jiggle.animationCursorY = 0.0
                jiggle.animationCursorScale = 1.0
                jiggle.animationCursorRotation = 0.0
            }
            
        }
        
        
    }
}

