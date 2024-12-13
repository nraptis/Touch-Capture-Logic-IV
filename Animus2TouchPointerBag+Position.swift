//
//  Animus2TouchPointerBag+Position.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/11/24.
//

import Foundation

extension Animus2TouchPointerBag {
    
    
    func captureStart_Position(jiggle: Jiggle,
                               cursorX: Float,
                               cursorY: Float,
                               averageX: Float,
                               averageY: Float) {
        
        captureStartAverageTouchPointerPosition.x = averageX
        captureStartAverageTouchPointerPosition.y = averageY
        
        var baseDistance_R1 = Float(0.0)
        var baseDistance_R2 = Float(0.0)
        var baseDistance_R3 = Float(0.0)
        Jiggle.getAnimationCursorFalloffDistance_Radii(measuredSize: jiggle.measuredSize,
                                                       userGrabDragPower: jiggle.grabDragPower,
                                                       distance_R1: &baseDistance_R1,
                                                       distance_R2: &baseDistance_R2,
                                                       distance_R3: &baseDistance_R3)
        let cursorLengthSquared = cursorX * cursorX + cursorY * cursorY
        let cursorLength: Float
        if cursorLengthSquared > Math.epsilon {
            cursorLength = sqrtf(cursorLengthSquared)
            if cursorLength <= baseDistance_R1 {
                captureStartCursorFalloffDistance_R1 = baseDistance_R1
                captureStartCursorFalloffDistance_R2 = baseDistance_R2
                captureStartCursorFalloffDistance_R3 = baseDistance_R3
            } else if cursorLength <= baseDistance_R2 {
                captureStartCursorFalloffDistance_R1 = cursorLength
                captureStartCursorFalloffDistance_R2 = baseDistance_R2
                captureStartCursorFalloffDistance_R3 = baseDistance_R3
            } else {
                captureStartCursorFalloffDistance_R1 = cursorLength
                captureStartCursorFalloffDistance_R2 = cursorLength
                captureStartCursorFalloffDistance_R3 = cursorLength
            }
            captureStartJiggleAnimationCursorPosition.x = cursorX
            captureStartJiggleAnimationCursorPosition.y = cursorY
        } else {
            captureStartJiggleAnimationCursorPosition.x = 0.0
            captureStartJiggleAnimationCursorPosition.y = 0.0
            captureStartCursorFalloffDistance_R1 = baseDistance_R1
            captureStartCursorFalloffDistance_R2 = baseDistance_R2
            captureStartCursorFalloffDistance_R3 = baseDistance_R3
        }
    }
    
    @MainActor func captureTrack_Position(jiggle: Jiggle,
                                          jiggleDocument: JiggleDocument,
                                          averageX: Float,
                                          averageY: Float) {
        let diffX = averageX - captureStartAverageTouchPointerPosition.x
        let diffY = averageY - captureStartAverageTouchPointerPosition.y
        let proposedX = captureStartJiggleAnimationCursorPosition.x + diffX
        let proposedY = captureStartJiggleAnimationCursorPosition.y + diffY
        var cursorDirX = proposedX
        var cursorDirY = proposedY
        let cursorLengthSquared = cursorDirX * cursorDirX + cursorDirY * cursorDirY
        let cursorLength: Float
        if cursorLengthSquared > Math.epsilon {
            let _cursorLength = sqrtf(cursorLengthSquared)
            let baseDistance_R1 = Jiggle.getAnimationCursorFalloffDistance_R1(format: format,
                                                                              measuredSize: jiggle.measuredSize,
                                                                              userGrabDragPower: jiggle.grabDragPower)
            if (captureStartCursorFalloffDistance_R1 > baseDistance_R1) && (_cursorLength < captureStartCursorFalloffDistance_R1) {
                jiggle.animationCursorX = proposedX
                jiggle.animationCursorY = proposedY
                captureStart_Position(jiggle: jiggle,
                                      cursorX: proposedX,
                                      cursorY: proposedY,
                                      averageX: averageX,
                                      averageY: averageY)
                cursorLength = _cursorLength
            } else {
                cursorDirX /= _cursorLength
                cursorDirY /= _cursorLength
                let fixedDistance = Math.fallOffOvershoot(input: _cursorLength,
                                                          falloffStart: captureStartCursorFalloffDistance_R1,
                                                          resultMax: captureStartCursorFalloffDistance_R2,
                                                          inputMax: captureStartCursorFalloffDistance_R3)
                jiggle.animationCursorX = cursorDirX * fixedDistance
                jiggle.animationCursorY = cursorDirY * fixedDistance
                cursorLength = fixedDistance
            }
        } else {
            cursorLength = 0.0
            jiggle.animationCursorX = 0.0
            jiggle.animationCursorY = 0.0
        }
        
        switch format {
        case .grab:
            break
        case .continuous:
            let measurePercentLinear = Jiggle.getMeasurePercentLinear(measuredSize: jiggle.measuredSize)
            let distanceR2 = Jiggle.getAnimationCursorFalloffDistance_R2(measurePercentLinear: measurePercentLinear)
            let angle: Float
            if cursorLength > Math.epsilon {
                angle = -atan2f(-jiggle.animationCursorX, -jiggle.animationCursorY)
            } else {
                angle = 0.0
            }
            var fixedAngle = fmodf(angle, Math.pi2)
            if fixedAngle < 0.0 {
                fixedAngle += Math.pi2
            }
            var anglePercent = fixedAngle / Math.pi2
            if anglePercent < 0.0 { anglePercent = 0.0 }
            if anglePercent > 1.0 { anglePercent = 1.0 }
            var powerPercent = cursorLength / distanceR2
            if powerPercent < 0.0 { powerPercent = 0.0 }
            if powerPercent > 1.0 { powerPercent = 1.0 }
            let angleMin = Animus2InstructionContinuous.userContinuousAngleMin
            let angleMax = Animus2InstructionContinuous.userContinuousAngleMax
            let powerMin = Animus2InstructionContinuous.userContinuousPowerMin
            let powerMax = Animus2InstructionContinuous.userContinuousPowerMax
            jiggle.continuousAngle = angleMin + (angleMax - angleMin) * anglePercent
            jiggle.continuousPower = powerMin + (powerMax - powerMin) * powerPercent
            jiggleDocument.animationContinuousDraggingPublisher.send(())
        }
    }
}
