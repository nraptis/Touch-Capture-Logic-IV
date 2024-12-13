//
//  Animus2TouchPointerBag+Rotation.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/11/24.
//

import Foundation

extension Animus2TouchPointerBag {
    
    //
    // [Touch Routes Verify] 12-11-2024
    // This looks to be right, I don't
    // see anything that can be improved.
    //
    func captureStart_PrepareRotate(jiggle: Jiggle,
                                    averageX: Float,
                                    averageY: Float) {
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            if touchPointer.isConsidered {
                let diffX = averageX - touchPointer.x
                let diffY = averageY - touchPointer.y
                let captureStartDistanceSquared = diffX * diffX + diffY * diffY
                if captureStartDistanceSquared > Animus2TouchPointerBag.captureTrackDistanceThresholdSquared {
                    let captureStartAngle = -atan2f(diffX, diffY)
                    touchPointer.captureStartAngle = captureStartAngle
                    touchPointer.captureTrackAngle = captureStartAngle
                    touchPointer.captureTrackAngleDifference = 0.0
                    touchPointer.captureTrackAngleFixed = captureStartAngle
                    touchPointer.isCaptureStartRotateValid = true
                    
                } else {
                    touchPointer.isCaptureStartRotateValid = false
                }
            }
        }
    }
    
    func captureStart_Rotate(jiggle: Jiggle, rotation: Float) {
        var fixedRotation = fmodf(rotation, Math.pi2)
        if fixedRotation > Math.pi { fixedRotation -= Math.pi2 }
        if fixedRotation < Math._pi { fixedRotation += Math.pi2 }
        captureStartJiggleAnimationCursorRotation = fixedRotation
        let grabDragPowerPercentLinear = Jiggle.getGrabDragPowerPercentLinear(userGrabDragPower: jiggle.grabDragPower)
        let grabDragRotateFactor = Jiggle.getGrabDragRotateFactor(grabDragPowerPercentLinear: grabDragPowerPercentLinear)
        let baseRotationU1 = Jiggle.animationCursorFalloffRotation_U1 * grabDragRotateFactor
        let baseRotationU2 = Jiggle.animationCursorFalloffRotation_U2 * grabDragRotateFactor
        let baseRotationU3 = Jiggle.animationCursorFalloffRotation_U3 * grabDragRotateFactor
        let baseRotationD1 = Jiggle.animationCursorFalloffRotation_D1 * grabDragRotateFactor
        let baseRotationD2 = Jiggle.animationCursorFalloffRotation_D2 * grabDragRotateFactor
        let baseRotationD3 = Jiggle.animationCursorFalloffRotation_D3 * grabDragRotateFactor
        if rotation > baseRotationU2 {
            captureStartCursorFalloffRotation_U1 = rotation
            captureStartCursorFalloffRotation_U2 = rotation
            captureStartCursorFalloffRotation_U3 = rotation
            captureStartCursorFalloffRotation_D1 = baseRotationD1
            captureStartCursorFalloffRotation_D2 = baseRotationD2
            captureStartCursorFalloffRotation_D3 = baseRotationD3
        } else if rotation > baseRotationU1 {
            captureStartCursorFalloffRotation_U1 = rotation
            captureStartCursorFalloffRotation_U2 = baseRotationU2
            captureStartCursorFalloffRotation_U3 = baseRotationU3
            captureStartCursorFalloffRotation_D1 = baseRotationD1
            captureStartCursorFalloffRotation_D2 = baseRotationD2
            captureStartCursorFalloffRotation_D3 = baseRotationD3
        } else if rotation < baseRotationD2 {
            captureStartCursorFalloffRotation_U1 = baseRotationU1
            captureStartCursorFalloffRotation_U2 = baseRotationU2
            captureStartCursorFalloffRotation_U3 = baseRotationU3
            captureStartCursorFalloffRotation_D1 = rotation
            captureStartCursorFalloffRotation_D2 = rotation
            captureStartCursorFalloffRotation_D3 = rotation
        } else if rotation < baseRotationD1 {
            captureStartCursorFalloffRotation_U1 = baseRotationU1
            captureStartCursorFalloffRotation_U2 = baseRotationU2
            captureStartCursorFalloffRotation_U3 = baseRotationU3
            captureStartCursorFalloffRotation_D1 = rotation
            captureStartCursorFalloffRotation_D2 = baseRotationD2
            captureStartCursorFalloffRotation_D3 = baseRotationD3
        } else {
            captureStartCursorFalloffRotation_U1 = baseRotationU1
            captureStartCursorFalloffRotation_U2 = baseRotationU2
            captureStartCursorFalloffRotation_U3 = baseRotationU3
            captureStartCursorFalloffRotation_D1 = baseRotationD1
            captureStartCursorFalloffRotation_D2 = baseRotationD2
            captureStartCursorFalloffRotation_D3 = baseRotationD3
        }
    }
    
    // @Precondition: captureTrack_PrepareRotate
    @MainActor func captureTrack_Rotate(jiggle: Jiggle,
                                        jiggleDocument: JiggleDocument,
                                        averageX: Float,
                                        averageY: Float) {
        
        var rotationShift = Float(0.0)
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            if (touchPointer.isConsidered == true) && (touchPointer.isCaptureStartRotateValid == true) {
                rotationShift += touchPointer.captureTrackAngleDifference
            }
        }
        
        var newRotation = captureStartJiggleAnimationCursorRotation + rotationShift * Jiggle.animationCursorRotationDampen
        if newRotation > captureStartCursorFalloffRotation_U1 {
            newRotation = Math.fallOffOvershoot(input: newRotation,
                                                falloffStart: captureStartCursorFalloffRotation_U1,
                                                resultMax: captureStartCursorFalloffRotation_U2,
                                                inputMax: captureStartCursorFalloffRotation_U3)
        } else if newRotation < captureStartCursorFalloffRotation_D1 {
            newRotation = Math.fallOffUndershoot(input: newRotation,
                                                 falloffStart: captureStartCursorFalloffRotation_D1,
                                                 resultMin: captureStartCursorFalloffRotation_D2,
                                                 inputMin: captureStartCursorFalloffRotation_D3)
        }
        
        let grabDragPowerPercentLinear = Jiggle.getGrabDragPowerPercentLinear(userGrabDragPower: jiggle.grabDragPower)
        let grabDragRotateFactor = Jiggle.getGrabDragRotateFactor(grabDragPowerPercentLinear: grabDragPowerPercentLinear)
        let baseRotationU1 = Jiggle.animationCursorFalloffRotation_U1 * grabDragRotateFactor
        let baseRotationD1 = Jiggle.animationCursorFalloffRotation_D1 * grabDragRotateFactor
        if (captureStartJiggleAnimationCursorRotation > baseRotationU1) && (newRotation < captureStartCursorFalloffRotation_U1) {
            captureStart_PrepareRotate(jiggle: jiggle,
                                       averageX: averageX,
                                       averageY: averageY)
            captureStart_Rotate(jiggle: jiggle, rotation: newRotation)
        }
        
        if (captureStartJiggleAnimationCursorRotation < baseRotationD1) && (newRotation > captureStartCursorFalloffRotation_D1) {
            captureStart_PrepareRotate(jiggle: jiggle,
                                       averageX: averageX,
                                       averageY: averageY)
            captureStart_Rotate(jiggle: jiggle, rotation: newRotation)
        }
        jiggle.animationCursorRotation = newRotation
        
        switch format {
        case .grab:
            break
        case .continuous:
            var fixedRotation = fmodf(newRotation, Math.pi2)
            if fixedRotation > Math.pi { fixedRotation -= Math.pi2 }
            if fixedRotation < Math._pi { fixedRotation += Math.pi2 }
            let rotationU2 = Jiggle.animationCursorFalloffRotation_U2
            let rotationD2 = Jiggle.animationCursorFalloffRotation_D2
            var rotationPercent = Float(fixedRotation - rotationD2) / (rotationU2 - rotationD2)
            if rotationPercent > 1.0 { rotationPercent = 1.0 }
            if rotationPercent < 0.0 { rotationPercent = 0.0 }
            let angleMin = Animus2InstructionContinuous.userContinuousRotationMin
            let angleMax = Animus2InstructionContinuous.userContinuousRotationMax
            jiggle.continuousStartRotation = angleMin + (angleMax - angleMin) * rotationPercent
            jiggleDocument.animationContinuousRotationPublisher.send(())
        }
    }
    
    func captureTrack_PrepareRotate(jiggle: Jiggle, averageX: Float, averageY: Float) -> Bool {
        var numberOfCapturedTouchPointers = 0
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            if (touchPointer.isConsidered == true) && (touchPointer.isCaptureStartRotateValid == true) {
                let diffX = averageX - touchPointer.x
                let diffY = averageY - touchPointer.y
                let captureTrackDistanceSquared = diffX * diffX + diffY * diffY
                if captureTrackDistanceSquared > Self.captureTrackDistanceThresholdSquared {
                    let captureTrackAngle = -atan2f(diffX, diffY)
                    let captureTrackAngleFixed = Animus2Utilities.findGoodNextAngle(captureTrackAngle: touchPointer.captureTrackAngleFixed,
                                                                                    proposedAngle: captureTrackAngle)
                    touchPointer.captureTrackAngle = captureTrackAngle
                    touchPointer.captureTrackAngleFixed = captureTrackAngleFixed
                    touchPointer.captureTrackAngleDifference = touchPointer.captureTrackAngleFixed - touchPointer.captureStartAngle
                }
                numberOfCapturedTouchPointers += 1
            }
        }
        if numberOfCapturedTouchPointers > 1 {
            return true
        } else {
            return false
        }
    }
    
}
