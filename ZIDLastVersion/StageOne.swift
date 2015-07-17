//
//  StageOne.swift
//  ZIDLastVersion
//
//  Created by KimPan Jung on 2015. 7. 18..
//  Copyright (c) 2015년 KPJ. All rights reserved.
//

import SceneKit

class StageOne : SCNNode{
 
    var getRootNode: SCNNode!
    
    //mapNode
    var mapNode: SCNNode!
    var mapChildNode: SCNNode!
    let mapScene = SCNScene(named: "Dummymaster")
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(){
        super.init()
        setupStageOne()
    }
    
    init(initNode: SCNNode) {
        self.getRootNode = initNode

        super.init()

    }
    

    func setupStageOne(){
        setupFloorAndRoad(getRootNode)
        setupStaticObject(getRootNode)
    }
    
    func setupMap(tmpNode: SCNNode){
        
        mapChildNode = mapScene!.rootNode.childNodeWithName("Dummymaster", recursively: false)!
        mapChildNode.position = SCNVector3(x: 0.0, y: -10 , z: -50)
        mapChildNode.scale = SCNVector3(x: 100, y: 100, z: 100)
        mapChildNode.name = "mapNode"
        
        let body = SCNPhysicsBody.dynamicBody()
        body.mass = 0
        
        mapChildNode.physicsBody?.categoryBitMask = CollisionCategory.Map
        mapChildNode.physicsBody?.collisionBitMask = CollisionCategory.All ^ CollisionCategory.Bullet
        
        mapChildNode.physicsBody = body
        tmpNode.addChildNode(mapChildNode)
    }
    
    func environment(tmpNode: SCNNode){
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
        tmpNode.addChildNode(wall)
        
        let wallC = wall.clone() as! SCNNode
        wallC.position = SCNVector3Make(-20, 0, -500)
        wallC.rotation = SCNVector4Make(0, 1, 0, Float(M_PI_2))
        tmpNode.addChildNode(wallC)
        
        let wallD = wall.clone() as! SCNNode
        wallD.position = SCNVector3Make(20, 0, -500)
        wallD.rotation = SCNVector4Make(0, 1, 0, Float(-M_PI_2))
        tmpNode.addChildNode(wallD)
        
    }
    
    func createStaticObject(position: SCNVector3, name: String)->SCNNode{
        let zombieScene = SCNScene(named: name)
        let node: SCNNode = zombieScene!.rootNode.childNodeWithName(name, recursively: false)!
        
        node.name = name
        node.position = SCNVector3(x: position.x, y: position.y, z: position.z)
        
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
    
    
    func setupStaticObject(tmpNode: SCNNode){
        
        let Node: SCNNode = createStaticObject(SCNVector3(x:  0 , y: 0 , z: 0), name: "Dummymaster")
        tmpNode.addChildNode(Node)
        
    }
    
    
    func setupFloorAndRoad(tmpNode: SCNNode){
        
        let floor = SCNFloor()
        floor.reflectivity = 0.1
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3Make(0, -0.1, 0)
        floorNode.geometry?.firstMaterial?.diffuse.contents = "desertTexture.jpg"
        floorNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(0.5, 1, 0.5);
        floorNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = false
        floorNode.position = SCNVector3Zero
        floorNode.geometry!.firstMaterial?.diffuse.wrapS = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial?.diffuse.wrapT = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial?.diffuse.mipFilter = SCNFilterMode.Linear
        
        let staticBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        floorNode.physicsBody = staticBody
        tmpNode.addChildNode(floorNode)
        
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
            setRoad(Float(i), tmpNode: tmpNode)
        }
        
    }
    
    func setRoad(roadPosition: Float, tmpNode: SCNNode){
        
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
        tmpNode.addChildNode(roadNode)
    }
}
