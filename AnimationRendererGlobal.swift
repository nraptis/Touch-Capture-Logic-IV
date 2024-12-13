//
//  AnimationRendererGlobal.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 8/8/24.
//

import UIKit
import Metal
import simd

class AnimationRendererGlobal {
    
    static let SHOW_CIRCLES = false
    static let SHOW_CURSOR = false
    static let SHOW_TOUCHES = false
    
    
    
    let pointScalePointers = Float(6.0)
    
    let pointScaleAnimus = Float(0.5)
    
    
    let offsetAnimusY = Float(640.0)
    
    
    
    let lineFillThickness = Float(3.0)
    let lineStrokeThickness = Float(5.0)
    
    unowned var jiggleDocument: JiggleDocument!
    //unowned var jiggleViewModel: JiggleViewModel!
    weak var jiggleViewModel: JiggleViewModel?
    
    unowned var jiggleEngine: JiggleEngine!
    unowned var graphics: Graphics!
    unowned var animusController: Animus2Controller!
    
    let centerMarkerStrokeBuffer = IndexedSpriteBuffer2D()
    let centerMarkerFillBuffer = IndexedSpriteBuffer2DColored()
    
    let cursorStrokeBuffer = IndexedSpriteBuffer2D()
    let cursorFillBuffer = IndexedSpriteBuffer2DColored()
    
    let testPointStrokeBuffer1 = IndexedSpriteBuffer2D()
    let testPointFillBuffer1 = IndexedSpriteBuffer2DColored()
    
    let testLineStrokeBuffer1 = IndexedShapeBuffer2D()
    let testLineFillBuffer1 = IndexedShapeBuffer2DColored()
    
    let testPointStrokeBuffer2 = IndexedSpriteBuffer2D()
    let testPointFillBuffer2 = IndexedSpriteBuffer2DColored()
    
    let testLineStrokeBuffer2 = IndexedShapeBuffer2D()
    let testLineFillBuffer2 = IndexedShapeBuffer2DColored()
    
    let testPointStrokeBuffer3 = IndexedSpriteBuffer2D()
    let testPointFillBuffer3 = IndexedSpriteBuffer2DColored()
    
    let testLineStrokeBuffer3 = IndexedShapeBuffer2D()
    let testLineFillBuffer3 = IndexedShapeBuffer2DColored()
    
    let centerMarkerSpriteInstance = IndexedSpriteInstance2D()
    let centerMarkerStrokeSpriteInstance = IndexedSpriteInstance2D()
    
    
    func load(graphics: Graphics,
              jiggleEngine: JiggleEngine,
              jiggleDocument: JiggleDocument,
              jiggleViewModel: JiggleViewModel) {
        
        cursorStrokeBuffer.red = 0.28
        cursorStrokeBuffer.green = 0.28
        cursorStrokeBuffer.blue = 0.28
        cursorStrokeBuffer.alpha = 0.5
        
        
        centerMarkerStrokeBuffer.red = 0.28
        centerMarkerStrokeBuffer.green = 0.28
        centerMarkerStrokeBuffer.blue = 0.28
        centerMarkerStrokeBuffer.alpha = 0.5
        
        testPointStrokeBuffer1.red = 0.28
        testPointStrokeBuffer1.green = 0.28
        testPointStrokeBuffer1.blue = 0.28
        testPointStrokeBuffer1.alpha = 0.5
        
        testLineStrokeBuffer1.red = 0.28
        testLineStrokeBuffer1.green = 0.28
        testLineStrokeBuffer1.blue = 0.28
        testLineStrokeBuffer1.alpha = 0.5
        
        testLineStrokeBuffer2.red = 0.28
        testLineStrokeBuffer2.green = 0.45
        testLineStrokeBuffer2.blue = 0.18
        testLineStrokeBuffer2.alpha = 0.5
        
        testLineStrokeBuffer3.red = 0.28
        testLineStrokeBuffer3.green = 0.45
        testLineStrokeBuffer3.blue = 0.18
        testLineStrokeBuffer3.alpha = 0.5
        
        
        self.graphics = graphics
        self.jiggleEngine = jiggleEngine
        self.jiggleDocument = jiggleDocument
        self.jiggleViewModel = jiggleViewModel
        self.animusController = jiggleDocument.animusController
        
        
        centerMarkerStrokeBuffer.load(graphics: graphics, sprite: jiggleEngine.jiggleCenterMarkerUnselectedRegularStroke)
        centerMarkerStrokeBuffer.primitiveType = .triangle
        centerMarkerStrokeBuffer.cullMode = .none
        
        centerMarkerFillBuffer.load(graphics: graphics, sprite: jiggleEngine.jiggleCenterMarkerUnselectedRegularFill)
        centerMarkerFillBuffer.primitiveType = .triangle
        centerMarkerFillBuffer.cullMode = .none
        
        cursorStrokeBuffer.load(graphics: graphics, sprite: jiggleEngine.weightCenterMarkerSpinnerUnselectedRegularStroke)
        cursorStrokeBuffer.primitiveType = .triangle
        cursorStrokeBuffer.cullMode = .none
        
        cursorFillBuffer.load(graphics: graphics, sprite: jiggleEngine.weightCenterMarkerSpinnerUnselectedRegularFill)
        cursorFillBuffer.primitiveType = .triangle
        cursorFillBuffer.cullMode = .none
        
        
        testPointFillBuffer1.load(graphics: graphics, sprite: jiggleEngine.guideUnselectedPointRegularFillSprite)
        testPointFillBuffer1.primitiveType = .triangle
        testPointFillBuffer1.cullMode = .none
        
        testPointStrokeBuffer1.load(graphics: graphics, sprite: jiggleEngine.guideUnselectedPointRegularStrokeSprite)
        testPointStrokeBuffer1.primitiveType = .triangle
        testPointStrokeBuffer1.cullMode = .none
        
        testLineFillBuffer1.load(graphics: graphics)
        testLineFillBuffer1.primitiveType = .triangle
        testLineFillBuffer1.cullMode = .none
        
        testLineStrokeBuffer1.load(graphics: graphics)
        testLineStrokeBuffer1.primitiveType = .triangle
        testLineStrokeBuffer1.cullMode = .none
        
        
        testPointFillBuffer2.load(graphics: graphics, sprite: jiggleEngine.guideUnselectedPointRegularFillSprite)
        testPointFillBuffer2.primitiveType = .triangle
        testPointFillBuffer2.cullMode = .none
        
        testPointStrokeBuffer2.load(graphics: graphics, sprite: jiggleEngine.guideUnselectedPointRegularStrokeSprite)
        testPointStrokeBuffer2.primitiveType = .triangle
        testPointStrokeBuffer2.cullMode = .none
        
        testLineFillBuffer2.load(graphics: graphics)
        testLineFillBuffer2.primitiveType = .triangle
        testLineFillBuffer2.cullMode = .none
        
        testLineStrokeBuffer2.load(graphics: graphics)
        testLineStrokeBuffer2.primitiveType = .triangle
        testLineStrokeBuffer2.cullMode = .none
        
        testPointFillBuffer3.load(graphics: graphics, sprite: jiggleEngine.guideUnselectedPointRegularFillSprite)
        testPointFillBuffer3.primitiveType = .triangle
        testPointFillBuffer3.cullMode = .none
        
        testPointStrokeBuffer3.load(graphics: graphics, sprite: jiggleEngine.guideUnselectedPointRegularStrokeSprite)
        testPointStrokeBuffer3.primitiveType = .triangle
        testPointStrokeBuffer3.cullMode = .none
        
        testLineFillBuffer3.load(graphics: graphics)
        testLineFillBuffer3.primitiveType = .triangle
        testLineFillBuffer3.cullMode = .none
        
        testLineStrokeBuffer3.load(graphics: graphics)
        testLineStrokeBuffer3.primitiveType = .triangle
        testLineStrokeBuffer3.cullMode = .none
        
        
        
    }
    
    func reset() {
        
        centerMarkerStrokeBuffer.reset()
        centerMarkerFillBuffer.reset()
        
        cursorStrokeBuffer.reset()
        cursorFillBuffer.reset()
        
        
        
        testPointFillBuffer1.reset()
        testPointStrokeBuffer1.reset()
        
        testLineFillBuffer1.reset()
        testLineStrokeBuffer1.reset()
        
        
        testPointFillBuffer2.reset()
        testPointStrokeBuffer2.reset()
        
        testLineFillBuffer2.reset()
        testLineStrokeBuffer2.reset()
        
        testPointFillBuffer3.reset()
        testPointStrokeBuffer3.reset()
        
        testLineFillBuffer3.reset()
        testLineStrokeBuffer3.reset()
        
    }
    
    func draw2DRegular(renderEncoder: MTLRenderCommandEncoder,
                       clipFrameX: Float, clipFrameY: Float, clipFrameWidth: Float, clipFrameHeight: Float,
                       contentFrameX: Float, contentFrameY: Float, contentFrameWidth: Float, contentFrameHeight: Float,
                       projectionMatrixBase: matrix_float4x4,
                       modelViewMatrixBase: matrix_float4x4) {
        
        centerMarkerStrokeBuffer.projectionMatrix = projectionMatrixBase
        centerMarkerStrokeBuffer.modelViewMatrix = modelViewMatrixBase
        
        
        centerMarkerFillBuffer.projectionMatrix = projectionMatrixBase
        centerMarkerFillBuffer.modelViewMatrix = modelViewMatrixBase
        
        cursorStrokeBuffer.projectionMatrix = projectionMatrixBase
        cursorStrokeBuffer.modelViewMatrix = modelViewMatrixBase
        
        cursorFillBuffer.projectionMatrix = projectionMatrixBase
        cursorFillBuffer.modelViewMatrix = modelViewMatrixBase
        
        
        
        testLineStrokeBuffer1.projectionMatrix = projectionMatrixBase
        testLineStrokeBuffer1.modelViewMatrix = modelViewMatrixBase
        
        testLineFillBuffer1.projectionMatrix = projectionMatrixBase
        testLineFillBuffer1.modelViewMatrix = modelViewMatrixBase
        
        testPointStrokeBuffer1.projectionMatrix = projectionMatrixBase
        testPointStrokeBuffer1.modelViewMatrix = modelViewMatrixBase
        
        testPointFillBuffer1.projectionMatrix = projectionMatrixBase
        testPointFillBuffer1.modelViewMatrix = modelViewMatrixBase
        
        
        testLineStrokeBuffer2.projectionMatrix = projectionMatrixBase
        testLineStrokeBuffer2.modelViewMatrix = modelViewMatrixBase
        
        testLineFillBuffer2.projectionMatrix = projectionMatrixBase
        testLineFillBuffer2.modelViewMatrix = modelViewMatrixBase
        
        testPointStrokeBuffer2.projectionMatrix = projectionMatrixBase
        testPointStrokeBuffer2.modelViewMatrix = modelViewMatrixBase
        
        testPointFillBuffer2.projectionMatrix = projectionMatrixBase
        testPointFillBuffer2.modelViewMatrix = modelViewMatrixBase
        
        testLineStrokeBuffer3.projectionMatrix = projectionMatrixBase
        testLineStrokeBuffer3.modelViewMatrix = modelViewMatrixBase
        
        testLineFillBuffer3.projectionMatrix = projectionMatrixBase
        testLineFillBuffer3.modelViewMatrix = modelViewMatrixBase
        
        testPointStrokeBuffer3.projectionMatrix = projectionMatrixBase
        testPointStrokeBuffer3.modelViewMatrix = modelViewMatrixBase
        
        testPointFillBuffer3.projectionMatrix = projectionMatrixBase
        testPointFillBuffer3.modelViewMatrix = modelViewMatrixBase
        
        
        
        
        
        if Self.SHOW_CURSOR {
            for jiggleIndex in 0..<jiggleDocument.jiggleCount {
                let jiggle = jiggleDocument.jiggles[jiggleIndex]
                
                centerMarkerStrokeBuffer.add(translation: jiggle.center,
                                             scale: 0.5,
                                             rotation: 0.0)
                centerMarkerFillBuffer.add(translation: jiggle.center,
                                           scale: 0.5,
                                           rotation: 0.0,
                                           red: 0.2,
                                           green: 0.7,
                                           blue: 0.7,
                                           alpha: 0.5)
                
                let cursorPoint = Math.Point(x: jiggle.center.x + jiggle.animationCursorX,
                                             y: jiggle.center.y + jiggle.animationCursorY)
                
                
                cursorStrokeBuffer.add(translation: cursorPoint,
                                       scale: 1.25,
                                       rotation: 0.0)
                cursorFillBuffer.add(translation: cursorPoint,
                                     scale: 1.25,
                                     rotation: 0.0,
                                     red: 1.0,
                                     green: 0.7,
                                     blue: 0.125,
                                     alpha: 0.9)
            }
        }
        
        if Self.SHOW_CIRCLES {
            for jiggleIndex in 0..<jiggleDocument.jiggleCount {
                let jiggle = jiggleDocument.jiggles[jiggleIndex]
                
                //let grabDragPower = Jiggle.getGrabDragPower(userGrabDragPower: jiggle.grabDragPower)
                
                let measuredSize = jiggle.measuredSize
                let userGrabDragPower = jiggle.grabDragPower
                
                
                var distance_R1 = Float(0.0)
                var distance_R2 = Float(0.0)
                var distance_R3 = Float(0.0)
                
                Jiggle.getAnimationCursorFalloffDistance_Radii(measuredSize: jiggle.measuredSize,
                                                               userGrabDragPower: jiggle.grabDragPower,
                                                               distance_R1: &distance_R1,
                                                               distance_R2: &distance_R2,
                                                               distance_R3: &distance_R3)
                
                prepareCircleRender(renderEncoder: renderEncoder,
                                    strokeBuffer: testLineStrokeBuffer2,
                                    strokeThickness: 5.0,
                                    fillBuffer: testLineFillBuffer2,
                                    fillThickness: 3.0,
                                    centerX: jiggle.center.x,
                                    centerY: jiggle.center.y,
                                    radius: distance_R1,
                                    red: 0.0,
                                    green: 1.0,
                                    blue: 1.0)
                
                prepareCircleRender(renderEncoder: renderEncoder,
                                    strokeBuffer: testLineStrokeBuffer2,
                                    strokeThickness: 5.0,
                                    fillBuffer: testLineFillBuffer2,
                                    fillThickness: 3.0,
                                    centerX: jiggle.center.x,
                                    centerY: jiggle.center.y,
                                    radius: distance_R2,
                                    red: 0.5,
                                    green: 1.0,
                                    blue: 0.5)
                
                prepareCircleRender(renderEncoder: renderEncoder,
                                    strokeBuffer: testLineStrokeBuffer2,
                                    strokeThickness: 5.0,
                                    fillBuffer: testLineFillBuffer2,
                                    fillThickness: 3.0,
                                    centerX: jiggle.center.x,
                                    centerY: jiggle.center.y,
                                    radius: distance_R3,
                                    red: 1.0,
                                    green: 1.0,
                                    blue: 0.25)
                
            }
            
        }
        
        if Self.SHOW_TOUCHES {
            
            for animationTouchIndex in 0..<animusController.animusTouchCount {
                let animusTouch = animusController.animusTouches[animationTouchIndex]
                
                let history = animusTouch.history
                
                for historyIndex in 0..<history.historyCount {
                    let historyX = history.historyX[historyIndex]
                    let historyY = history.historyY[historyIndex]
                    let historyExpired = history.historyExpired[historyIndex]
                    let historyPoint = Math.Point(x: historyX,
                                                  y: historyY + offsetAnimusY)
                    
                    if historyExpired {
                        testPointStrokeBuffer1.add(translation: historyPoint,
                                                   scale: 0.75 * pointScaleAnimus, rotation: 0.0)
                        testPointFillBuffer1.add(translation: historyPoint,
                                                 scale: 0.75 * pointScaleAnimus, rotation: 0.0,
                                                 red: 0.54, green: 0.25, blue: 0.25, alpha: 0.5)
                    } else {
                        testPointStrokeBuffer1.add(translation: historyPoint,
                                                   scale: 1.0 * pointScaleAnimus, rotation: 0.0)
                        testPointFillBuffer1.add(translation: historyPoint,
                                                 scale: 1.0 * pointScaleAnimus, rotation: 0.0,
                                                 red: 0.35, green: 0.65, blue: 0.65, alpha: 0.5)
                    }
                }
                
                if animusTouch.isExpired {
                    let point = Math.Point(x: animusTouch.point.x,
                                           y: animusTouch.point.y + offsetAnimusY)
                    
                    testPointStrokeBuffer1.add(translation: point,
                                               scale: 1.25 * pointScaleAnimus, rotation: 0.0)
                    
                    testPointFillBuffer1.add(translation: point,
                                             scale: 1.25 * pointScaleAnimus, rotation: 0.0,
                                             red: 0.25, green: 0.25, blue: 0.25, alpha: 0.5)
                } else {
                    let point = Math.Point(x: animusTouch.point.x,
                                           y: animusTouch.point.y + offsetAnimusY)
                    
                    testPointStrokeBuffer1.add(translation: point,
                                               scale: 1.5 * pointScaleAnimus, rotation: 0.0)
                    testPointFillBuffer1.add(translation: point,
                                             scale: 1.5 * pointScaleAnimus, rotation: 0.0,
                                             red: 0.35, green: 0.66, blue: 0.78, alpha: 0.5)
                }
            }
            
            
            for animationTouchIndex in 0..<animusController.purgatoryAnimusTouchCount {
                let animusTouch = animusController.purgatoryAnimusTouches[animationTouchIndex]
                
                let history = animusTouch.history
                
                for historyIndex in 0..<history.historyCount {
                    let historyX = history.historyX[historyIndex]
                    let historyY = history.historyY[historyIndex]
                    let historyExpired = history.historyExpired[historyIndex]
                    let historyPoint = Math.Point(x: historyX,
                                                  y: historyY + offsetAnimusY)
                    
                    if historyExpired {
                        testPointStrokeBuffer1.add(translation: historyPoint,
                                                   scale: 0.75 * pointScaleAnimus, rotation: 0.0)
                        testPointFillBuffer1.add(translation: historyPoint,
                                                 scale: 0.75 * pointScaleAnimus, rotation: 0.0,
                                                 red: 0.25, green: 0.54, blue: 0.15, alpha: 0.5)
                    } else {
                        testPointStrokeBuffer1.add(translation: historyPoint,
                                                   scale: 1.0 * pointScaleAnimus, rotation: 0.0)
                        testPointFillBuffer1.add(translation: historyPoint,
                                                 scale: 1.0 * pointScaleAnimus, rotation: 0.0,
                                                 red: 0.65, green: 0.35, blue: 0.45, alpha: 0.5)
                    }
                }
                
                if animusTouch.isExpired {
                    let point = Math.Point(x: animusTouch.point.x,
                                           y: animusTouch.point.y + offsetAnimusY)
                    testPointStrokeBuffer1.add(translation: point,
                                               scale: 1.25 * pointScaleAnimus, rotation: 0.0)
                    
                    testPointFillBuffer1.add(translation: animusTouch.point,
                                             scale: 1.25 * pointScaleAnimus, rotation: 0.0,
                                             red: 0.15, green: 0.25, blue: 0.35, alpha: 0.5)
                } else {
                    let point = Math.Point(x: animusTouch.point.x,
                                           y: animusTouch.point.y + offsetAnimusY)
                    testPointStrokeBuffer1.add(translation: point,
                                               scale: 1.5 * pointScaleAnimus, rotation: 0.0)
                    testPointFillBuffer1.add(translation: animusTouch.point,
                                             scale: 1.5 * pointScaleAnimus, rotation: 0.0,
                                             red: 0.66, green: 0.35, blue: 0.58, alpha: 0.5)
                }
                
            }
            
            for animationTouchIndex in 0..<animusController.animusTouchCount {
                let animusTouch = animusController.animusTouches[animationTouchIndex]
                
                var touchJiggle: Jiggle?
                switch animusTouch.residency {
                case .unassigned:
                    break
                case .jiggleContinuous(let jiggle):
                    touchJiggle = jiggle
                case .jiggleGrab(let jiggle):
                    touchJiggle = jiggle
                }
                
                if let jiggle = touchJiggle {
                    
                    let strokeBox = getLineBox(x1: animusTouch.x, y1: animusTouch.y + offsetAnimusY,
                                               x2: jiggle.center.x, y2: jiggle.center.y + offsetAnimusY,
                                               thickness: lineStrokeThickness)
                    
                    let fillBox = getLineBox(x1: animusTouch.x, y1: animusTouch.y + offsetAnimusY,
                                             x2: jiggle.center.x, y2: jiggle.center.y + offsetAnimusY,
                                             thickness: lineFillThickness)
                    
                    testLineStrokeBuffer1.add(cornerX1: strokeBox.x1, cornerY1: strokeBox.y1,
                                              cornerX2: strokeBox.x2, cornerY2: strokeBox.y2,
                                              cornerX3: strokeBox.x3, cornerY3: strokeBox.y3,
                                              cornerX4: strokeBox.x4, cornerY4: strokeBox.y4)
                    testLineFillBuffer1.add(cornerX1: fillBox.x1, cornerY1: fillBox.y1,
                                            cornerX2: fillBox.x2, cornerY2: fillBox.y2,
                                            cornerX3: fillBox.x3, cornerY3: fillBox.y3,
                                            cornerX4: fillBox.x4, cornerY4: fillBox.y4,
                                            red: 0.65, green: 0.96, blue: 0.34, alpha: 0.5)
                    
                }
            }
            
            for animationTouchIndex in 0..<animusController.purgatoryAnimusTouchCount {
                let animusTouch = animusController.purgatoryAnimusTouches[animationTouchIndex]
                
                var touchJiggle: Jiggle?
                switch animusTouch.residency {
                case .unassigned:
                    break
                case .jiggleContinuous(let jiggle):
                    touchJiggle = jiggle
                case .jiggleGrab(let jiggle):
                    touchJiggle = jiggle
                }
                
                if let jiggle = touchJiggle {
                    
                    let strokeBox = getLineBox(x1: animusTouch.x, y1: animusTouch.y + offsetAnimusY,
                                               x2: jiggle.center.x, y2: jiggle.center.y + offsetAnimusY,
                                               thickness: lineStrokeThickness)
                    
                    let fillBox = getLineBox(x1: animusTouch.x, y1: animusTouch.y + offsetAnimusY,
                                             x2: jiggle.center.x, y2: jiggle.center.y + offsetAnimusY,
                                             thickness: lineFillThickness)
                    
                    testLineStrokeBuffer1.add(cornerX1: strokeBox.x1, cornerY1: strokeBox.y1,
                                              cornerX2: strokeBox.x2, cornerY2: strokeBox.y2,
                                              cornerX3: strokeBox.x3, cornerY3: strokeBox.y3,
                                              cornerX4: strokeBox.x4, cornerY4: strokeBox.y4)
                    testLineFillBuffer1.add(cornerX1: fillBox.x1, cornerY1: fillBox.y1,
                                            cornerX2: fillBox.x2, cornerY2: fillBox.y2,
                                            cornerX3: fillBox.x3, cornerY3: fillBox.y3,
                                            cornerX4: fillBox.x4, cornerY4: fillBox.y4,
                                            red: 0.65, green: 0.35, blue: 0.54, alpha: 0.5)
                    
                }
            }
        }
        
        
        
        
        if true {
            
            for animusTouch in animusController.releaseGhostTestTouches {
                
                let history = animusTouch.history
                
                for historyIndex in 0..<history.historyCount {
                    let historyX = history.historyX[historyIndex]
                    let historyY = history.historyY[historyIndex]
                    let historyExpired = history.historyExpired[historyIndex]
                    let historyPoint = Math.Point(x: historyX,
                                                  y: historyY)
                    
                    if historyExpired {
                        testPointStrokeBuffer2.add(translation: historyPoint,
                                                   scale: 0.5 * pointScaleAnimus, rotation: 0.0)
                        testPointFillBuffer2.add(translation: historyPoint,
                                                 scale: 0.5 * pointScaleAnimus, rotation: 0.0,
                                                 red: 0.15, green: 0.15, blue: 0.15, alpha: 0.25)
                    } else {
                        testPointStrokeBuffer3.add(translation: historyPoint,
                                                   scale: 1.0 * pointScaleAnimus, rotation: 0.0)
                        testPointFillBuffer3.add(translation: historyPoint,
                                                 scale: 1.0 * pointScaleAnimus, rotation: 0.0,
                                                 red: 0.25, green: 0.65, blue: 0.65, alpha: 0.5)
                    }
                }
                
                if animusTouch.isAllHistoryExpired {
                    let point = Math.Point(x: animusTouch.point.x,
                                           y: animusTouch.point.y)
                    
                    testPointStrokeBuffer2.add(translation: point,
                                               scale: 0.4 * pointScaleAnimus, rotation: 0.0)
                    
                    testPointFillBuffer2.add(translation: point,
                                             scale: 0.4 * pointScaleAnimus, rotation: 0.0,
                                             red: 0.25, green: 0.25, blue: 0.25, alpha: 0.25)
                } else {
                    let point = Math.Point(x: animusTouch.point.x,
                                           y: animusTouch.point.y)
                    
                    testPointStrokeBuffer3.add(translation: point,
                                               scale: 1.25 * pointScaleAnimus, rotation: 0.0)
                    testPointFillBuffer3.add(translation: point,
                                             scale: 1.25 * pointScaleAnimus, rotation: 0.0,
                                             red: 0.65, green: 0.95, blue: 0.25, alpha: 0.5)
                }
            }
            
            for animusTouch in animusController.releaseGhostTestTouches {
                
                var touchJiggle: Jiggle?
                switch animusTouch.residency {
                case .unassigned:
                    break
                case .jiggleContinuous(let jiggle):
                    touchJiggle = jiggle
                case .jiggleGrab(let jiggle):
                    touchJiggle = jiggle
                }
                
                if let jiggle = touchJiggle {
                    
                    let strokeBox = getLineBox(x1: animusTouch.x, y1: animusTouch.y,
                                               x2: jiggle.center.x, y2: jiggle.center.y,
                                               thickness: lineStrokeThickness)
                    
                    let fillBox = getLineBox(x1: animusTouch.x, y1: animusTouch.y,
                                             x2: jiggle.center.x, y2: jiggle.center.y,
                                             thickness: lineFillThickness)
                    
                    if animusTouch.isAllHistoryExpired {
                        testLineFillBuffer3.add(cornerX1: fillBox.x1, cornerY1: fillBox.y1,
                                                cornerX2: fillBox.x2, cornerY2: fillBox.y2,
                                                cornerX3: fillBox.x3, cornerY3: fillBox.y3,
                                                cornerX4: fillBox.x4, cornerY4: fillBox.y4,
                                                red: 0.25, green: 0.25, blue: 0.25, alpha: 0.25)
                    } else {
                        testLineFillBuffer3.add(cornerX1: fillBox.x1, cornerY1: fillBox.y1,
                                                cornerX2: fillBox.x2, cornerY2: fillBox.y2,
                                                cornerX3: fillBox.x3, cornerY3: fillBox.y3,
                                                cornerX4: fillBox.x4, cornerY4: fillBox.y4,
                                                red: 0.85, green: 0.96, blue: 0.315, alpha: 0.5)
                    }
                    
                    
                    
                }
            }
            
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        for jiggleIndex in 0..<jiggleDocument.jiggleCount {
            let jiggle = jiggleDocument.jiggles[jiggleIndex]
            
            let instruction = jiggle.animusInstructionGrab
            let pb = instruction.pointerBag
            
            for touchPointerIndex in 0..<pb.touchPointerCount {
                let touchPointer = pb.touchPointers[touchPointerIndex]
                
                
                switch touchPointer.actionType {
                    
                case .detached:
                    let point = Math.Point(x: touchPointer.x, y: touchPointer.y)
                    testPointStrokeBuffer2.add(translation: point,
                                               scale: 0.65 * pointScalePointers, rotation: 0.0)
                    testPointFillBuffer2.add(translation: point,
                                             scale: 0.65 * pointScalePointers, rotation: 0.0,
                                             red: 0.45, green: 0.05, blue: 0.05, alpha: 0.75)
                case .retained(let x, let y):
                    let point = Math.Point(x: touchPointer.x, y: touchPointer.y)
                    testPointStrokeBuffer2.add(translation: point,
                                               scale: 0.75 * pointScalePointers, rotation: 0.0)
                    testPointFillBuffer2.add(translation: point,
                                             scale: 0.75 * pointScalePointers, rotation: 0.0,
                                             red: 0.75, green: 0.75, blue: 0.05, alpha: 0.75)
                case .add(let x, let y):
                    let point = Math.Point(x: touchPointer.x, y: touchPointer.y)
                    testPointStrokeBuffer2.add(translation: point,
                                               scale: 0.85 * pointScalePointers, rotation: 0.0)
                    testPointFillBuffer2.add(translation: point,
                                             scale: 0.85 * pointScalePointers, rotation: 0.0,
                                             red: 0.5, green: 1.0, blue: 0.25, alpha: 0.75)
                case .remove:
                    let point = Math.Point(x: touchPointer.x, y: touchPointer.y)
                    testPointStrokeBuffer2.add(translation: point,
                                               scale: 0.65 * pointScalePointers, rotation: 0.0)
                    testPointFillBuffer2.add(translation: point,
                                             scale: 0.65 * pointScalePointers, rotation: 0.0,
                                             red: 1.0, green: 0.05, blue: 0.05, alpha: 0.75)
                case .move(let x, let y):
                    let point = Math.Point(x: touchPointer.x, y: touchPointer.y)
                    testPointStrokeBuffer2.add(translation: point,
                                               scale: 0.75 * pointScalePointers, rotation: 0.0)
                    testPointFillBuffer2.add(translation: point,
                                             scale: 0.75 * pointScalePointers, rotation: 0.0,
                                             red: 0.56, green: 0.85, blue: 0.95, alpha: 0.75)
                }
            }
        }
        
        centerMarkerStrokeBuffer.render(renderEncoder: renderEncoder,
                                        pipelineState: .spriteNodeIndexed2DAlphaBlending)
        centerMarkerFillBuffer.render(renderEncoder: renderEncoder,
                                      pipelineState: .spriteNodeColoredIndexed2DAlphaBlending)
        
        
        
        
        
        
        testLineStrokeBuffer1.render(renderEncoder: renderEncoder,
                                     pipelineState: .shapeNodeIndexed2DAlphaBlending)
        
        testLineFillBuffer1.render(renderEncoder: renderEncoder,
                                   pipelineState: .shapeNodeColoredIndexed2DAlphaBlending)
        
        
        testPointStrokeBuffer1.render(renderEncoder: renderEncoder,
                                      pipelineState: .spriteNodeIndexed2DAlphaBlending)
        testPointFillBuffer1.render(renderEncoder: renderEncoder,
                                    pipelineState: .spriteNodeColoredIndexed2DAlphaBlending)
        
        
        
        testLineStrokeBuffer2.render(renderEncoder: renderEncoder,
                                     pipelineState: .shapeNodeIndexed2DAlphaBlending)
        
        testLineFillBuffer2.render(renderEncoder: renderEncoder,
                                   pipelineState: .shapeNodeColoredIndexed2DAlphaBlending)
        
        
        testPointStrokeBuffer2.render(renderEncoder: renderEncoder,
                                      pipelineState: .spriteNodeIndexed2DAlphaBlending)
        testPointFillBuffer2.render(renderEncoder: renderEncoder,
                                    pipelineState: .spriteNodeColoredIndexed2DAlphaBlending)
        
        
        
        testLineStrokeBuffer3.render(renderEncoder: renderEncoder,
                                     pipelineState: .shapeNodeIndexed2DAlphaBlending)
        
        testLineFillBuffer3.render(renderEncoder: renderEncoder,
                                   pipelineState: .shapeNodeColoredIndexed2DAlphaBlending)
        
        
        
        testPointStrokeBuffer3.render(renderEncoder: renderEncoder,
                                      pipelineState: .spriteNodeIndexed2DAlphaBlending)
        testPointFillBuffer3.render(renderEncoder: renderEncoder,
                                    pipelineState: .spriteNodeColoredIndexed2DAlphaBlending)
        
        
        
        
        cursorStrokeBuffer.render(renderEncoder: renderEncoder,
                                  pipelineState: .spriteNodeIndexed2DAlphaBlending)
        cursorFillBuffer.render(renderEncoder: renderEncoder,
                                pipelineState: .spriteNodeColoredIndexed2DAlphaBlending)
        
    }
    
    func getLineBox(x1: Float, y1: Float,
                    x2: Float, y2: Float,
                    thickness: Float) -> LineBox {
        
        let diffX = (x2 - x1)
        let diffY = (y2 - y1)
        
        let distanceSquared = diffX * diffX + diffY * diffY
        if distanceSquared > Math.epsilon {
            let distance = sqrtf(distanceSquared)
            let normalX = -diffY / distance
            let normalY = diffX / distance
            return getLineBox(x1: x1, y1: y1, x2: x2, y2: y2,
                              normalX: normalX, normalY: normalY, thickness: thickness)
        } else {
            let normalX = Float(0.0)
            let normalY = Float(-1.0)
            return getLineBox(x1: x1, y1: y1, x2: x2, y2: y2,
                              normalX: normalX, normalY: normalY, thickness: thickness)
        }
    }
    
    func getLineBox(x1: Float, y1: Float,
                    x2: Float, y2: Float,
                    normalX: Float, normalY: Float,
                    thickness: Float) -> LineBox {
        let _x1 = x1 - thickness * normalX; let _y1 = y1 - thickness * normalY
        let _x2 = x1 + thickness * normalX; let _y2 = y1 + thickness * normalY
        let _x3 = x2 - thickness * normalX; let _y3 = y2 - thickness * normalY
        let _x4 = x2 + thickness * normalX; let _y4 = y2 + thickness * normalY
        return LineBox(x1: _x1, y1: _y1, x2: _x2, y2: _y2,
                       x3: _x3, y3: _y3, x4: _x4, y4: _y4)
    }
    
    
    func prepareCircleRender(renderEncoder: MTLRenderCommandEncoder,
                             strokeBuffer: IndexedShapeBuffer2D,
                             strokeThickness: Float,
                             fillBuffer: IndexedShapeBuffer2DColored,
                             fillThickness: Float,
                             centerX: Float,
                             centerY: Float,
                             radius: Float,
                             red: Float,
                             green: Float,
                             blue: Float) {
        
        let angleCount = 32
        for angleIndex in 1..<angleCount {
            let anglePercent1 = Float(angleIndex - 1) / Float(angleCount - 1)
            let angle1 = Math.pi2 * anglePercent1
            let dirX1 = sinf(angle1)
            let dirY1 = -cosf(angle1)
            let x1 = centerX + radius * dirX1
            let y1 = centerY + radius * dirY1
            
            let anglePercent2 = Float(angleIndex) / Float(angleCount - 1)
            let angle2 = Math.pi2 * anglePercent2
            let dirX2 = sinf(angle2)
            let dirY2 = -cosf(angle2)
            let x2 = centerX + radius * dirX2
            let y2 = centerY + radius * dirY2
            
            
            let strokeBox = getLineBox(x1: x1, y1: y1,
                                       x2: x2, y2: y2,
                                       thickness: strokeThickness)
            
            let fillBox = getLineBox(x1: x1, y1: y1,
                                     x2: x2, y2: y2,
                                     thickness: fillThickness)
            
            strokeBuffer.add(cornerX1: strokeBox.x1, cornerY1: strokeBox.y1,
                             cornerX2: strokeBox.x2, cornerY2: strokeBox.y2,
                             cornerX3: strokeBox.x3, cornerY3: strokeBox.y3,
                             cornerX4: strokeBox.x4, cornerY4: strokeBox.y4)
            fillBuffer.add(cornerX1: fillBox.x1, cornerY1: fillBox.y1,
                           cornerX2: fillBox.x2, cornerY2: fillBox.y2,
                           cornerX3: fillBox.x3, cornerY3: fillBox.y3,
                           cornerX4: fillBox.x4, cornerY4: fillBox.y4,
                           red: red, green: green, blue: blue, alpha: 0.5)
            
        }
        
    }
    
}
