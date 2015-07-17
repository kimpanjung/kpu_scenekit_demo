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

class GameScene : SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate,UIGestureRecognizerDelegate {
    
    var sceneView: SCNView!
    var gameState = GameState.WaitGame
    
    // Bullet //
    let autofireTapTimeThreshold = 0.5
    let maxRoundsPerSecond = 10
    let bulletRadius = 0.05 // 0.05
    let bulletImpulse = 100
    let maxBullets = 1
    
    // Camera
    var lookGesture: UIPanGestureRecognizer!
    var walkGesture: UIPanGestureRecognizer!
    var fireGesture: FireGestureRecognizer!
    var camNode: SCNNode!
    
    // Player & zombie Scene/Node
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
    
    // StaticObject (stage)
    var stageOneNode: StageOne!

    
    // tap control //
    var elevation: Float = 0
    var tapCount = 0
    var lastTappedFire: NSTimeInterval = 0
    var lastFired: NSTimeInterval = 0
    var bullets = [SCNNode]()
    var steering: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    // *** GameScene method *** //
    init(view: SCNView) {
        sceneView = view
        super.init()
        // game initialize method
        initGame()
    }

    
    func initGame(){
        
        // dynamic object
        setupPlayer(SCNVector3(x: 0 , y: 2.0 , z: 0))
        
        
        setupPlayerAnimation(SCNVector3(x: 0, y: 0, z: -40))
        setupPlayerAnimation2(SCNVector3(x: 8, y: 0, z: -120))
        setupPlayerAnimation3(SCNVector3(x: -8, y: 0, z: -200))
        setupPlayerAnimation4(SCNVector3(x: -2, y: 0, z: -300))
        setupPlayerAnimation5(SCNVector3(x: -4, y: 0, z: -450))
        
        // static object
        stageOneNode = StageOne(initNode: rootNode)
        stageOneNode.setupStageOne()
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
    
    func setupPlayer(firstPosition: SCNVector3){
        // player Node
        playerNode = SCNNode()
        playerNode.position = firstPosition
        playerNode.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)

        playerNode.physicsBody = SCNPhysicsBody.dynamicBody()
        playerNode.physicsBody?.angularDamping = 0.9999999
        playerNode.physicsBody?.damping = 0.9999999
        playerNode.physicsBody?.rollingFriction = 100
        playerNode.physicsBody?.friction = 0
        playerNode.physicsBody?.restitution = 0
        playerNode.physicsBody?.velocityFactor = SCNVector3(x: 5, y:0, z: 5) // (not y==0 ) affected by gravity
        
        
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
        
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = SCNLightTypeSpot
        spotLightNode.position = SCNVector3Make(playerNode.position.x, playerNode.position.y-2, playerNode.position.z + 5)
        spotLightNode.rotation = SCNVector4Make(1, 0, 0,  Float(-M_PI)/2.8)
        spotLightNode.orientation = SCNQuaternion(x: 0, y: 0, z: 1, w: 0.5)
        spotLightNode.light?.spotInnerAngle = 0
        spotLightNode.light!.spotOuterAngle = 30
        
        spotLightNode.light?.shadowColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3);
        spotLightNode.light?.zFar = 50;
        spotLightNode.light?.zNear = -10;
        playerNode.addChildNode(spotLightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.2, alpha: 0.1)
        rootNode.addChildNode(ambientLightNode)
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
        player.runAction(SCNAction.repeatActionForever(SCNAction.sequence([moveAction, moveAction2])))
        
        //player.constraints = [SCNLookAtConstraint(target: playerNode)]
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
    // Game State
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
    }
    
    func createParticle(position: SCNVector3)->SCNNode{
        let fire = SCNParticleSystem(named: "bulletParticle3D", inDirectory: nil)
        let Node = SCNNode()
        Node.position = position
        fire.emitterShape = Node.geometry
        Node.addParticleSystem(fire)
        return Node
    }
    
    // MARK: Player movement
    func movePlayerInDirection() {
        
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
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {

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
                
                bulletNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletNode.geometry!, options: nil))
                
                bulletNode.geometry?.firstMaterial?.diffuse.contents = "buttletTexture.jpg"
                bulletNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(0.5, 1, 0.5);
                bulletNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
                bulletNode.name = "bulletNode"
                
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
