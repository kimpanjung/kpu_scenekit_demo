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
    static let None: Int = 0b00000000
    static let All: Int = 0b11111111
    // static object //
    static let Map: Int = 0b00000001
    
    // dynamic object //
    static let Player: Int = 0b00000010
    static let Monster: Int = 0b00000100
    static let Bullet: Int = 0b00001000
}