//
//  GameScene.swift
//  ZIDLastVersion
//
//  Created by KimPan Jung on 2015. 5. 11..
//  Copyright (c) 2015년 KPJ. All rights reserved.
//

import SceneKit
import SpriteKit


class GameScene : SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate,UIGestureRecognizerDelegate {

    
    var sceneView: SCNView!
    var gameState = GameState.WaitGame
    
    // Bullet //
    let autofireTapTimeThreshold = 0.5
    let maxRoundsPerSecond = 30
    let bulletRadius = 0.05
    let bulletImpulse = 15
    let maxBullets = 100
    
    // Camera
    var lookGesture: UIPanGestureRecognizer!
    var walkGesture: UIPanGestureRecognizer!
    var fireGesture: FireGestureRecognizer!
    var camNode: SCNNode!

    // Player & zombie Scene/Node
    var playerNode: SCNNode!
    var playerChildNode: SCNNode!
    let playerScene = SCNScene(named: "art.scnassets/ship.dae")
    // zombie
    var zombieNode: SCNNode!
    var zombieChildNode: SCNNode!
//    let zombieScene = SCNScene(named: "zombie_skinned.dae")
    let zombieScene = SCNScene(named: "zombietest")
    //mapNode
    var mapNode: SCNNode!
    var mapChildNode: SCNNode!
    let mapScene = SCNScene(named: "test4")
    
    
    // tap control //
    var elevation: Float = 0
    
    var tapCount = 0
    var lastTappedFire: NSTimeInterval = 0
    var lastFired: NSTimeInterval = 0
    var bullets = [SCNNode]()
    
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

        setupPlayer()
        setupZombie()
        //testPhysicsWorld()
        //setupCamera()
        setupMap()
        setupLevel()
        setupGestureRecognizer()
        switchToWaitingForFirstTap()

    }
    
    func setupGestureRecognizer(){
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
        
        lookGesture = UIPanGestureRecognizer(target: self, action: "lookGestureRecognized:")
        lookGesture.delegate = self
        sceneView.addGestureRecognizer(lookGesture)
        
        //walk gesture
        walkGesture = UIPanGestureRecognizer(target: self, action: "walkGestureRecognized:")
        walkGesture.delegate = self
        sceneView.addGestureRecognizer(walkGesture)
        
        //fire gesture
        fireGesture = FireGestureRecognizer(target: self, action: "fireGestureRecognized:")
        fireGesture.delegate = self
        sceneView.addGestureRecognizer(fireGesture)
    }
    
    // tap to start!
    func handleTap(gesture: UIGestureRecognizer) {
        if let tapGesture = gesture as? UITapGestureRecognizer {
            switchToPlaying()
        }
    }
    
    func setupMap(){
        mapNode = SCNNode()
        mapNode.name = "map"
//        mapNode.rotation = SCNVector4Make(0, 0, 1, 90.0)
        mapNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        mapChildNode = mapScene!.rootNode.childNodeWithName("Dummymaster", recursively: false)!
        mapChildNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0)
        mapChildNode.scale = SCNVector3(x: 100, y: 100, z: 100)
//        mapChildNode.rotation = SCNVector4Make(0, 0, 0, 90.0)
        
        let body = SCNPhysicsBody.staticBody()
        mapChildNode.physicsBody = body
        //mapChildNode.physicsBody?.categoryBitMask = CollisionCategory.Map
        rootNode.addChildNode(mapChildNode)
        
        
        println("\(sizeOfBoundingBoxFromNode(mapChildNode).width), \(sizeOfBoundingBoxFromNode(mapChildNode).height), \(sizeOfBoundingBoxFromNode(mapChildNode).depth)")
        // 290 29 30
        
        
//
//        mapNode.addChildNode(mapChildNode)
//        
//        SCNPhysicsShape(geometry: SCNCylinder(radius: 0.2, height: 1), options: nil)
//        SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(node: zombieChildNode , options: nil))
//        
//        mapNode.physicsBody?.categoryBitMask = CollisionCategory.Map
//        mapNode.physicsBody?.collisionBitMask = CollisionCategory.All
//        mapNode.physicsBody?.velocityFactor = SCNVector3(x: 5, y:1, z: 5) // ***(not) affected by gravity
//        
//        rootNode.addChildNode(mapNode)
    }
    
    func setupPlayer(){
        // player Node
        playerNode = SCNNode()
        playerNode.position = SCNVector3(x: 0.0, y: ControlVariable.playerHeight, z: 0.0)
        
        playerNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: SCNCylinder(radius: 0.2, height: 1), options: nil))
        playerNode.physicsBody?.angularDamping = 0.9999999
        playerNode.physicsBody?.damping = 0.9999999
        playerNode.physicsBody?.rollingFriction = 0
        playerNode.physicsBody?.friction = 0
        playerNode.physicsBody?.restitution = 0
        playerNode.physicsBody?.velocityFactor = SCNVector3(x: 5, y:0, z: 5) // (not y==0 ) affected by gravity
        playerNode.physicsBody?.categoryBitMask = CollisionCategory.Player
        playerNode.physicsBody?.collisionBitMask = CollisionCategory.All ^ CollisionCategory.Bullet
        rootNode.addChildNode(playerNode)
        
        //add a camera node
        camNode = SCNNode()
        camNode.position = SCNVector3(x: 0, y: 0, z: 0)
        playerNode.addChildNode(camNode)
        
        //add camera
        let camera = SCNCamera()
        camera.zNear = 0.01
        camera.zFar = 500
        camNode.camera = camera

    }
    
    func setupZombie(){
        
        zombieNode = zombieScene!.rootNode.childNodeWithName("root", recursively: false)
        zombieNode.name = "zombieNode"
        zombieNode.position = SCNVector3Make(0, 0, -50)
        zombieNode.scale = SCNVector3Make(10, 10, 10)
        
        let zombieShape = SCNPhysicsShape(geometry: SCNCylinder(radius: 1, height: 6), options: nil)
        zombieNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: zombieShape)
        zombieNode.physicsBody?.categoryBitMask = CollisionCategory.Monster
        zombieNode.physicsBody?.collisionBitMask = CollisionCategory.Bullet
        
        sizeOfBoundingBoxFromNode(zombieNode)

        rootNode.addChildNode(zombieNode)
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
    
    func testPhysicsWorld(){
        let monsterNode = SCNNode()
        monsterNode.position = SCNVector3(x: 0, y: 0.4, z: -20)
        monsterNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: 90)
        monsterNode.geometry = SCNCylinder(radius: 1, height: 6)
        monsterNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: monsterNode.geometry!, options: nil))
        monsterNode.physicsBody?.categoryBitMask = CollisionCategory.Monster
        monsterNode.physicsBody?.collisionBitMask = CollisionCategory.All
        rootNode.addChildNode(monsterNode)
    }
    
    
    func setupCamera(){
        //add a camera node
        camNode = SCNNode()
        camNode.position = SCNVector3(x: 0, y: 0, z: 0)
        playerNode.addChildNode(camNode)
        
        //add camera
        let camera = SCNCamera()
        camera.zNear = 0.01
        camera.zFar = 500
        camNode.camera = camera
    }
    
    func setupLevel(){
        let floor = SCNFloor()
        floor.reflectivity = 0.1
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3Make(0, -0.1, 0)
        floorNode.geometry?.firstMaterial?.diffuse.contents = "desertTexture.jpg"
        //floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
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
        rootNode.addChildNode(particleNode)
        
//        let staticBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
//        floorNode.physicsBody?.categoryBitMask = CollisionCategory.Map
//        floorNode.physicsBody = staticBody
        
        
        //rootNode.addChildNode(floorNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeOmni
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        rootNode.addChildNode(ambientLightNode)
        
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = SCNLightTypeSpot
        spotLightNode.position = SCNVector3Make(0, 80, 30)
        spotLightNode.rotation = SCNVector4Make(1, 0, 0,  Float(-M_PI)/2.8)
        spotLightNode.light?.spotInnerAngle = 0
        spotLightNode.light?.shadowColor = SKColor(red: 1, green: 1, blue: 0.8, alpha: 0.7);
        spotLightNode.light?.zFar = 15;
        spotLightNode.light?.zNear = 10;
        playerNode.addChildNode(spotLightNode)
    }
    
    
    // Camera walking & player direction vector
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        //test if we hit the camera button
//        let scene = OverlayScene(size: sceneView.bounds.size)
//        var p = touch.locationInView(sceneView)
////        p = scene.convertPointFromView(p)
//        let node = scene.nodeAtPoint(p)
//        
//        
//        if node.name != nil && node.name == "shoot" {
//            //play a sound
//            node.runAction(SKAction.playSoundFileNamed("bulletSound.mp3", waitForCompletion: false))
//            
//            p = node.position
//            
//            //change the point of view
//
//        }
//        
//        println("\(p)")
        
        //update the total number of touches on screen


        
        if gestureRecognizer == lookGesture {
            return touch.locationInView(sceneView).x > sceneView.frame.size.width / 2
            
        } else if gestureRecognizer == walkGesture {
            return touch.locationInView(sceneView).x < sceneView.frame.size.width / 2
            
        }
        //else if gestureRecognizer == fireGesture{
//            return touch.locationInView(sceneView) == p
//        }

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
    
    // MARK: Game State
    func switchToWaitingForFirstTap() {
        
        gameState = GameState.WaitGame
        
        // Fade in
        if let overlay = sceneView.overlaySKScene {
            overlay.enumerateChildNodesWithName("GameRestart", usingBlock: { node, stop in
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
                text: "Game Over",
                name: "GameOver")
            
            overlay.addChild(gameOverLabel)
            
            let clickToRestartLabel = LabelNode(
                position: CGPoint(x: gameOverLabel.position.x, y: gameOverLabel.position.y - 24.0),
                size: 14,
                color: .whiteColor(),
                text: "Tap to restart",
                name: "GameOver")
            
            overlay.addChild(clickToRestartLabel)
        }
        physicsWorld.contactDelegate = nil
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
            blackNode.name = "GameRestart"
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
                bulletNode.geometry = SCNBox(width: CGFloat(bulletRadius) * 2, height: CGFloat(bulletRadius) * 2, length: CGFloat(bulletRadius) * 2, chamferRadius: CGFloat(bulletRadius))
                bulletNode.position = SCNVector3(x: playerNode.presentationNode().position.x, y: playerNode.presentationNode().position.y, z: playerNode.presentationNode().position.z)
                bulletNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletNode.geometry!, options: nil))
                
                bulletNode.geometry?.firstMaterial?.diffuse.contents = "buttletTexture.jpg"
                bulletNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(0.5, 1, 0.5);
                bulletNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
                
                
                // ---- particle
                // Fire Particle System, attached to the boing ball
                let fire = SCNParticleSystem(named: "bulletParticle3D", inDirectory: nil)
                fire.emitterShape = bulletNode.geometry
                bulletNode.addParticleSystem(fire)
                // ----
                
                bulletNode.physicsBody?.categoryBitMask = CollisionCategory.Bullet
                bulletNode.physicsBody?.collisionBitMask = CollisionCategory.All ^ CollisionCategory.Player
                    //| CollisionCategory.Map
                bulletNode.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0.2, z: 1)
                sceneView.scene!.rootNode.addChildNode(bulletNode)
                
                //apply impulse
                var impulse = SCNVector3(x: direction.x * Float(bulletImpulse), y: direction.y * Float(bulletImpulse), z: direction.z * Float(bulletImpulse))
                bulletNode.physicsBody?.applyForce(impulse, impulse: true)
                
                //update timestamp
                lastFired = now
            }
        }
    }
    
    func torchLight() -> SCNLight
    {
        var light = SCNLight()
        light.type = SCNLightTypeOmni;
        light.color = SKColor.orangeColor()
        light.attenuationStartDistance = 350;
        light.attenuationEndDistance = 400;
        light.attenuationFalloffExponent = 1;
        return light;
    }
    


    
}
