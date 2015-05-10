//
//  GameControlConst.swift
//  ZIDLastVersion
//
//  Created by KimPan Jung on 2015. 5. 11..
//  Copyright (c) 2015년 KPJ. All rights reserved.
//

enum GameState{
    
    case WaitGame
    case GameStart
    case GameOver
    case GameRestart
}

struct CollisionCategory {
    static let None: Int = 0
    static let Player: Int = 0b1
    static let Zombie: Int = 0b10
    static let Map: Int = 0b100
    static let Bullet: Int = 0b1000
}