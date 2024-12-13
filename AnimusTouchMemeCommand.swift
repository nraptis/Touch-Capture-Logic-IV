//
//  AnimusTouchMemeCommand.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

import Foundation

class AnimusTouchMemeCommand {
    
    var type = AnimusTouchMemeCommandType.move
    
    var chunks = [AnimusTouchMemeCommandChunk]()
    var chunkCount = 0
    
    func addChunk(chunk: AnimusTouchMemeCommandChunk) {
        while chunks.count <= chunkCount {
            chunks.append(chunk)
        }
        chunks[chunkCount] = chunk
        chunkCount += 1
    }
    
    func containsTouch(touchID: ObjectIdentifier) -> Bool {
        for chunkIndex in 0..<chunkCount {
            let chunk = chunks[chunkIndex]
            switch chunk {
            case .add(let oid, _, _):
                if oid == touchID {
                    return true
                }
            case .remove(let oid):
                if oid == touchID {
                    return true
                }
            case .move(let oid, _, _, _, _):
                if oid == touchID {
                    return true
                }
            }
        }
        
        return false
    }
    
    func printCommand() {
        
        print("~~~~~~~~~~~~~~~~~~~~~~~~")
        print("iCommand => \(type)")
        for chunkIndex in 0..<chunkCount {
            let chunk = chunks[chunkIndex]
            switch chunk {
            case .add(let oid, let x, let y):
                print("i\tChunk[\(chunkIndex)] Add(\(oid)) @ [\(x), \(y)]")
            case .remove(let oid):
                print("i\tChunk[\(chunkIndex)] Remove(\(oid))")
            case .move(let oid, let x1, let y1, let x2, let y2):
                print("i\tChunk[\(chunkIndex)] Move(\(oid)) [\(x1), \(y1)] => [\(x2), \(y2)]")
            }
        }
        print("~~~~~~~~~~~~~~~~~~~~~~~~")
        
    }
}
