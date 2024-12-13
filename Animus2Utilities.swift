//
//  Animus2Utilities.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import Foundation

struct Animus2Utilities {
    
    static func restrictAngle(_ angle: Float) -> Float {
        var result = angle
        if (result > Math.pi4) || (result < Math._pi4) {
            result = fmodf(result, Math.pi2)
        }
        while result > Math.pi2 {
            result -= Math.pi2
        }
        while result < 0.0 {
            result += Math.pi2
        }
        return result
    }
    
    static func findGoodNextAngle(captureTrackAngle: Float, proposedAngle: Float) -> Float {
        var goodAngle = Float(0.0)
        var goodDistance = Float(100_000_000.0)
        for step in -3...3 {
            let tryAngle = Float(step) * (Math.pi2) + proposedAngle
            let tryDistance = fabsf(tryAngle - captureTrackAngle)
            if tryDistance < goodDistance {
                goodDistance = tryDistance
                goodAngle = tryAngle
            }
        }
        return goodAngle
    }
    
}
