//
//  Animus2TouchHistory.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import Foundation

class Animus2TouchHistory {
    
    var historyCount: Int = 0
    //var historySize: Int = 12
    static let historySize = 460
    
    var historyX = [Float]()
    var historyY = [Float]()
    
    var historyTime = [Float]()
    var historyExpired = [Bool]()
    
    // These are only used when we compute release...
    var historyDiffX = [Float]()
    var historyDiffY = [Float]()
    var historyDiffMagnitude = [Float]()
    var historyDiffTime = [Float]()
    
    init() {
        for _ in 0..<Animus2TouchHistory.historySize {
            historyX.append(0.0)
        }
        for _ in 0..<Animus2TouchHistory.historySize {
            historyY.append(0.0)
        }
        for _ in 0..<Animus2TouchHistory.historySize {
            historyTime.append(0.0)
        }
        for _ in 0..<Animus2TouchHistory.historySize {
            historyExpired.append(false)
        }
        for _ in 0..<Animus2TouchHistory.historySize {
            historyDiffX.append(0.0)
        }
        for _ in 0..<Animus2TouchHistory.historySize {
            historyDiffY.append(0.0)
        }
        for _ in 0..<Animus2TouchHistory.historySize {
            historyDiffMagnitude.append(0.0)
        }
        for _ in 0..<Animus2TouchHistory.historySize {
            historyDiffTime.append(0.0)
        }
    }
    
    func update(deltaTime: Float, clock: Float) {
        let historyExpireClock = clock - Animus2Touch.historyExpireTime
        for historyIndex in 0..<historyCount {
            if historyTime[historyIndex] <= historyExpireClock {
                historyExpired[historyIndex] = true
            }
        }
    }
    
    func isEveryNodeExpired() -> Bool {
        var result = true
        for historyIndex in 0..<historyCount {
            if historyExpired[historyIndex] == false {
                result = false
            }
        }
        return result
    }
    
    func clearHistory() {
        historyCount = 0
    }
    
    func read(from animusTouchHistory: Animus2TouchHistory) {
        
        historyCount = animusTouchHistory.historyCount
        for index in 0..<Animus2TouchHistory.historySize {
            historyX[index] = animusTouchHistory.historyX[index]
            historyY[index] = animusTouchHistory.historyY[index]
            
            historyTime[index] = animusTouchHistory.historyTime[index]
            historyExpired[index] = animusTouchHistory.historyExpired[index]
            
            historyDiffX[index] = animusTouchHistory.historyDiffX[index]
            historyDiffY[index] = animusTouchHistory.historyDiffY[index]
            historyDiffMagnitude[index] = animusTouchHistory.historyDiffMagnitude[index]
            historyDiffTime[index] = animusTouchHistory.historyDiffTime[index]
        }
    }
    
    // [Deep Dive] 12-7-2024
    //             Developer notes: This seems good.
    //             We waste a little bit of time copying expired
    //             touches, could stop after the first expired touch.
    //             Since there are less than 10,000, it should hardly matter.
    func recordHistory(clock: Float,
                                x: Float,
                                y: Float) {
        if historyCount < Animus2TouchHistory.historySize {
            historyX[historyCount] = x
            historyY[historyCount] = y
            historyTime[historyCount] = clock
            historyExpired[historyCount] = false
            historyCount += 1
        } else {
            for i in 1..<Animus2TouchHistory.historySize {
                historyX[i - 1] = historyX[i]
                historyY[i - 1] = historyY[i]
                historyTime[i - 1] = historyTime[i]
                historyExpired[i - 1] = historyExpired[i]
            }
            historyX[Animus2TouchHistory.historySize - 1] = x
            historyY[Animus2TouchHistory.historySize - 1] = y
            historyTime[Animus2TouchHistory.historySize - 1] = clock
            historyExpired[Animus2TouchHistory.historySize - 1] = false
        }
    }
    
    // [Deep Dive] 12-7-2024
    //             Developer notes: This seems good.
    //             It gives equal weight to all the touches, it might
    //             make more sense to weight the recent ones more.
    //             However, we're only using 12 of them. This is probably fine.
    //             *APPROVED* with hesitation.
    func release() -> ReleaseData {
        
        var isValid = false
        var time = Float(0.0)
        var dirX = Float(0.0)
        var dirY = Float(-1.0)
        var magnitude = Float(0.0)
        
        var diffCount = 0
        
        if (historyCount > 0) && (historyExpired[historyCount - 1] == false) {
            
            var seekIndex = historyCount - 1
            var previousTime = historyTime[seekIndex]
            var previousX = historyX[seekIndex]
            var previousY = historyY[seekIndex]
            
            seekIndex -= 1
            
            while (seekIndex >= 0) && (historyExpired[seekIndex] == false) {
                
                let currentTime = historyTime[seekIndex]
                
                let timeDifference = previousTime - currentTime
                if timeDifference > Math.epsilon {
                    
                    let currentX = historyX[seekIndex]
                    let currentY = historyY[seekIndex]
                    
                    var diffX = (previousX - currentX)
                    var diffY = (previousY - currentY)
                    
                    let distanceSquared = diffX * diffX + diffY * diffY
                    if distanceSquared > Math.epsilon {
                        let distance = sqrtf(distanceSquared)
                        diffX /= distance
                        diffY /= distance
                        
                        historyDiffX[diffCount] = diffX
                        historyDiffY[diffCount] = diffY
                        historyDiffTime[diffCount] = timeDifference
                        historyDiffMagnitude[diffCount] = distance
                        diffCount += 1
                        
                        previousTime = currentTime
                        previousX = currentX
                        previousY = currentY
                    }
                }
                seekIndex -= 1
            }
        }
        
        if diffCount > 0 {
            var totalTime = Float(0.0)
            for diffIndex in 0..<diffCount {
                totalTime += historyDiffTime[diffIndex]
            }
            if totalTime > Math.epsilon {
                time = totalTime
                for diffIndex in 0..<diffCount {
                    let timePercent = historyDiffTime[diffIndex] / totalTime
                    dirX += historyDiffX[diffIndex] * timePercent * historyDiffMagnitude[diffIndex]
                    dirY += historyDiffY[diffIndex] * timePercent * historyDiffMagnitude[diffIndex]
                }
                
                let magnitudeSquared = dirX * dirX + dirY * dirY
                if magnitudeSquared > Math.epsilon {
                    magnitude = sqrtf(magnitudeSquared)
                    dirX /= magnitude
                    dirY /= magnitude
                    isValid = true
                }
            }
        }
        
        return ReleaseData(isValid: isValid,
                           time: time,
                           dirX: dirX,
                           dirY: dirY,
                           magnitude: magnitude)
    }
    
}
