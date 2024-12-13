//
//  AnimusInstructionLoops.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import Foundation

class AnimusInstructionLoops {
    
    static let continuousDurationMin = Float(0.24)
    static let continuousDurationMax = Float(1.78)
    
    static let userContinuousDurationMin = Float(0.0)
    static let userContinuousDurationMax = Float(100.0)
    static let userContinuousDurationDefault = Float(62.0)
    
    static let userContinuousFrameOffsetMin = Float(0.0)
    static let userContinuousFrameOffsetMax = Float(100.0)
    static let userContinuousFrameOffsetDefault = Float(0.0)
    
    static let userContinuousFrameOffsetZero = userContinuousFrameOffsetMin
    static let userContinuousFrameOffsetQuarter = userContinuousFrameOffsetMin + (userContinuousFrameOffsetMax - userContinuousFrameOffsetMin) * 0.25
    
    typealias Point = Math.Point
    
    var isActive = false
    
    var keyFrame = Float(0.0)
    //var time = Float(0.75)
    
    func hibernate() {
        if isActive == true {
            isActive = false
        }
    }
    
    func activate() {
        if isActive == false {
            keyFrame = 0.0
            isActive = true
        }
    }
    
    private func skewedValue(value: Float, factor: Float) -> Float {
        var result = 2.0 * value - 1.0
        if result < -1.0 { result = -1.0 }
        if result > 1.0 { result = 1.0 }
        return result * factor
    }
    
    func update(deltaTime: Float,
                jiggleDocument: JiggleDocument,
                jiggle: Jiggle,
                worldScale: Float,
                jiggleMeasureFactor: Float,
                isGyroEnabled: Bool,
                gyroFactor: Float,
                clock: Float) {
        
        var _continuousDurationPercent = (jiggle.timeLine.animationDuration - Self.userContinuousDurationMin) / (Self.userContinuousDurationMax - Self.userContinuousDurationMin)
        if _continuousDurationPercent > 1.0 { _continuousDurationPercent = 1.0 }
        if _continuousDurationPercent < 0.0 { _continuousDurationPercent = 0.0 }
        
        _continuousDurationPercent = (1.0 - _continuousDurationPercent)
        
        let percentLHS = _continuousDurationPercent * 0.35
        let percentRHS = (_continuousDurationPercent * _continuousDurationPercent) * 0.65
        
        _continuousDurationPercent = percentLHS + percentRHS
        
        var _continuousDuration = Self.continuousDurationMin + (Self.continuousDurationMax - Self.continuousDurationMin) * _continuousDurationPercent
        if _continuousDuration < Self.continuousDurationMin { _continuousDuration = Self.continuousDurationMin }
        if _continuousDuration > Self.continuousDurationMax { _continuousDuration = Self.continuousDurationMax }
        
        if _continuousDuration > Math.epsilon {
            
            keyFrame += deltaTime
            if keyFrame >= _continuousDuration || keyFrame < 0.0 {
                keyFrame = fmodf(keyFrame, _continuousDuration)
                if keyFrame < 0.0 {
                    keyFrame += _continuousDuration
                }
            }
            
            let swatchPositionX = jiggle.timeLine.swatchPositionX
            let swatchPositionY = jiggle.timeLine.swatchPositionY
            let swatchScale = jiggle.timeLine.swatchScale
            let swatchRotation = jiggle.timeLine.swatchRotation
            
            let channelPositionX = swatchPositionX.selectedChannel
            let channelPositionY = swatchPositionY.selectedChannel
            let channelScale = swatchScale.selectedChannel
            let channelRotation = swatchRotation.selectedChannel
            
            let frameOffsetMin = AnimusInstructionLoops.userContinuousFrameOffsetMin
            let frameOffsetDelta = AnimusInstructionLoops.userContinuousFrameOffsetMax - AnimusInstructionLoops.userContinuousFrameOffsetMin
            
            var _frameOffsetX = (jiggle.timeLine.swatchPositionX.frameOffset - frameOffsetMin) / frameOffsetDelta
            if _frameOffsetX > 1.0 { _frameOffsetX = 1.0 }
            if _frameOffsetX < 0.0 { _frameOffsetX = 0.0 }
            var percentX = (keyFrame + (_frameOffsetX * _continuousDuration)) / Float(_continuousDuration)
            if percentX > 1.0 || percentX < 0.0 {
                percentX = fmodf(percentX, 1.0)
                if percentX < 0.0 { percentX += 1.0 }
            }
            
            var _frameOffsetY = (jiggle.timeLine.swatchPositionY.frameOffset - frameOffsetMin) / frameOffsetDelta
            if _frameOffsetY > 1.0 { _frameOffsetY = 1.0 }
            if _frameOffsetY < 0.0 { _frameOffsetY = 0.0 }
            var percentY = (keyFrame + (_frameOffsetY * _continuousDuration)) / Float(_continuousDuration)
            if percentY > 1.0 || percentY < 0.0 {
                percentY = fmodf(percentY, 1.0)
                if percentY < 0.0 { percentY += 1.0 }
            }
            
            var _frameOffsetScale = (jiggle.timeLine.swatchScale.frameOffset - frameOffsetMin) / frameOffsetDelta
            if _frameOffsetScale > 1.0 { _frameOffsetScale = 1.0 }
            if _frameOffsetScale < 0.0 { _frameOffsetScale = 0.0 }
            var percentScale = (keyFrame + (_frameOffsetScale * _continuousDuration)) / Float(_continuousDuration)
            if percentScale > 1.0 || percentScale < 0.0 {
                percentScale = fmodf(percentScale, 1.0)
                if percentScale < 0.0 { percentScale += 1.0 }
            }
            
            var _frameOffsetRotation = (jiggle.timeLine.swatchRotation.frameOffset - frameOffsetMin) / frameOffsetDelta
            if _frameOffsetRotation > 1.0 { _frameOffsetRotation = 1.0 }
            if _frameOffsetRotation < 0.0 { _frameOffsetRotation = 0.0 }
            var percentRotation = (keyFrame + (_frameOffsetRotation * _continuousDuration)) / Float(_continuousDuration)
            if percentRotation > 1.0 || percentRotation < 0.0 {
                percentRotation = fmodf(percentRotation, 1.0)
                if percentRotation < 0.0 { percentRotation += 1.0 }
            }
            
            if channelPositionX.smoother.baseCount > 1 {
                let value = channelPositionX.smoother.scrape(percent: percentX) / TimeLineSmoother.SCALE
                jiggle.animationCursorX = skewedValue(value: value,
                                                      factor: Jiggle.animationCursorDistanceResultMax)
            }
            
            if channelPositionY.smoother.baseCount > 1 {
                let value = channelPositionY.smoother.scrape(percent: percentY) / TimeLineSmoother.SCALE
                jiggle.animationCursorY = skewedValue(value: value, factor: Jiggle.animationCursorDistanceResultMax)
            }
            
            if channelScale.smoother.baseCount > 1 {
                let value = channelScale.smoother.scrape(percent: percentScale) / TimeLineSmoother.SCALE
                jiggle.animationCursorScale = Jiggle.animationCursorScaleDownResultMin + (Jiggle.animationCursorScaleUpResultMax - Jiggle.animationCursorScaleDownResultMin) * value
            } else {
                jiggle.animationCursorScale = 1.0
            }
            
            if channelRotation.smoother.baseCount > 1 {
                let value = channelRotation.smoother.scrape(percent: percentRotation) / TimeLineSmoother.SCALE
                jiggle.animationCursorRotation = Jiggle.animationCursorRotationLeftResultMin + (Jiggle.animationCursorRotationRightResultMax - Jiggle.animationCursorRotationLeftResultMin) * value
                
            } else {
                jiggle.animationCursorRotation = 0.0
            }
        }
    }
}
