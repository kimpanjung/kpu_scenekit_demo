//
//  EnemyCharacter.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/15/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SceneKit

enum EnemyState : Int {
    case Idle = 0,
    Walking,
    Running,
    Attacking,
    Hit,
    Dead,
    Unknown
}

enum EnemyAnimation : Int {
    case Die = 0,
    Run,
    Idle,
    Walk,
    Attack
}

class EnemyCharacter : SkinnedCharacter, GameObject {
    let attackSound = "art.scnassets/common/sounds/click"
    let assetDirectory = "art.scnassets/level2/models/warrior/"
    let skeletonName = "Bip01"
    
    
    var speed = 1.0
    var currentState:EnemyState = EnemyState.Unknown
    var previousState:EnemyState = EnemyState.Unknown

    
    var gameType:GameObjectType {
        get {
            return GameObjectType.Enemy
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(characterNode:SCNNode)
    {
        super.init(rootNode: characterNode)
        
        self.name = "Enemy"
        self.addCollideSphere()
        
        // Load the animations and store via a lookup table.
        self.setupIdleAnimation()
        self.setupRunAnimation()
        self.setupWalkAnimation()
        self.setupDieAnimation()
        self.setupAttackAnimation()
        
        currentState = .Unknown;
        previousState = .Unknown;
        
        self.changeState(.Idle)
        

        
    }
    
    class func keyForAnimationType(animType:EnemyAnimation) -> String!
    {
        switch (animType) {
        case .Attack:
            return "attackID";
        case .Die:
            return "DeathID";
        case .Idle:
            return "idleAnimationID";
        case .Run:
            return "RunID";
        case .Walk:
            return "WalkID";
        default:
            return nil;
        }
    }
    
    func changeState(newState:EnemyState) {
        if(currentState == newState) {
            return;
        }
        
        previousState = currentState;
        currentState = newState;
        
        switch(currentState) {
        case .Walking:

            self.changeAnimationState(.Walking)
            break;
        case .Running:
            self.changeAnimationState(.Running)
            break;
        case .Attacking:
            self.changeAnimationState(.Attacking)

            break;
        case .Dead:
            self.changeAnimationState(.Dead)
            break;
        case .Idle:
            self.changeAnimationState(.Idle)
            break;
        case .Hit:
            break;
        default:
            break;
        }
        
    }
    
    func setupIdleAnimation() {
        let fileName = assetDirectory + "idle.dae"
        var idleAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimation.Idle))
        idleAnimation.repeatCount = FLT_MAX;
        idleAnimation.fadeInDuration = 0.15
        idleAnimation.fadeOutDuration = 0.15
        
    }
    
    func setupWalkAnimation()
    {
        let fileName = assetDirectory + "walk.dae"
        var walkAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimation.Walk))
        walkAnimation.repeatCount = FLT_MAX;
        walkAnimation.fadeInDuration = 0.15
        walkAnimation.fadeOutDuration = 0.15
    }
    
    func setupDieAnimation()
    {
        let fileName = assetDirectory + "die.dae"
        var dieAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimation.Die))
        dieAnimation.repeatCount = FLT_MAX;
        dieAnimation.fadeInDuration = 0.15
        dieAnimation.fadeOutDuration = 0.15
        
    }
    
    func setupRunAnimation()
    {
        let fileName = assetDirectory + "run.dae"
        var runAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimation.Run))
        runAnimation.repeatCount = FLT_MAX;
        runAnimation.fadeInDuration = 0.15
        runAnimation.fadeOutDuration = 0.15
    }
    
    func setupAttackAnimation()
    {
        let fileName = assetDirectory + "attack.dae"
        var attackAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimation.Attack))
        attackAnimation.repeatCount = FLT_MAX;
        attackAnimation.fadeInDuration = 0.15
        attackAnimation.fadeOutDuration = 0.15
    }
    
    
    func getAnimationKeyForState(state:EnemyState) -> String
    {
        var key = "unknown"
        switch (state) {
        case .Idle:
            key = EnemyCharacter.keyForAnimationType(.Idle)
            break;
        case .Running:
            key = EnemyCharacter.keyForAnimationType(.Run)
            break;
        case .Walking:
            key = EnemyCharacter.keyForAnimationType(.Walk)
            break;
        case .Attacking:
            key = EnemyCharacter.keyForAnimationType(.Attack)
            break;
        case .Dead:
            key = EnemyCharacter.keyForAnimationType(.Die)
            break;
        default:
            break;
        }
        return key;
    }
    
    func changeAnimationState(newState:EnemyState)
    {
        let newKey = self.getAnimationKeyForState(newState)
        let currentKey = self.getAnimationKeyForState(previousState)
        
        var runAnim = self.cachedAnimationForKey(newKey)
        runAnim.fadeInDuration = 0.15
        if(previousState != .Unknown) {
            self.mainSkeleton.removeAnimationForKey(currentKey, fadeOutDuration:0.15)
        }
        self.mainSkeleton.addAnimation(runAnim, forKey:newKey)
        
    }
    
    func getBoundingBox() -> SCNBox {
        let node = self.childNodeWithName("BODY", recursively: true)
        
        var min:SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
        var max:SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
        node!.getBoundingBoxMin(&min, max: &max)
        
        let box = SCNBox(width: CGFloat(max.x-min.x), height: CGFloat(max.y-min.y), length: CGFloat(max.z-min.z), chamferRadius: 0.0)
        return box
    }
    
    func addCollideSphere() {
        let scale = 0.05
        let playerBox = getBoundingBox()
        let capRadius = CGFloat(scale) * playerBox.width/2.0
        let capHeight = CGFloat(scale) * playerBox.height
        
        //println("enemy box width:\(playerBox.width) height:\(playerBox.height) length:\(playerBox.length)")
        
        let collideSphere = SCNNode()
        collideSphere.name = "EnemyCollideSphere";
        collideSphere.position = SCNVector3Make(0.0, Float(playerBox.height/2), 0.0)
        let geo = SCNCapsule(capRadius: capRadius, height: capHeight)
        let shape2 = SCNPhysicsShape(geometry: geo, options: nil)
        collideSphere.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: shape2)
        
        // We only want to collide with walls and player. Ground collision is handled elsewhere.
        
        collideSphere.physicsBody!.collisionBitMask =
            ColliderType.FrontWall.rawValue | ColliderType.LeftWall.rawValue | ColliderType.RightWall.rawValue | ColliderType.BackWall.rawValue | ColliderType.Player.rawValue
        
        // Put ourself into the player category so other objects can limit their scope of collision checks.
        collideSphere.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue;
        
        self.addChildNode(collideSphere)
        
    }
    
    func handleContact(node:SCNNode) {
        if(node.physicsBody!.categoryBitMask == ColliderType.FrontWall.rawValue) {
            println("Enemy collided with front wall");
            self.position = SCNVector3Make(self.position.x, self.position.y, self.position.z + 10);
            
        } else if(node.physicsBody!.categoryBitMask == ColliderType.LeftWall.rawValue) {
            println("Enemy collided with left wall");
            self.position = SCNVector3Make(self.position.x+10, self.position.y, self.position.z);
            
        } else if(node.physicsBody!.categoryBitMask == ColliderType.RightWall.rawValue) {
            println("Enemy collided with right wall");
            self.position = SCNVector3Make(self.position.x-10, self.position.y, self.position.z);
            
        } else if(node.physicsBody!.categoryBitMask == ColliderType.BackWall.rawValue) {
            println("Enemy collided with back wall");
            self.position = SCNVector3Make(self.position.x, self.position.y, self.position.z - 10);
        }
        
        else if(node.name == "bulletNode"){
            println("Enemy collided with Bullet");
            //self.position = SCNVector3Make(self.position.x-10, self.position.y, self.position.z - backOff);
            
            health -= 10;
            if(health <= 0) {
                println("PLAYER DEAD");
                self.changeState(EnemyState.Attacking)

            } else {
                self.changeState(EnemyState.Running)
                //self.changeState(EnemyState.Idle)
                
            }
        }
        else {
            println("Enemy collided with node: \(node.name)");
            
        }
        
    }
    
    func collideWithLava(node: SCNNode) {
                //Blink for a second
        let blinkOffAction = SCNAction.fadeOutWithDuration(0.15)
        let blinkOnAction = SCNAction.fadeInWithDuration(0.15)
        let cycle = SCNAction.sequence([blinkOffAction, blinkOnAction])
        let repeatCycle = SCNAction.repeatAction(cycle, count: 7)
        
        
        node.runAction(repeatCycle, completionHandler: {
            () -> Void in

        })
    }
    
    func update(deltaTime:NSTimeInterval) {

        
    }
    func isStatic() -> Bool {
        return false
    }
    
}
