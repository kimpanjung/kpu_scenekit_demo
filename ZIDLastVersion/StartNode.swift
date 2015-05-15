//
//  StartNode.swift
//  ZIDLastVersion
//
//  Created by KimPan Jung on 2015. 5. 11..
//  Copyright (c) 2015년 KPJ. All rights reserved.
//

import SpriteKit
import SceneKit

class StartNode : SKNode {
    
    override init() {
        
        super.init()
        
        
        //사운드 추가하기 - 스타 철소리
        // Tap to start 라벨 추가
        
        // Load textures
        
        name = "Tutorial"

//        let gameStartLabel = SKLabelNode(text: "Tap to start")
//        gameStartLabel.position = CGPoint(x: 512, y: 720)
//        gameStartLabel.fontSize = 72
//        //gameStartLabel.fontName = "Menlo"
//        gameStartLabel.color = UIColor(red: 0.38, green: 0.11, blue: 0.14, alpha: 1.0)
//        gameStartLabel.fontColor = UIColor.whiteColor()
//        gameStartLabel.name = "Tutorial"
//        //gameStartLabel.zPosition = 10
//        addChild(gameStartLabel)
        
        
        let handTexture = SKTexture(imageNamed:"tap1.png")
        handTexture.filteringMode = SKTextureFilteringMode.Nearest
        let handTextureClick = SKTexture(imageNamed:"tap2.png")
        handTextureClick.filteringMode = SKTextureFilteringMode.Nearest
        
        
        // Create animation
//        let handAnimation = SKAction.animateWithTextures([handTexture, handTextureClick], timePerFrame:0.3)
        let handAnimation = SKAction.animateWithTextures([handTexture, handTextureClick], timePerFrame: 0.3, resize: true, restore: true)
        // Create a sprite node abd animate it
//        let sound = SKAction.playSoundFileNamed("bulletSound.mp3", waitForCompletion: true)
//        runAction(sound)
        
        let handSprite = SKSpriteNode(texture: handTexture)
//       handSprite.xScale = 0.1
//        handSprite.yScale = 0.1
        handSprite.runAction(SKAction.repeatActionForever(handAnimation))
        
        addChild(handSprite)
        

        

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

