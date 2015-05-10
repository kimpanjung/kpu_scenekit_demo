//
//  LabelNode.swift
//  ZIDLastVersion
//
//  Created by KimPan Jung on 2015. 5. 11..
//  Copyright (c) 2015년 KPJ. All rights reserved.
//

import SpriteKit

class LabelNode : SKLabelNode {
    
    init(position: CGPoint, size: CGFloat, color: SKColor, text: String, name: String) {
        super.init()
        
        self.name = name
        self.text = text
        self.position = position
        
        fontName = "Early-Gameboy"
        fontSize = size
        fontColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

