//
//  AnimusTouchMemeCommandChunk.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/8/24.
//

enum AnimusTouchMemeCommandChunk {
    case add(ObjectIdentifier, Float, Float)
    case remove(ObjectIdentifier)
    case move(ObjectIdentifier, Float, Float, Float, Float)
}