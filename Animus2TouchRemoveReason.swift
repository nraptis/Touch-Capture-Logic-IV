//
//  Animus2TouchRemoveReason.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/7/24.
//

import Foundation

// Note: The only purpose of this
//       is for debugging.
enum Animus2TouchRemoveReason {
    case appBackground
    case expired
    case modeMismatch
    case touchMismatch
    case orphaned
    case touchesEnded
    case flushAllDocumentMode
    case flushAllKillAllTouches
}
