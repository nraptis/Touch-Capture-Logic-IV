//
//  Animus2TouchSkeleton.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

import UIKit

class Animus2TouchMeme {
    
    init(x: Float,
         y: Float,
         touchID: ObjectIdentifier) {
        self.x = x
        self.y = y
        self.touchID = touchID
    }
    
    var x: Float
    var y: Float
    var touchID: ObjectIdentifier
    
    // The residency should not change. It will simply appear in the list...
    //var residency: AnimusTouchResidency
    
    // The meme would not be expired, it would simply be gone...
    //var isExpired: Bool
    
}
