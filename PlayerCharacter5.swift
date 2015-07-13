//
//  PlayerCharacter.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/15/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SceneKit

//enum PlayerState : Int {
//    case Idle = 0,
//    Walking,
//    Running,
//    Crouching,
//    Jumping,
//    Attacking,
//    Hit,
//    Dead,
//    Unknown
//}
//
//enum PlayerAnimation : Int {
//    case Die = 0,
//    Run,
//    Jump,
//    JumpFalling,
//    JumpLand,
//    Idle,
//    GetHit,
//    Bored,
//    RunStart,
//    RunStop,
//    Walk
//}

class PlayerCharacter5 : SkinnedCharacter, GameObject {
    let assetDirectory = "art.scnassets/common/models/explorer/"
    let skeletonName = "Bip001_Pelvis"
    
    var gameType:GameObjectType {
        get {
            return GameObjectType.Player
        }
    }
    
    var speed = 1.0
    var currentState : PlayerState = PlayerState.Unknown
    var previousState : PlayerState = PlayerState.Unknown
    //    var soundListener: OpenALSoundListenerObject = OpenALSoundListenerObject()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(characterNode:SCNNode)
    {
        super.init(rootNode: characterNode)
        
        self.name = "Player"
        
        self.addCollideSphere()
        
        // Load the animations and store via a lookup table.
        self.setupIdleAnimation()
        self.setupWalkAnimation()
        self.setupBoredAnimation()
        self.setupHitAnimation()
        
        self.changeState(PlayerState.Idle)
        
        //        soundListener.objectPosition = self.position;
        //soundListenerObject.gainLevel = 1.0;  // Change this value if you want to play with the listener volume
        //soundListener.atOrientation = SCNVector3Make(0, 0, 0);
    }
    
    class func keyForAnimationType(animType:PlayerAnimation) -> String!
    {
        switch (animType) {
        case .Bored:
            return "bored-1"
        case .Die:
            return "die-1"
        case .GetHit:
            return "hit-1"
        case .Idle:
            return "idle-1"
        case .Jump:
            return "jump_start-1"
        case .JumpFalling:
            return "jump_falling-1"
        case .JumpLand:
            return "jump_land-1"
        case .Run:
            return "run-1"
        case .RunStart:
            return "run_start-1"
        case .RunStop:
            return "run_stop-1"
        case .Walk:
            return "walk-1"
        default:
            return nil
        }
    }
    
    func getAnimationKeyForState(state:PlayerState) -> String
    {
        var key = "unknown";
        switch (state) {
        case .Idle:
            key = PlayerCharacter.keyForAnimationType(.Idle)
            break
        case .Running:
            key = PlayerCharacter.keyForAnimationType(.Run)
            break;
        case .Walking:
            key = PlayerCharacter.keyForAnimationType(.Walk)
            break;
        case .Hit:
            key = PlayerCharacter.keyForAnimationType(.GetHit)
            break;
        case .Dead:
            key = PlayerCharacter.keyForAnimationType(.Die)
            break;
        default:
            break;
        }
        return key;
    }
    
    func changeAnimationState(newState:PlayerState)
    {
        let newKey = self.getAnimationKeyForState(newState)
        let currentKey = self.getAnimationKeyForState(previousState)
        
        var runAnim = self.cachedAnimationForKey(newKey)
        runAnim.fadeInDuration = 0.15;
        self.mainSkeleton.removeAnimationForKey(currentKey, fadeOutDuration:0.15)
        self.mainSkeleton.addAnimation(runAnim, forKey:newKey)
    }
    
    func resetLevel()
    {
        self.health = 50
        currentState = .Idle
        previousState = .Idle
        self.changeState(.Idle)
    }
    
    func changeState(newState:PlayerState)
    {
        if(currentState == newState) {
            return;
        }
        //NSLog(@"CHanging state from %d to %d", _currentState, newState);
        previousState = currentState;
        currentState = newState;
        
        switch(newState) {
        case .Idle:
            self.changeAnimationState(.Idle)
            break;
        case .Jumping:
            self.changeAnimationState(.Jumping)
            break;
        case .Walking:
            self.changeAnimationState(.Walking)
            break;
        case .Hit:
            self.changeAnimationState(.Hit)
            break;
        case .Dead:
            self.changeAnimationState(.Dead)
            break;
        default:
            break;
        }
    }
    
    func setupIdleAnimation()
    {
        let fileName = assetDirectory + "idle.dae"
        var idleAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.Idle))
        idleAnimation.repeatCount = FLT_MAX;
        idleAnimation.fadeInDuration = 0.15;
        idleAnimation.fadeOutDuration = 0.15;
    }
    
    func setupWalkAnimation()
    {
        let fileName = assetDirectory + "walk.dae"
        
        var walkAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.Walk))
        walkAnimation.repeatCount = FLT_MAX;
        walkAnimation.fadeInDuration = 0.15;
        walkAnimation.fadeOutDuration = 0.15;
    }
    
    func setupDieAnimation()
    {
        let fileName = assetDirectory + "die.dae"
        var dieAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimation.Die))
        dieAnimation.repeatCount = FLT_MAX;
        dieAnimation.fadeInDuration = 0.15
        dieAnimation.fadeOutDuration = 0.15
        
    }
    
    func setupBoredAnimation()
    {
        let fileName = assetDirectory + "bored.dae"
        
        var boredAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.Bored))
        boredAnimation.repeatCount = FLT_MAX;
        boredAnimation.fadeInDuration = 0.15;
        boredAnimation.fadeOutDuration = 0.15;
    }
    
    func setupHitAnimation()
    {
        let fileName = assetDirectory + "hit.dae"
        
        var animation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.GetHit))
        animation.fadeInDuration = 0.15;
        animation.fadeOutDuration = 0.15;
        animation.repeatCount = FLT_MAX;
    }
    
    func getAngleFromDirection(currentPosition:SCNVector3, target:SCNVector3) -> Float
    {
        let delX = target.x - currentPosition.x;
        let delZ = target.z - currentPosition.z;
        let angleInRadians =  atan2(delX, delZ);
        //NSLog(@"Angle in radians:%f, in degrees:%f", angleInRadians, RAD2DEG(angleInRadians));
        
        return angleInRadians;
    }
    
    func getBoundingBox() -> SCNBox {
        let node = self.childNodeWithName("explorer", recursively: true)
        
        var min:SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
        var max:SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
        node!.getBoundingBoxMin(&min, max: &max)
        
        let box = SCNBox(width: CGFloat(max.x-min.x), height: CGFloat(max.y-min.y), length: CGFloat(max.z-min.z), chamferRadius: 0.0)
        return box
    }
    
    func addCollideSphere() {
        let scale = 0.025
        let playerBox = getBoundingBox()
        let capRadius = CGFloat(scale) * playerBox.width/2.0
        let capHeight = CGFloat(scale) * playerBox.height
        
        println("player box width:\(playerBox.width) height:\(playerBox.height) length:\(playerBox.length)")
        
        let collideSphere = SCNNode()
        collideSphere.name = "PlayerCollideSphere5";
        collideSphere.position = SCNVector3Make(0, Float(playerBox.height/2), 0);
        let geo = SCNCapsule(capRadius: capRadius, height: capHeight)
        let shape2 = SCNPhysicsShape(geometry: geo, options: nil)
        collideSphere.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: shape2)
        
        println("player box x:\(collideSphere.position.x) y:\(collideSphere.position.y) z:\(collideSphere.position.z)")
        
        // We only want to collide with walls and enemy. Ground collision is handled elsewhere.
        
        collideSphere.physicsBody!.collisionBitMask = CollisionCategory.Bullet//ColliderType.Enemy.rawValue | ColliderType.LeftWall.rawValue | ColliderType.RightWall.rawValue | ColliderType.BackWall.rawValue | ColliderType.FrontWall.rawValue
        
        
        // Put ourself into the player category so other objects can limit their scope of collision checks.
        collideSphere.physicsBody!.categoryBitMask = CollisionCategory.Player //ColliderType.Player.rawValue
        
        
        self.addChildNode(collideSphere)
        
    }
    
    func handleContact(node:SCNNode) {
        let backOff:Float = 10.0
        if(node.name == "FrontWall") {
            println("Player collided with front wall");
            self.position = SCNVector3Make(self.position.x, self.position.y, self.position.z + backOff);
            
        } else if(node.name == "LeftWall") {
            println("Player collided with left wall");
            self.position = SCNVector3Make(self.position.x+backOff, self.position.y, self.position.z);
            
        } else if(node.name == "RightWall") {
            println("Player collided with right wall");
            self.position = SCNVector3Make(self.position.x-backOff, self.position.y, self.position.z);
            
        } else if(node.name == "BackWall") {
            println("Player collided with back wall");
            self.position = SCNVector3Make(self.position.x, self.position.y, self.position.z - backOff);
        } else if(node.name == "EnemyCollideSphere") {
            println("Player collided with enemy");
            health -= 10;
            if(health <= 0) {
                println("PLAYER DEAD");
                self.changeState(PlayerState.Dead)
                self.resetLevel()
            } else {
                self.changeState(PlayerState.Hit)
            }
        }else if(node.name == "bulletNode"){
            println("Player collided with Bullet");
            //self.position = SCNVector3Make(self.position.x-10, self.position.y, self.position.z - backOff);
            println("helth ::: \(health)")
            health -= 10;
            if(health <= 0) {
                println("PLAYER DEAD");
                
                
                collideWithLava(self.presentationNode())
                
                //self.resetLevel()
            } else {
                self.changeState(PlayerState.Hit)
                self.changeState(PlayerState.Idle)
                
            }
        }
            
        else {
            println("Player collided with node: \(node.name)");
            
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
            self.removeFromParentNode()
            //node.removeFromParentNode()
        })
        //node.removeFromParentNode()
        
    }
    
    func createParticle(position: SCNVector3)->SCNNode{
        let fire = SCNParticleSystem(named: "bulletParticle3D", inDirectory: nil)
        let Node = SCNNode()
        Node.position = position
        fire.emitterShape = Node.geometry
        Node.addParticleSystem(fire)
        // ----
        return Node
    }
    
    func getGroundHeight(pos:SCNVector3) -> Float
    {
        
        //        let start = SCNVector3Make(pos.x, pos.y - 75, pos.z)
        //        let end = SCNVector3Make(pos.x, pos.y + 75, pos.z)
        //
        //        let options = [ SCNPhysicsTestSearchModeKey: SCNPhysicsTestSearchModeClosest, SCNPhysicsTestCollisionBitMaskKey : ColliderType.Ground.rawValue]
        //        let physicsWorld = GameScenesManager.sharedInstance.scnView.scene!.physicsWorld
        //        var hits = physicsWorld.rayTestWithSegmentFromPoint(start,
        //                            toPoint:end,
        //                            options:nil)
        //        if(hits == nil) {
        //            println("Hits is nil")
        //            return 0
        //        }
        //        if (hits.count > 0) {
        //            // take the first hit. make that the ground.
        //            var result:SCNHitTestResult!
        //            for result in hits {
        //                var node:SCNNode! = result.node
        //                println("hit node \(node)")
        //                return result.worldCoordinates.y;
        //            }
        //        }
        //
        //        // 0 is ground if we didn't hit anything.
        return 0
    }
    
    
    func update(deltaTime:NSTimeInterval) {
        //        soundListener.objectPosition = self.position;
        //        soundListener.update()
        //
        //        let gameState = GameScenesManager.sharedInstance.gameState
        //        if (gameState == GameState.InGame) {
        //            let joystick:Joystick! = GameUIManager.sharedInstance.inGameMenu?.joystick
        //
        //            //println("velocity x is \(joystick?.velocity.x) and \(joystick?.velocity.y)")
        //
        //            if(joystick.velocity.x == 0.0 && joystick.velocity.y == 0.0 ) {
        //                if(currentState != .Hit) {
        //                    self.changeState(.Idle)
        //                }
        //                return;
        //            }
        //
        //            self.changeState(.Walking)
        //
        //            let delX = joystick.velocity.x * CGFloat(deltaTime * speed)
        //            let delZ = joystick.velocity.y * CGFloat(deltaTime * speed)
        //
        //            let newPlayerPos = SCNVector3Make(self.position.x+Float(delX), self.position.y, self.position.z+Float(delZ));
        //            let angleDirection = self.getAngleFromDirection(self.position, target:newPlayerPos)
        //
        //            /*
        //            let height = self.getGroundHeight(newPlayerPos)
        //            println("ground height is \(height)")
        //            */
        //
        //            self.position = newPlayerPos;
        //            self.rotation = SCNVector4Make(0, 1, 0, angleDirection);
        //
        //        }
    }
    
    func isStatic() -> Bool {
        return false
    }
}
