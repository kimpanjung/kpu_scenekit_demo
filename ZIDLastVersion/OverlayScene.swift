//
//  OverlayScene.swift
//  SceneKitVehicle
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/08/17.
//
//
/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A SpriteKit scene used as an overlay.

*/

import SpriteKit

@objc(AAPLOverlayScene)
class OverlayScene: SKScene {
    
    private(set) var speedNeedle: SKNode!
    
    let cameraImage = SKSpriteNode(imageNamed: "pannel45.png")
    let crossFire = SKSpriteNode(imageNamed: "crosshair_green.png")

    
    
    override init(size: CGSize) {
        super.init(size: size)
        //setup the overlay scene
        //anchorPoint = CGPointMake(0.5, 0.5)
        
        //automatically resize to fill the viewport
        scaleMode = .ResizeFill
        
        //make UI larger on iPads
        let iPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
        let scale: CGFloat = iPad ? 1.5 : 1
        
        //add the camera button
        cameraImage.position = CGPointMake(size.width/6, size.height/6)//CGPointMake(-341, -256)
        cameraImage.alpha = 0.5
        cameraImage.name = "shoot"
//        cameraImage.xScale = 0.6 * scale
//        cameraImage.yScale = 0.6 * scale
        addChild(cameraImage)
        
        // add crossFire
        //crossFire.anchorPoint = CGPointMake(0, 0)
        crossFire.position = CGPointMake(size.width/2, size.height/2)
        crossFire.name = "cross"
        //        cameraImage.xScale = 0.6 * scale
        //        cameraImage.yScale = 0.6 * scale
        addChild(crossFire)
        
    }
    
    func locateImage()->CGPoint{
        return cameraImage.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}