//
//  Animus2TouchPointerBag+Scale.swift
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
    func captureStart_PrepareScale(jiggle: Jiggle,
                                   averageX: Float,
                                   averageY: Float) {
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            if touchPointer.isConsidered {
                let diffX = averageX - touchPointer.x
                let diffY = averageY - touchPointer.y
                let captureStartDistanceSquared = diffX * diffX + diffY * diffY
                if captureStartDistanceSquared > Animus2TouchPointerBag.captureTrackDistanceThresholdSquared {
                    let captureStartDistance = sqrtf(captureStartDistanceSquared)
                    touchPointer.captureStartDistance = captureStartDistance
                    touchPointer.captureTrackDistance = captureStartDistance
                    touchPointer.isCaptureStartScaleValid = true
                } else {
                    touchPointer.isCaptureStartScaleValid = false
                }
            }
        }
    }
    
    func captureStart_Scale(jiggle: Jiggle, scale: Float) {
        captureStartJiggleAnimationCursorScale = scale
        let grabDragPowerPercentLinear = Jiggle.getGrabDragPowerPercentLinear(userGrabDragPower: jiggle.grabDragPower)
        let grabDragScaleFactor = Jiggle.getGrabDragScaleFactor(grabDragPowerPercentLinear: grabDragPowerPercentLinear)
        let baseScaleStepU1 = Jiggle.animationCursorFalloffScale_U1 - 1.0
        let baseScaleU1 = 1.0 + baseScaleStepU1 * grabDragScaleFactor
        let baseScaleStepU2 = Jiggle.animationCursorFalloffScale_U2 - 1.0
        let baseScaleU2 = 1.0 + baseScaleStepU2 * grabDragScaleFactor
        let baseScaleStepU3 = Jiggle.animationCursorFalloffScale_U3 - 1.0
        let baseScaleU3 = 1.0 + baseScaleStepU3 * grabDragScaleFactor
        let baseScaleStepD1 = 1.0 - Jiggle.animationCursorFalloffScale_D1
        let baseScaleD1 = 1.0 - baseScaleStepD1 * grabDragScaleFactor
        let baseScaleStepD2 = 1.0 - Jiggle.animationCursorFalloffScale_D2
        let baseScaleD2 = 1.0 - baseScaleStepD2 * grabDragScaleFactor
        let baseScaleStepD3 = 1.0 - Jiggle.animationCursorFalloffScale_D3
        let baseScaleD3 = 1.0 - baseScaleStepD3 * grabDragScaleFactor
        if scale > baseScaleU2 {
            captureStartCursorFalloffScale_U1 = scale
            captureStartCursorFalloffScale_U2 = scale
            captureStartCursorFalloffScale_U3 = scale
            captureStartCursorFalloffScale_D1 = baseScaleD1
            captureStartCursorFalloffScale_D2 = baseScaleD2
            captureStartCursorFalloffScale_D3 = baseScaleD3
        } else if scale > baseScaleU1 {
            captureStartCursorFalloffScale_U1 = scale
            captureStartCursorFalloffScale_U2 = baseScaleU2
            captureStartCursorFalloffScale_U3 = baseScaleU3
            captureStartCursorFalloffScale_D1 = baseScaleD1
            captureStartCursorFalloffScale_D2 = baseScaleD2
            captureStartCursorFalloffScale_D3 = baseScaleD3
        } else if scale < baseScaleD2 {
            captureStartCursorFalloffScale_U1 = baseScaleU1
            captureStartCursorFalloffScale_U2 = baseScaleU2
            captureStartCursorFalloffScale_U3 = baseScaleU3
            captureStartCursorFalloffScale_D1 = scale
            captureStartCursorFalloffScale_D2 = scale
            captureStartCursorFalloffScale_D3 = scale
        } else if scale < baseScaleD1 {
            captureStartCursorFalloffScale_U1 = baseScaleU1
            captureStartCursorFalloffScale_U2 = baseScaleU2
            captureStartCursorFalloffScale_U3 = baseScaleU3
            captureStartCursorFalloffScale_D1 = scale
            captureStartCursorFalloffScale_D2 = baseScaleD2
            captureStartCursorFalloffScale_D3 = baseScaleD3
        } else {
            captureStartCursorFalloffScale_U1 = baseScaleU1
            captureStartCursorFalloffScale_U2 = baseScaleU2
            captureStartCursorFalloffScale_U3 = baseScaleU3
            captureStartCursorFalloffScale_D1 = baseScaleD1
            captureStartCursorFalloffScale_D2 = baseScaleD2
            captureStartCursorFalloffScale_D3 = baseScaleD3
        }
    }
    
    func captureTrack_PrepareScale(jiggle: Jiggle, averageX: Float, averageY: Float) -> Animus2TouchPointerScaleResponse {
        let scaleWeightUnit = Jiggle.getAnimationCursorScaleWeightUnit(measuredSize: jiggle.measuredSize)
        var startDistanceSum = Float(0.0)
        var trackDistanceSum = Float(0.0)
        var weightSum = Float(0.0)
        var numberOfCapturedTouchPointers = 0
        for touchPointerIndex in 0..<touchPointerCount {
            let touchPointer = touchPointers[touchPointerIndex]
            if (touchPointer.isConsidered == true) && (touchPointer.isCaptureStartScaleValid == true) {
                let diffX = averageX - touchPointer.x
                let diffY = averageY - touchPointer.y
                let captureTrackDistanceSquared = diffX * diffX + diffY * diffY
                if captureTrackDistanceSquared > Self.captureTrackDistanceThresholdSquared {
                    let captureTrackDistance = sqrtf(captureTrackDistanceSquared)
                    touchPointer.captureTrackDistance = captureTrackDistance
                }
                startDistanceSum += touchPointer.captureStartDistance
                trackDistanceSum += touchPointer.captureTrackDistance
                weightSum += scaleWeightUnit
                numberOfCapturedTouchPointers += 1
            }
        }
        if numberOfCapturedTouchPointers > 1 {
            let scaleData = Animus2TouchPointerScaleData(startDistanceSum: startDistanceSum,
                                                         trackDistanceSum: trackDistanceSum,
                                                         weightSum: weightSum)
            return Animus2TouchPointerScaleResponse.valid(scaleData)
        } else {
            return Animus2TouchPointerScaleResponse.invalid
        }
    }
    
    // @Precondition: captureTrack_PrepareScale
    @MainActor func captureTrack_Scale(jiggle: Jiggle,
                                       jiggleDocument: JiggleDocument,
                                       scaleData: Animus2TouchPointerScaleData,
                                       averageX: Float,
                                       averageY: Float) {
        
        if scaleData.weightSum < Math.epsilon {
            fatalError("this should not be possible, weight sum too small")
        }
        
        let scaleFractionStart = scaleData.startDistanceSum / scaleData.weightSum
        let scaleFractionTrack = scaleData.trackDistanceSum / scaleData.weightSum
        let scaleFractionDelta = (scaleFractionTrack - scaleFractionStart)
        var newScale = captureStartJiggleAnimationCursorScale + scaleFractionDelta
        let grabDragPowerPercentLinear = Jiggle.getGrabDragPowerPercentLinear(userGrabDragPower: jiggle.grabDragPower)
        let grabDragScaleFactor = Jiggle.getGrabDragScaleFactor(grabDragPowerPercentLinear: grabDragPowerPercentLinear)
        if newScale > captureStartCursorFalloffScale_U1 {
            newScale = Math.fallOffOvershoot(input: newScale,
                                             falloffStart: captureStartCursorFalloffScale_U1,
                                             resultMax: captureStartCursorFalloffScale_U2,
                                             inputMax: captureStartCursorFalloffScale_U3)
        } else if newScale < captureStartCursorFalloffScale_D1 {
            newScale = Math.fallOffUndershoot(input: newScale,
                                              falloffStart: captureStartCursorFalloffScale_D1,
                                              resultMin: captureStartCursorFalloffScale_D2,
                                              inputMin: captureStartCursorFalloffScale_D3)
        }
        
        let baseScaleStepU1 = Jiggle.animationCursorFalloffScale_U1 - 1.0
        let baseScaleU1 = 1.0 + baseScaleStepU1 * grabDragScaleFactor
        let baseScaleStepD1 = 1.0 - Jiggle.animationCursorFalloffScale_D1
        let baseScaleD1 = 1.0 - baseScaleStepD1 * grabDragScaleFactor
        if (captureStartJiggleAnimationCursorScale > baseScaleU1) && (newScale < captureStartCursorFalloffScale_U1) {
            captureStart_PrepareScale(jiggle: jiggle,
                                      averageX: averageX,
                                      averageY: averageY)
            captureStart_Scale(jiggle: jiggle,
                               scale: newScale)
        }
        if (captureStartJiggleAnimationCursorScale < baseScaleD1) && (newScale > captureStartCursorFalloffScale_D1) {
            captureStart_PrepareScale(jiggle: jiggle,
                                      averageX: averageX,
                                      averageY: averageY)
            captureStart_Scale(jiggle: jiggle,
                               scale: newScale)
        }
        jiggle.animationCursorScale = newScale
        switch format {
        case .grab:
            break
        case .continuous:
            let scaleU2 = Jiggle.animationCursorFalloffScale_U2
            let scaleD2 = Jiggle.animationCursorFalloffScale_D2
            var scalePercent = Float(0.5)
            if newScale > 1.0 {
                var percentUp = (newScale - 1.0) / (scaleU2 - 1.0)
                if percentUp > 1.0 { percentUp = 1.0 }
                if percentUp < 0.0 { percentUp = 0.0 }
                scalePercent = 0.5 + percentUp * 0.5
            } else if newScale < 1.0 {
                var percentDown = (1.0 - newScale) / (1.0 - scaleD2)
                if percentDown > 1.0 { percentDown = 1.0 }
                if percentDown < 0.0 { percentDown = 0.0 }
                scalePercent = 0.5 - percentDown * 0.5
            }
            let scaleMin = Animus2InstructionContinuous.userContinuousScaleMin
            let scaleMax = Animus2InstructionContinuous.userContinuousScaleMax
            jiggle.continuousStartScale = scaleMin + (scaleMax - scaleMin) * scalePercent
            jiggleDocument.animationContinuousScalePublisher.send(())
        }
    }
}
