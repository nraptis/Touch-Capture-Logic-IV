//
//  AnimusTouchSkeleton.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

import UIKit

class AnimusTouchMeme {
    
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
}
