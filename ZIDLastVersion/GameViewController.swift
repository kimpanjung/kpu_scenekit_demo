//
//  GameViewController.swift
//  ZIDLastVersion
//
//  Created by KimPan Jung on 2015. 5. 10..
//  Copyright (c) 2015년 KPJ. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController {
    
    var sceneView: SCNView{
        get{
            return self.view as! SCNView
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set up the SCNView
        sceneView.backgroundColor = UIColor.blackColor()
        sceneView.showsStatistics = true
        // antialiasing~!
        sceneView.antialiasingMode = SCNAntialiasingMode.Multisampling2X
        sceneView.overlaySKScene = SKScene(size: view.bounds.size)
        sceneView.playing = false
        
        // Set up the scene
        let scene = GameScene(view: sceneView)
        //scene.rootNode.hidden = true
        //scene.physicsWorld.contactDelegate = scene
        
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: -5, z: 0)
        scene.physicsWorld.timeStep = 1.0/360
        scene.physicsWorld.speed = 4.0;
        scene.background.contents = UIImage(named: "ih_shrine-skybox02.jpg")

        
        // Start playing the scene
        sceneView.scene = scene
        sceneView.delegate = scene
        sceneView.scene!.rootNode.hidden = false
        sceneView.play(self)
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
