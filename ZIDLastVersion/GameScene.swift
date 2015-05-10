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
    let autofireTapTimeThreshold = 0.2
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
    let zombieScene = SCNScene(named: "art.scnassets/ship.dae")
    
    var elevation: Float = 0
    var mapNode: SCNNode!
    
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
        setupCamera()
        setupLevel()
        setupGestureRecognizer(sceneView)

    }
    
    func setupGestureRecognizer(view: SCNView){
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
    
    func setupPlayer(){
        playerNode = SCNNode()
        playerNode.name = "Player"
        playerNode.position = SCNVector3Zero
        playerNode.position.y = 0.2
        
        let playerMaterial = SCNMaterial()
        playerMaterial.diffuse.contents = UIImage(named: "art.scnassets/texture.png")
        playerMaterial.locksAmbientWithDiffuse = false
        
//        playerChildNode = playerScene!.rootNode.childNodeWithName("ship", recursively: false)!
//        playerChildNode.geometry!.firstMaterial = playerMaterial
//        playerChildNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.075)
//        
//        playerNode.addChildNode(playerChildNode)
        
//        // Create a physicsbody for collision detection
//        let playerPhysicsBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.08, height: 0.08, length: 0.08, chamferRadius: 0.0), options: nil)
//        
//        playerChildNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: playerPhysicsBodyShape)
//        playerChildNode.physicsBody!.categoryBitMask = CollisionCategory.Player
//        playerChildNode.physicsBody!.collisionBitMask = CollisionCategory.Zombie
        
        rootNode.addChildNode(playerNode)
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
        floorNode.geometry?.firstMaterial?.diffuse.contents = "desert.jpeg"
        //floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        floorNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(0.5, 1, 0.5);
        floorNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = false
        floorNode.position = SCNVector3Zero
        
        floorNode.geometry!.firstMaterial?.diffuse.wrapS = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial?.diffuse.wrapT = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial?.diffuse.mipFilter = SCNFilterMode.Linear
        
        let staticBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        floorNode.physicsBody?.categoryBitMask = CollisionCategory.Map
        floorNode.physicsBody = staticBody
        rootNode.addChildNode(floorNode)
        
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if gestureRecognizer == lookGesture {
            return touch.locationInView(sceneView).x > sceneView.frame.size.width / 2
        } else if gestureRecognizer == walkGesture {
            return touch.locationInView(sceneView).x < sceneView.frame.size.width / 2
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func lookGestureRecognized(gesture: UIPanGestureRecognizer) {
        
        //get translation and convert to rotation
        let translation = gesture.translationInView(self.sceneView)
        let hAngle = acos(Float(translation.x) / 200) - Float(M_PI_2)
        let vAngle = acos(Float(translation.y) / 200) - Float(M_PI_2)
        
        var tmpNode = SCNNode()
        tmpNode.name = "heroNode"
        
        //rotate hero
        playerNode.physicsBody?.applyTorque(SCNVector4(x: 0, y: 1, z: 0, w: hAngle), impulse: true)
        
        //tilt camera
        elevation = max(Float(-M_PI_4), min(Float(M_PI_4), elevation + vAngle))
        camNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: elevation)
        
        //reset translation
        gesture.setTranslation(CGPointZero, inView: self.sceneView)
    }
    
    func walkGestureRecognized(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
            gesture.setTranslation(CGPointZero, inView: self.sceneView)
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
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        //get walk gesture translation
        var translation = walkGesture.translationInView(self.sceneView)
        
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
                bulletNode.position = SCNVector3(x: playerNode.presentationNode().position.x, y: 0.4, z: playerNode.presentationNode().position.z)
                bulletNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletNode.geometry!, options: nil))
                bulletNode.physicsBody?.categoryBitMask = CollisionCategory.Bullet
                bulletNode.physicsBody?.collisionBitMask = CollisionCategory.None ^ CollisionCategory.Player | CollisionCategory.Map
                bulletNode.physicsBody?.velocityFactor = SCNVector3(x: 1, y: 0.5, z: 1)
                self.sceneView.scene!.rootNode.addChildNode(bulletNode)
                
                //apply impulse
                var impulse = SCNVector3(x: direction.x * Float(bulletImpulse), y: direction.y * Float(bulletImpulse), z: direction.z * Float(bulletImpulse))
                bulletNode.physicsBody?.applyForce(impulse, impulse: true)
                
                //update timestamp
                lastFired = now
            }
        }
    }

    
}
