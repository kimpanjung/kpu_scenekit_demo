//
//  GameObject.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/15/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SceneKit

enum ColliderType: Int {
    case Ground = 4
    case Player = 8
    case Enemy = 16
    case LeftWall = 32
    case RightWall = 64
    case BackWall = 128
    case FrontWall = 256
}

enum GameObjectType :Int {
    case Player = 0, Enemy, KeyCard, Torch, Flag, BunkerScene, Door
}
protocol GameObject  {
    var gameType:GameObjectType { get }
    
    func update(deltaTime:NSTimeInterval)
    func isStatic() -> Bool

}
