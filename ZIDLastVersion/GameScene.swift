//
//  GameScene.swift
//  ZIDLastVersion
//
//  Created by KimPan Jung on 2015. 5. 11..
//  Copyright (c) 2015년 KPJ. All rights reserved.
//

import SceneKit
import SpriteKit
import UIKit

typealias Float3 = (Float, Float, Float)
func +(lhs: SCNVector3, rhs: Float3) -> SCNVector3 {
    return SCNVector3Make(lhs.x + rhs.0, lhs.y + rhs.1, lhs.z + rhs.2)
}
func -(lhs: SCNVector3, rhs: Float3) -> SCNVector3 {
    return SCNVector3Make(lhs.x - rhs.0, lhs.y - rhs.1, lhs.z - rhs.2)
}
//--Alternate for vector_mix
func mix(x:Float3, y:Float3, t:Float) -> Float3 {
    return x + (y - x) * t
}
func +(lhs:Float3, rhs:Float3) -> Float3 {
    return (lhs.0 + rhs.0, lhs.1 + rhs.1, lhs.2 + rhs.2)
}
func -(lhs:Float3, rhs:Float3) -> Float3 {
    return (lhs.0 - rhs.0, lhs.1 - rhs.1, lhs.2 - rhs.2)
}
func *(lhs:Float3, rhs:Float) -> Float3 {
    return (lhs.0 * rhs, lhs.1 * rhs, lhs.2 * rhs)
}
extension SCNVector3 {
    init(_ f3: Float3) {
        self.x = f3.0
        self.y = f3.1
        self.z = f3.2
    }
    var toFloat3: Float3 {
        return (self.x, self.y, self.z)
    }
}

class GameScene : SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate,UIGestureRecognizerDelegate {
    
    var sceneView: SCNView!
    var gameState = GameState.WaitGame
    
    // Bullet //
    let autofireTapTimeThreshold = 0.5
    let maxRoundsPerSecond = 10
    let bulletRadius = 0.5 // 0.05
    let bulletImpulse = 100
    let maxBullets = 1
    
    // Camera
    var lookGesture: UIPanGestureRecognizer!
    var walkGesture: UIPanGestureRecognizer!
    var fireGesture: FireGestureRecognizer!
    var camNode: SCNNode!
    
    // Player & zombie Scene/Node
    
    //var player:PlayerCharacter!
    var player:PlayerCharacter!
    var player2:PlayerCharacter2!
    var player3:PlayerCharacter3!
    var player4:PlayerCharacter4!
    var player5:PlayerCharacter5!
    
    var playerNode: SCNNode!
    var playerChildNode: SCNNode!
    let playerScene = SCNScene(named: "art.scnassets/ship.dae")
    // zombie
    var zombieNode: SCNNode!
    var zombieChildNode: SCNNode!
    
    //mapNode
    var mapNode: SCNNode!
    var mapChildNode: SCNNode!
    let mapScene = SCNScene(named: "stage1test2")
    
    // Locate zombie
    var map: Map!
    
    // tap control //
    var elevation: Float = 0
    
    var tapCount = 0
    var lastTappedFire: NSTimeInterval = 0
    var lastFired: NSTimeInterval = 0
    var bullets = [SCNNode]()
    
    var levelData: GameLevel!
    
    var steering: Bool = false
    
    
    var enemy:EnemyCharacter!
    
    
    // *** GameScene method *** //
    
    init(view: SCNView) {
        sceneView = view
        super.init()
        // game initialize method
        initGame()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initGame(){
        
        // dynamic object
        setupPlayer(SCNVector3(x: 0 , y: 2.0 , z: 0))
        
        //setupStaticObject()
        let Node: SCNNode = createStaticObject(SCNVector3(x:  0 , y: 0 , z: 0), name: "Dummymaster")
        rootNode.addChildNode(Node)

        
        setupPlayerAnimation(SCNVector3(x: 0, y: 0, z: -40))
        setupPlayerAnimation2(SCNVector3(x: 8, y: 0, z: -120))
        setupPlayerAnimation3(SCNVector3(x: -8, y: 0, z: -200))
        setupPlayerAnimation4(SCNVector3(x: -2, y: 0, z: -300))
        setupPlayerAnimation5(SCNVector3(x: -4, y: 0, z: -450))
        
        // static object
        environment()
        setupLevel()
        
        // touch event
        setupGestureRecognizer(sceneView)
        switchToWaitingForFirstTap()
        
    }

    
    func setupGestureRecognizer(view: SCNView){
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        lookGesture = UIPanGestureRecognizer(target: self, action: "lookGestureRecognized:")
        lookGesture.delegate = self
        view.addGestureRecognizer(lookGesture)
        
        //walk gesture
        walkGesture = UIPanGestureRecognizer(target: self, action: "walkGestureRecognized:")
        walkGesture.delegate = self
        view.addGestureRecognizer(walkGesture)
        
        //fire gesture
        fireGesture = FireGestureRecognizer(target: self, action: "fireGestureRecognized:")
        fireGesture.delegate = self
        view.addGestureRecognizer(fireGesture)
    }
    
    // tap to start!
    func handleTap(gesture: UIGestureRecognizer) {
        if let tapGesture = gesture as? UITapGestureRecognizer {
            switchToPlaying()
            //movePlayerInDirection()
        }
    }
    
    func setupMap(){
        
        mapChildNode = mapScene!.rootNode.childNodeWithName("Dummymaster", recursively: false)!
        mapChildNode.position = SCNVector3(x: 0.0, y: -10 , z: -50)
        mapChildNode.scale = SCNVector3(x: 100, y: 100, z: 100)
        mapChildNode.name = "mapNode"
        
        let body = SCNPhysicsBody.dynamicBody()
        //        body.allowsResting = false
        body.mass = 0
        //        body.restitution = 0.1
        //        body.friction = 0.5
        //        body.rollingFriction = 0
        
        mapChildNode.physicsBody?.categoryBitMask = CollisionCategory.Map
        mapChildNode.physicsBody?.collisionBitMask = CollisionCategory.All ^ CollisionCategory.Bullet
        
        mapChildNode.physicsBody = body
        rootNode.addChildNode(mapChildNode)
    }
    
    func environment(){
        // add walls
        let wall = SCNNode(geometry: SCNBox(width: 1000, height: 2, length: 4, chamferRadius: 0))
        wall.geometry!.firstMaterial!.diffuse.contents = "wallTexture.jpg"
        wall.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4Mult(SCNMatrix4MakeScale(24, 2, 1), SCNMatrix4MakeTranslation(0, 1, 0))
        wall.geometry!.firstMaterial!.diffuse.wrapS = .Repeat
        wall.geometry!.firstMaterial!.diffuse.wrapT = .Mirror
        wall.geometry!.firstMaterial!.doubleSided = false
        wall.castsShadow = false
        wall.geometry!.firstMaterial!.locksAmbientWithDiffuse = true
        
        wall.position = SCNVector3Make(0, 0, 50)
        //wall.physicsBody = SCNPhysicsBody.staticBody()
        let body = SCNPhysicsBody.dynamicBody()
        body.allowsResting = false
        body.mass = 0
        body.restitution = 0.1
        body.friction = 0.5
        body.rollingFriction = 0
        
        wall.physicsBody = body
        
        wall.physicsBody?.categoryBitMask = CollisionCategory.Map
        wall.physicsBody?.collisionBitMask = CollisionCategory.All ^ CollisionCategory.Bullet
        
        wall.name = "mapNode"
        
        rootNode.addChildNode(wall)
        
        let wallC = wall.clone() as! SCNNode
        wallC.position = SCNVector3Make(-20, 0, -500)
        wallC.rotation = SCNVector4Make(0, 1, 0, Float(M_PI_2))
        rootNode.addChildNode(wallC)
        
        let wallD = wall.clone() as! SCNNode
        wallD.position = SCNVector3Make(20, 0, -500)
        wallD.rotation = SCNVector4Make(0, 1, 0, Float(-M_PI_2))
        rootNode.addChildNode(wallD)
        
        //        let backWall = SCNNode(geometry: SCNPlane(width: 400, height: 100))
        //        backWall.geometry!.firstMaterial = wall.geometry!.firstMaterial
        //        backWall.position = SCNVector3Make(0, 50, 200)
        //        backWall.rotation = SCNVector4Make(0, 1, 0, Float(M_PI_2))
        //        backWall.castsShadow = false
        //        backWall.physicsBody = SCNPhysicsBody.staticBody()
        //        rootNode.addChildNode(backWall)
    }
    
    
    
    func setupPlayer(firstPosition: SCNVector3){
        // player Node
        let carScene = SCNScene(named: "rc_car")
        
        playerNode = SCNNode()
        //playerNode = carScene!.rootNode.childNodeWithName("rccarBody", recursively: false)!
        playerNode.position = firstPosition
        
        playerNode.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        
        //SCNCylinder(radius: 0.2, height: 1)
        
        //SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: SCNCylinder(radius: 0.2, height: 1), options: nil))
        
        //playerNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: SCNCylinder(radius: 1, height: 1), options: nil))
        
        //        let body = SCNPhysicsBody.dynamicBody()
        //        body.angularDamping = 0.9999999
        //        body.damping = 0.9999999
        //        body.rollingFriction = 0
        //        body.friction = 0.5
        //        body.restitution = 0.1
        //        body.velocityFactor = SCNVector3(x: 5, y:0, z: 5) // (not y==0 ) affected by gravity
        
        //body.allowsResting = false
        //body.mass = 80
        
        //        playerNode!.physicsBody = body
        
        //playerNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 1), options: nil))
        playerNode.physicsBody = SCNPhysicsBody.dynamicBody()
        playerNode.physicsBody?.angularDamping = 0.9999999
        playerNode.physicsBody?.damping = 0.9999999
        playerNode.physicsBody?.rollingFriction = 100
        playerNode.physicsBody?.friction = 0
        playerNode.physicsBody?.restitution = 0
        playerNode.physicsBody?.velocityFactor = SCNVector3(x: 5, y:0, z: 5) // (not y==0 ) affected by gravity
        
        //playerNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        
        println("\(playerNode.rotation.x) >> \(playerNode.rotation.y) >> \(playerNode.rotation.z) >> \(playerNode.rotation.w)")
        
        println("\(playerNode.orientation.x) >> \(playerNode.orientation.y) >> \(playerNode.orientation.z) >> \(playerNode.orientation.w)")
        
        
        playerNode.physicsBody?.categoryBitMask = CollisionCategory.Player
        //playerNode.physicsBody?.collisionBitMask = CollisionCategory.All ^ CollisionCategory.Bullet
        
        playerNode.name = "playerNode"
        //playerNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        rootNode.addChildNode(playerNode)
        
        //add a camera node
        camNode = SCNNode()
        camNode.position = SCNVector3(x: 0, y: 0, z: 0)
        playerNode.addChildNode(camNode)
        
        //add camera
        let camera = SCNCamera()
        camera.zNear = 0.01
        camera.zFar = 70
        camNode.camera = camera
        
        // player AI
        // Move the car
        // playerNode.position = ball.position
        //        let moveDirection: Float = -1
        //        let moveDistance: Float = 500 //levelData.gameLevelWidth()
        //        let moveAction = SCNAction.moveTo(SCNVector3(x: 0,y: 0,z: -1000), duration: 30)//(SCNVector3(x: 0.0, y: 0.0, z: moveDistance * moveDirection), duration: 10.0)
        //        let removeAction = SCNAction.runBlock { node -> Void in
        //            node.removeFromParentNode()
        //        }
        //        ball.runAction(SCNAction.sequence([moveAction, removeAction]))
        
        // Rotate the car to move it in the right direction
        //        if moveDirection > 0.0 {
        //            carNode.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: 3.1415)
        //        }
        
    }
    
    
    func setupPlayerAnimation(position: SCNVector3) {
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/common/models/explorer/explorer_skinned", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options:nil)
        let rootNode2 = source!.entryWithIdentifier("group", withClass:SCNNode.self) as! SCNNode
        
        player = PlayerCharacter(characterNode:rootNode2)
        player.scale = SCNVector3Make(0.025, 0.025, 0.025);
        player.position = position //SCNVector3Make(0, 0, -50);
        player.name = "player"
        
        rootNode.addChildNode(player)
        
        // Move the zombie
        let moveDirection: Float = player.position.x > 0.0 ? -1.0 : 1.0
        let moveDistance: Float = 10
        let moveAction = SCNAction.moveBy(SCNVector3(x: moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 10)
        let removeAction = SCNAction.runBlock { node -> Void in
            //node.removeFromParentNode()
        }
        let moveAction2 = SCNAction.moveBy(SCNVector3(x: -moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 10)
        
        //player2.runAction(SCNAction.sequence([moveAction, moveAction2]))
        player.runAction(SCNAction.repeatActionForever(SCNAction.sequence([moveAction, moveAction2])))
        
        
        //player.constraints = [SCNLookAtConstraint(target: playerNode)]
        
        // Rotate the car to move it in the right direction

            }
    
    func setupPlayerAnimation2(position: SCNVector3) {
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/common/models/explorer/explorer_skinned", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options:nil)
        let rootNode2 = source!.entryWithIdentifier("group", withClass:SCNNode.self) as! SCNNode
        
        player2 = PlayerCharacter2(characterNode:rootNode2)
        player2.scale = SCNVector3Make(0.025, 0.025, 0.025);
        player2.position = position //SCNVector3Make(0, 0, -50);
        player2.name = "player"
        
        rootNode.addChildNode(player2)
        
        // Move the zombie
        let moveDirection: Float = player2.position.x > 0.0 ? -1.0 : 1.0
        let moveDistance: Float = 10
        let moveAction = SCNAction.moveBy(SCNVector3(x: moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 5)
        let removeAction = SCNAction.runBlock { node -> Void in
            //node.removeFromParentNode()
        }
        let moveAction2 = SCNAction.moveBy(SCNVector3(x: -moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 5)

        //player2.runAction(SCNAction.sequence([moveAction, moveAction2]))
        player2.runAction(SCNAction.repeatActionForever(SCNAction.sequence([moveAction, moveAction2])))
        
        // Rotate the car to move it in the right direction

    }
    
    func setupPlayerAnimation3(position: SCNVector3) {
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/common/models/explorer/explorer_skinned", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options:nil)
        let rootNode2 = source!.entryWithIdentifier("group", withClass:SCNNode.self) as! SCNNode
        
        player3 = PlayerCharacter3(characterNode:rootNode2)
        player3.scale = SCNVector3Make(0.025, 0.025, 0.025);
        player3.position = position //SCNVector3Make(0, 0, -50);
        player3.name = "player"
        
        rootNode.addChildNode(player3)
        
        // Move the zombie
        let moveDirection: Float = player3.position.x > 0.0 ? -1.0 : 1.0
        let moveDistance: Float = 15
        let moveAction = SCNAction.moveBy(SCNVector3(x: moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 7)
        let removeAction = SCNAction.runBlock { node -> Void in
            //node.removeFromParentNode()
        }
        let moveAction2 = SCNAction.moveBy(SCNVector3(x: -moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 7)
        
        //player2.runAction(SCNAction.sequence([moveAction, moveAction2]))
        player3.runAction(SCNAction.repeatActionForever(SCNAction.sequence([moveAction, moveAction2])))
        
        // Rotate the car to move it in the right direction

        
    }
    
    func setupPlayerAnimation4(position: SCNVector3) {
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/common/models/explorer/explorer_skinned", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options:nil)
        let rootNode2 = source!.entryWithIdentifier("group", withClass:SCNNode.self) as! SCNNode
        
        player4 = PlayerCharacter4(characterNode:rootNode2)
        player4.scale = SCNVector3Make(0.025, 0.025, 0.025);
        player4.position = position //SCNVector3Make(0, 0, -50);
        player4.name = "player"
        
        rootNode.addChildNode(player4)
        
        // Move the zombie
        let moveDirection: Float = player4.position.x > 0.0 ? -1.0 : 1.0
        let moveDistance: Float = 5
        let moveAction = SCNAction.moveBy(SCNVector3(x: moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 8)
        let removeAction = SCNAction.runBlock { node -> Void in
            //node.removeFromParentNode()
        }
        let moveAction2 = SCNAction.moveBy(SCNVector3(x: -moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 8)
        
        //player2.runAction(SCNAction.sequence([moveAction, moveAction2]))
        player4.runAction(SCNAction.repeatActionForever(SCNAction.sequence([moveAction, moveAction2])))
        
        // Rotate the car to move it in the right direction
        if moveDirection > 0.0 {
            player4.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: 90)
        }
        
    }
    
    func setupPlayerAnimation5(position: SCNVector3) {
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/common/models/explorer/explorer_skinned", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options:nil)
        let rootNode2 = source!.entryWithIdentifier("group", withClass:SCNNode.self) as! SCNNode
        
        player5 = PlayerCharacter5(characterNode:rootNode2)
        player5.scale = SCNVector3Make(0.025, 0.025, 0.025);
        player5.position = position //SCNVector3Make(0, 0, -50);
        player5.name = "player"
        
        rootNode.addChildNode(player5)
        
        // Move the zombie
        let moveDirection: Float = player5.position.x > 0.0 ? -1.0 : 1.0
        let moveDistance: Float = 10
        let moveAction = SCNAction.moveBy(SCNVector3(x: moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 5)
        let removeAction = SCNAction.runBlock { node -> Void in
            //node.removeFromParentNode()
        }
        let moveAction2 = SCNAction.moveBy(SCNVector3(x: -moveDistance * moveDirection, y: 0.0, z: 0.0), duration: 5)
        
        //player2.runAction(SCNAction.sequence([moveAction, moveAction2]))
        player5.runAction(SCNAction.repeatActionForever(SCNAction.sequence([moveAction, moveAction2])))
        
        // Rotate the car to move it in the right direction

        
    }
    
    //////////////////////////////////////
    func setupPlayerAnimationSetPosition(position: SCNVector3)->PlayerCharacter {
        
        let url = NSBundle.mainBundle().URLForResource("art.scnassets/common/models/explorer/explorer_skinned", withExtension: "dae")
        let source = SCNSceneSource(URL: url!, options:nil)
        let rootNode2 = source!.entryWithIdentifier("group", withClass:SCNNode.self) as! SCNNode
        
        let node:PlayerCharacter = PlayerCharacter(characterNode:rootNode2)
        node.scale = SCNVector3Make(0.05, 0.05, 0.05);
        node.position = SCNVector3Make(10, 0, -50);
        node.name = "player2"
        
        //rootNode.addChildNode(player)
        return node
        
    }
    
    
    func setupAnimation(){
        let Node: SCNNode = setupPlayerAnimationSetPosition(SCNVector3(x:  -10 , y: 0 , z: -50))
        rootNode.addChildNode(Node)
        
    }
    /////////////////////////////////////////////////
    
    func createStaticObject(position: SCNVector3, name: String)->SCNNode{
        let zombieScene = SCNScene(named: name)
        let node: SCNNode = zombieScene!.rootNode.childNodeWithName(name, recursively: false)!
        
        node.name = name
        node.position = SCNVector3(x: position.x, y: position.y, z: position.z)
        //node.scale = SCNVector3Make(2, 2, 2)
        
        //        let zombieShape = SCNPhysicsShape(geometry: SCNCylinder(radius: 2, height: 6), options: nil)
        //        node.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: zombieShape)
        
        
        let body = SCNPhysicsBody.staticBody()
        body.allowsResting = false
        body.mass = 0
        body.restitution = 0.1
        body.friction = 0.5
        body.rollingFriction = 0
        
        node.physicsBody = body
        //        node.physicsBody?.categoryBitMask = CollisionCategory.Monster
        //        node.physicsBody?.collisionBitMask = CollisionCategory.Bullet
        
        return node
    }
    
    
    func setupStaticObject(){
        
        let Node: SCNNode = createStaticObject(SCNVector3(x:  0 , y: 0 , z: 0), name: "stageObject")
        rootNode.addChildNode(Node)
        
        var i:Int = 0
        
        for i = 0 ; i < 20 ; i++ {
            let Node: SCNNode = createStaticObject(SCNVector3(x:  35 , y: 5 , z: -Float(+(i-1)*160)), name: "building2")
            rootNode.addChildNode(Node)
            
            let Node2: SCNNode = createStaticObject(SCNVector3(x:  35 , y: 5 , z: -Float(20+(i-1)*160)), name: "building3")
            rootNode.addChildNode(Node2)
            
            let Node3: SCNNode = createStaticObject(SCNVector3(x:  35 , y: 5 , z: -Float(40+(i-1)*160)), name: "building5")
            rootNode.addChildNode(Node3)
            
            let Node4: SCNNode = createStaticObject(SCNVector3(x:  35 , y: 5 , z: -Float(60+(i-1)*160)), name: "building6")
            rootNode.addChildNode(Node4)
        }
        
        
        for i = 0 ; i < 20 ; i++ {
            let Node: SCNNode = createStaticObject(SCNVector3(x:  -35 , y: 5 , z: -Float(+(i-1)*160)), name: "building6")
            rootNode.addChildNode(Node)
            
            let Node2: SCNNode = createStaticObject(SCNVector3(x:  -35 , y: 5 , z: -Float(20+(i-1)*160)), name: "building5")
            rootNode.addChildNode(Node2)
            
            let Node3: SCNNode = createStaticObject(SCNVector3(x:  -35 , y: 5 , z: -Float(40+(i-1)*160)), name: "building3")
            rootNode.addChildNode(Node3)
            
            let Node4: SCNNode = createStaticObject(SCNVector3(x:  -35 , y: 5 , z: -Float(60+(i-1)*160)), name: "building2")
            rootNode.addChildNode(Node4)
        }
        
        for i = 0 ; i < 4 ; i++ {
            let Node: SCNNode = createStaticObject(SCNVector3(x:  6 , y: 0 , z: -Float(20)), name: "block")
            rootNode.addChildNode(Node)
            
            let Node2: SCNNode = createStaticObject(SCNVector3(x:  3 , y: 0 , z: -Float(60)), name: "ambulance")
            rootNode.addChildNode(Node2)
            
            let Node3: SCNNode = createStaticObject(SCNVector3(x:  6 , y: 0 , z: -Float(90)), name: "bus2")
            rootNode.addChildNode(Node3)
            
            let Node4: SCNNode = createStaticObject(SCNVector3(x:  5 , y: 0 , z: -Float(120)), name: "container")
            rootNode.addChildNode(Node4)
        }
        
        
        
        //                for entity in map.entities {
        //
        //                    //let Node: SCNNode = createZombieNode(SCNVector3(x: entity.y - 60 , y: 0.0 , z: -1 * entity.x))
        //                    let Node: SCNNode = createZombieNode(SCNVector3(x:  10 , y: 0.0 , z: -10))
        //
        //                    rootNode.addChildNode(Node)
        //
        //
        //                    //Move the Zombie
        //                    let moveDirection: Float = Node.position.x > 0.0 ? -1.0 : 1.0
        //                    let moveDistance: Float = 60.0
        //                    let moveAction = SCNAction.moveBy(SCNVector3(x:moveDirection * moveDirection, y: 0.0, z: 0.0), duration: 10.0)
        //
        //                    Node.runAction(SCNAction.sequence([moveAction]))
        //
        //                    // Rotate the car to move it in the right direction
        //                    //            if moveDirection > 0.0 {
        //                    //                Node.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: 3.1415)
        //                    //
        //                    //            }
        //
        //                }
    }
    
    
    func sizeOfBoundingBoxFromNode(node: SCNNode) -> (width: Float, height: Float, depth: Float) {
        var boundingBoxMin = SCNVector3Zero
        var boundingBoxMax = SCNVector3Zero
        let boundingBox = node.getBoundingBoxMin(&boundingBoxMin, max: &boundingBoxMax)
        
        let width = boundingBoxMax.x - boundingBoxMin.x
        let height = boundingBoxMax.y - boundingBoxMin.y
        let depth = boundingBoxMax.z - boundingBoxMin.z
        println("\(width), \(height), \(depth)")
        return (width, height, depth)
    }
    
    func setupLevel(){
        
        let floor = SCNFloor()
        floor.reflectivity = 0.1
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3Make(0, -0.1, 0)
        floorNode.geometry?.firstMaterial?.diffuse.contents = "desertTexture.jpg"
        //floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        floorNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(0.5, 1, 0.5);
        floorNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = false
        floorNode.position = SCNVector3Zero
        floorNode.geometry!.firstMaterial?.diffuse.wrapS = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial?.diffuse.wrapT = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial?.diffuse.mipFilter = SCNFilterMode.Linear
        
        let particleNode = SCNNode()
        particleNode.position = SCNVector3(x: 0, y: 10, z: -20)
        let fire = SCNParticleSystem(named: "rainParticle", inDirectory: nil)
        particleNode.addParticleSystem(fire)
        playerNode.addChildNode(particleNode)
        
        let staticBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        //                floorNode.physicsBody?.categoryBitMask = CollisionCategory.Map
        floorNode.physicsBody = staticBody
        rootNode.addChildNode(floorNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.2, alpha: 0.1)
        rootNode.addChildNode(ambientLightNode)
        
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = SCNLightTypeSpot
        //spotLightNode.position = SCNVector3Make(0, 80, playerNode.position.z - 10)
        spotLightNode.position = SCNVector3Make(playerNode.position.x, playerNode.position.y-2, playerNode.position.z + 5)
        spotLightNode.rotation = SCNVector4Make(1, 0, 0,  Float(-M_PI)/2.8)
        spotLightNode.orientation = SCNQuaternion(x: 0, y: 0, z: 1, w: 0.5)
        spotLightNode.light?.spotInnerAngle = 0
        spotLightNode.light!.spotOuterAngle = 30
        
        spotLightNode.light?.shadowColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3);
        spotLightNode.light?.zFar = 50;
        spotLightNode.light?.zNear = -10;
        playerNode.addChildNode(spotLightNode)
        
//        let spotLightNodeRight = SCNNode()
//        spotLightNodeRight.light = SCNLight()
//        spotLightNodeRight.light?.type = SCNLightTypeSpot
//        //spotLightNode.position = SCNVector3Make(0, 80, playerNode.position.z - 10)
//        spotLightNodeRight.position = SCNVector3Make(playerNode.position.x-4, playerNode.position.y-2, playerNode.position.z + 5)
//        spotLightNodeRight.rotation = SCNVector4Make(1, 0, 0,  Float(-M_PI)/2.8)
//        spotLightNodeRight.orientation = SCNQuaternion(x: 0, y: 0, z: 1, w: 0.5)
//        spotLightNodeRight.light?.spotInnerAngle = 0
//        spotLightNodeRight.light!.spotOuterAngle = 20
//        
//        spotLightNodeRight.light?.shadowColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3);
//        spotLightNodeRight.light?.zFar = 100;
//        spotLightNodeRight.light?.zNear = 0;
//        playerNode.addChildNode(spotLightNodeRight)

        
        let fireParticleNode = SCNNode()
        fireParticleNode.position = SCNVector3(x: 0, y: 0, z: -15)
        let fireOnGround = SCNParticleSystem(named: "fireParticle", inDirectory: nil)
        fireParticleNode.addParticleSystem(fireOnGround)
        //rootNode.addChildNode(fireParticleNode)
        
        
        // fog
        //                fogStartDistance = 10
        //                fogEndDistance = 30
        //                fogDensityExponent = 2
        //                fogColor = UIColor.blackColor()
        
        
        var i:Int = 0
        for i; i < 100 ; i++ {
            setRoad(Float(i))
        }
        
    }
    
    func setRoad(roadPosition: Float){
        
        let floor = SCNFloor()
        floor.reflectivity = 0.1
        let roadNode = SCNNode(geometry: floor)
        roadNode.position = SCNVector3Make(0, 0, 50 + (-roadPosition*50))
        roadNode.geometry = SCNBox(width: 20, height: 0.5, length: 50, chamferRadius: 0)

        roadNode.geometry!.firstMaterial!.locksAmbientWithDiffuse = false
        roadNode.geometry?.firstMaterial!.diffuse.contents = "roadTexture.jpg"
        roadNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1, 1, 1)
        roadNode.geometry!.firstMaterial?.diffuse.wrapS = SCNWrapMode.Repeat
        roadNode.geometry!.firstMaterial?.diffuse.wrapT = SCNWrapMode.Repeat
        roadNode.geometry!.firstMaterial?.diffuse.mipFilter = SCNFilterMode.Linear
        
        roadNode.physicsBody = SCNPhysicsBody.staticBody()
        
        // add carpet
        
        rootNode.addChildNode(roadNode)
        
    }
    
    
    // Camera walking & player direction vector
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if gestureRecognizer == lookGesture {
            return touch.locationInView(sceneView).x > sceneView.frame.size.width / 2
            
        } else if gestureRecognizer == walkGesture {
            return touch.locationInView(sceneView).x < sceneView.frame.size.width / 2
            
        }
        else if gestureRecognizer == fireGesture{
            return (touch.locationInView(sceneView).x < sceneView.frame.size.width / 3) && (touch.locationInView(sceneView).y > sceneView.frame.size.height *  (2 / 3))
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func lookGestureRecognized(gesture: UIPanGestureRecognizer) {
        
        //get translation and convert to rotation
        let translation = gesture.translationInView(sceneView)
        let hAngle = acos(Float(translation.x) / 200) - Float(M_PI_2)
        let vAngle = acos(Float(translation.y) / 200) - Float(M_PI_2)
        
        //rotate palyer
        playerNode.physicsBody?.applyTorque(SCNVector4(x: 0, y: 1, z: 0, w: hAngle), impulse: true)
        
        //tilt camera
        elevation = max(Float(-M_PI_4), min(Float(M_PI_4), elevation + vAngle))
        camNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: elevation)
        //
        //reset translation
        gesture.setTranslation(CGPointZero, inView: sceneView)
    }
    
    func walkGestureRecognized(gesture: UIPanGestureRecognizer) {
        
        
        if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
            gesture.setTranslation(CGPointZero, inView: sceneView)
        }
    }
    
    func fireGestureRecognized(gesture: FireGestureRecognizer) {
        
        //update timestamp
        let now = CFAbsoluteTimeGetCurrent()
        
        
        if now - lastTappedFire < autofireTapTimeThreshold {
            tapCount += 1
        } else {
            tapCount = 1
        }
        lastTappedFire = now
    }
    
    
    // Game state control //
    
    // MARK: Game State
    func switchToWaitingForFirstTap() {
        
        gameState = GameState.WaitGame
        
        // Fade in
        if let overlay = sceneView.overlaySKScene {
            overlay.enumerateChildNodesWithName("RestartLevel", usingBlock: { node, stop in
                node.runAction(SKAction.sequence(
                    [SKAction.fadeOutWithDuration(0.5),
                        SKAction.removeFromParent()]))
            })
            
            // Tap to play animation icon
            let handNode = StartNode()
            handNode.position = CGPoint(x: sceneView.bounds.size.width * 0.5, y: sceneView.bounds.size.height * 0.5)
            
            overlay.addChild(handNode)
        }
    }
    
    
    func switchToPlaying() {
        
        gameState = GameState.GameStart
        
        //physicsWorld.contactDelegate = nil
        
        // 사운드 추가! //
        if let overlay = sceneView.overlaySKScene {
            
            // Remove tutorial
            overlay.enumerateChildNodesWithName("Tutorial", usingBlock: { node, stop in
                node.runAction(SKAction.sequence(
                    [SKAction.fadeOutWithDuration(0.5),
                        SKAction.removeFromParent()]))
            })
            
            sceneView.overlaySKScene = OverlayScene(size: sceneView.bounds.size)
        }
    }
    
    
    func switchToGameOver() {
        
        gameState = GameState.GameOver
        
        if let overlay = sceneView.overlaySKScene {
            
            let gameOverLabel = LabelNode(
                position: CGPoint(x: overlay.size.width/2.0, y: overlay.size.height/2.0),
                size: 24, color: .whiteColor(),
                text: "Game Over - Tap to restart",
                name: "GameOver")
            
            overlay.addChild(gameOverLabel)
            
            let clickToRestartLabel = LabelNode(
                position: CGPoint(x: gameOverLabel.position.x, y: gameOverLabel.position.y - 24.0),
                size: 14,
                color: .whiteColor(),
                text: "Score : \(playerNode.presentationNode().position.z * -0.1)",
                name: "GameOver")
            overlay.addChild(clickToRestartLabel)
            
            
            // Score node
        }
        //physicsWorld.contactDelegate = nil
    }
    
    
    func switchToRestartLevel() {
        
        gameState = GameState.GameRestart
        if let overlay = sceneView.overlaySKScene {
            
            // Fade out game over screen
            overlay.enumerateChildNodesWithName("GameOver", usingBlock: { node, stop in
                node.runAction(SKAction.sequence(
                    [SKAction.fadeOutWithDuration(0.25),
                        SKAction.removeFromParent()]))
            })
            
            // Fade to black - and create a new level to play
            let blackNode = SKSpriteNode(color: UIColor.blackColor(), size: overlay.frame.size)
            blackNode.name = "RestartLevel"
            blackNode.alpha = 0.0
            blackNode.position = CGPoint(x: sceneView.bounds.size.width/2.0, y: sceneView.bounds.size.height/2.0)
            overlay.addChild(blackNode)
            blackNode.runAction(SKAction.sequence([SKAction.fadeInWithDuration(0.5), SKAction.runBlock({
                let newScene = GameScene(view: self.sceneView)
                newScene.physicsWorld.contactDelegate = newScene
                self.sceneView.scene = newScene
                self.sceneView.delegate = newScene
            })]))
        }
    }
    
    //    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
    ////        if gameState == GameState.GameStart {
    ////            switchToGameOver()
    ////        }
    //    }
    
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        println("Contact between nodes: \(contact.nodeA.name) and \(contact.nodeB.name)")
        
        if(contact.nodeA.name == "PlayerCollideSphere" && contact.nodeB.name == "bulletNode") {
            player.handleContact(contact.nodeB)
            contact.nodeB.removeFromParentNode()
            
        }
        if(contact.nodeA.name == "PlayerCollideSphere2" && contact.nodeB.name == "bulletNode") {
            player2.handleContact(contact.nodeB)
            contact.nodeB.removeFromParentNode()
        }
        if(contact.nodeA.name == "PlayerCollideSphere3" && contact.nodeB.name == "bulletNode") {
            player3.handleContact(contact.nodeB)
            contact.nodeB.removeFromParentNode()
            
        }
        if(contact.nodeA.name == "PlayerCollideSphere4" && contact.nodeB.name == "bulletNode") {
            player4.handleContact(contact.nodeB)
            contact.nodeB.removeFromParentNode()
            
        }
        if(contact.nodeA.name == "PlayerCollideSphere5" && contact.nodeB.name == "bulletNode") {
            player5.handleContact(contact.nodeB)
            contact.nodeB.removeFromParentNode()
            
        }
        if(contact.nodeA.name == "playerNode" && contact.nodeB.name == "PlayerCollideSphere") {
            
            println(" player - zombie")
            let fireParticleNode = SCNNode()
            fireParticleNode.position = contact.nodeB.position
            let fireOnGround = SCNParticleSystem(named: "fireParticle", inDirectory: nil)
            fireParticleNode.addParticleSystem(fireOnGround)
            rootNode.addChildNode(fireParticleNode)
            
        }

        
        
        
        
        
        
        //        if(contact.nodeA.name == "Dummymaster") {
        //            println("bullet! A")
        //
        //            //            contact.nodeA.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        //            //contact.nodeA.runAction(SCNAction.rotateByX(3.14, y: 1, z: 0, duration: 1) )
        //
        //                let tmpNode = createParticle(contact.nodeB.position)
        //                tmpNode.name = "tmpNode"
        //                // Fire Particle System
        //                let fire = SCNParticleSystem(named: "MyParticleSystem", inDirectory: nil)
        //                fire.emitterShape = tmpNode.geometry
        //                fire.loops = false
        //                tmpNode.addParticleSystem(fire)
        ////
        ////
        ////            rootNode.addChildNode(tmpNode)
        //            // ----
        //
        //            println("Contact between nodes: \(contact.nodeA.name) and \(contact.nodeB.name)")
        //            //contact.nodeB.removeFromParentNode()
        //
        //
        //        }
        
    }
    
    func collideWithLava(node: SCNNode) {
        //Blink for a second
        let blinkOffAction = SCNAction.fadeOutWithDuration(0.15)
        let blinkOnAction = SCNAction.fadeInWithDuration(0.15)
        let cycle = SCNAction.sequence([blinkOffAction, blinkOnAction])
        let repeatCycle = SCNAction.repeatAction(cycle, count: 7)
        
        
        node.runAction(repeatCycle, completionHandler: {
            () -> Void in
            
            node.removeFromParentNode()
        })
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
    
    
    // MARK: Player movement
    func movePlayerInDirection() {
        
        
//        case WaitGame
//        case GameStart
//        case GameOver
//        case GameRestart
        
        switch gameState {
        case .WaitGame:
            
            // Start playing
            switchToPlaying()
            movePlayerInDirection()
            
            break
            
        case .GameStart:
            
            
            break
            
        case .GameOver:
            
            // Switch to tutorial
            switchToRestartLevel()
            break
            
        case .GameRestart:
            
            // Switch to new level
            switchToWaitingForFirstTap()
            break
        }
        
    }
    
    func update(currentTime: NSTimeInterval) {
        if let overlay = sceneView.overlaySKScene {
            
            
            let clickToRestartLabel = LabelNode(
                position: CGPoint(x: overlay.size.width/2.0, y: overlay.size.height/2.0 ),
                size: 14,
                color: .whiteColor(),
                text: "Score : \(playerNode.presentationNode().position.z * -0.1)",
                name: "GameOver")
            overlay.addChild(clickToRestartLabel)
            
            
            // Score node
        }
    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
//        if gameState == GameState.GameStart && playerNode.presentationNode().position.z < -100{ // -500 : tunnel
//            
//            switchToGameOver()
//        }
        


        
        //get walk gesture translation
        var translation = walkGesture.translationInView(sceneView)
        
        //create impulse vector for hero
        let angle = playerNode.presentationNode().rotation.w * playerNode.presentationNode().rotation.y
        
        var impulse = SCNVector3(x: max(-1, min(1, Float(translation.x) / 50)), y: 0, z: max(-1, min(1, Float(-translation.y) / 50)))
        impulse = SCNVector3(
            x: impulse.x * cos(angle) - impulse.z * sin(angle),
            y: 0,
            z: impulse.x * -sin(angle) - impulse.z * cos(angle)
        )
        playerNode.physicsBody?.applyForce(impulse, impulse: true)
        
        //handle firing
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastTappedFire < autofireTapTimeThreshold {
            let fireRate = min(Double(maxRoundsPerSecond), Double(tapCount) / autofireTapTimeThreshold)
            if now - lastFired > 1 / fireRate {
                
                //get hero direction vector
                let angle = playerNode.presentationNode().rotation.w * playerNode.presentationNode().rotation.y
                var direction = SCNVector3(x: -sin(angle), y: 0, z: -cos(angle))
                
                //get elevation
                direction = SCNVector3(x: cos(elevation) * direction.x, y: sin(elevation), z: cos(elevation) * direction.z)
                
                //create or recycle bullet node
                let bulletNode: SCNNode = {
                    if self.bullets.count < self.maxBullets {
                        return SCNNode()
                    } else {
                        return self.bullets.removeAtIndex(0)
                    }
                    }()
                
                bullets.append(bulletNode)
                bulletNode.geometry = SCNBox(width: CGFloat(bulletRadius), height: CGFloat(bulletRadius) , length: CGFloat(bulletRadius), chamferRadius: CGFloat(bulletRadius))
                
                bulletNode.position = SCNVector3(x: playerNode.presentationNode().position.x, y: playerNode.presentationNode().position.y, z: playerNode.presentationNode().position.z - 2.0)
                
                //bulletNode.position = SCNVector3(x: camNode.presentationNode().position.x, y: camNode.presentationNode().position.y , z: camNode.presentationNode().position.z)
                
                bulletNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletNode.geometry!, options: nil))
                
                bulletNode.geometry?.firstMaterial?.diffuse.contents = "buttletTexture.jpg"
                bulletNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(0.5, 1, 0.5);
                bulletNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
                bulletNode.name = "bulletNode"
                
                // ---- particle
                // Fire Particle System
                let fire = SCNParticleSystem(named: "bulletParticle3D", inDirectory: nil)
                fire.emitterShape = bulletNode.geometry
                bulletNode.addParticleSystem(fire)
                // ----
                
                bulletNode.physicsBody?.categoryBitMask = CollisionCategory.Bullet
                bulletNode.physicsBody?.collisionBitMask = CollisionCategory.All ^ CollisionCategory.Monster
                
                bulletNode.physicsBody?.velocityFactor = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
                sceneView.scene!.rootNode.addChildNode(bulletNode)
                
                //apply impulse
                var impulse = SCNVector3(x: direction.x * Float(bulletImpulse), y: direction.y * Float(bulletImpulse), z: direction.z * Float(bulletImpulse))
                bulletNode.physicsBody?.applyForce(impulse, impulse: true)
                
                //update timestamp
                lastFired = now
                
            }
        }
    }
    
}
