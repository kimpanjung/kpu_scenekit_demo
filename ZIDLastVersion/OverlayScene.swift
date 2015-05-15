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
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        //setup the overlay scene
        anchorPoint = CGPointMake(0.5, 0.5)
        
        //automatically resize to fill the viewport
        scaleMode = .ResizeFill
        
        //make UI larger on iPads
        let iPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
        let scale: CGFloat = iPad ? 1.5 : 1
        
        //add the camera button
        let cameraImage = SKSpriteNode(imageNamed: "shootButton.png")
        cameraImage.position = CGPointMake(-size.width * 0.4, -size.height * 0.4)
        cameraImage.name = "shoot"
        cameraImage.xScale = 0.6 * scale
        cameraImage.yScale = 0.6 * scale
        addChild(cameraImage)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}