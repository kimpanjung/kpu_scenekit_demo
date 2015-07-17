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
import GameKit
import iAd

// Insert ' Ad '
var adBannerView: ADBannerView!


class GameViewController: UIViewController, ADBannerViewDelegate, GKGameCenterControllerDelegate {
    
    var sceneView: SCNView{
        get{
            return self.view as! SCNView
        }
    }
    
    var leaderboardIdentifier: String = ""
    var gameCenterEnabled: Bool = false
    
    func loadAds() {
        adBannerView = ADBannerView(frame: CGRectZero)
        adBannerView.hidden = true
        adBannerView.delegate = self
        view.addSubview(adBannerView)
    }
    
    func authenticate() {
        
        var player = GKLocalPlayer.localPlayer()
        player.authenticateHandler = {(var gameCenterVC: UIViewController!, var gameCenterError: NSError!) -> Void in
            
            if ((gameCenterVC) != nil) {
                self.presentViewController(gameCenterVC, animated: true, completion: nil)
            } else {
                
                if player.authenticated
                {
                    player.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (var leaderboardIdentifier: String!, var error: NSError!) -> Void in
                        if((error) != nil) {
                            NSLog("\(error.localizedDescription)")
                        } else {
                            self.leaderboardIdentifier = leaderboardIdentifier
                        }
                    })
                } else {
                    
                    println("not able to authenticate fail")
                    self.gameCenterEnabled = false
                    
                    if (gameCenterError != nil) {
                        println("\(gameCenterError.description)")
                    }
                    else {
                        println( "error is nil")
                    }
                }
            }
        }
    }

    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
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
        scene.physicsWorld.contactDelegate = scene
        
        scene.physicsWorld.gravity = SCNVector3(x: 0, y:-9, z: 0) // default : -9 = 9.8mh
        scene.physicsWorld.timeStep = 1.0/360
        //scene.physicsWorld.speed = 5.0;
        //scene.background.contents = UIImage(named: "dark-soul-clouds.png")

        scene.background.contents = ["skybox_left.bmp", "skybox_right.bmp",
        "skybox_up.bmp", "skybox_bottom.bmp",
        "skybox_back.bmp", "skybox_front.bmp"];

        
        // Start playing the scene
        sceneView.scene = scene
        sceneView.delegate = scene
        sceneView.scene!.rootNode.hidden = false
        sceneView.play(self)
        
        loadAds()
        
        authenticate()
    }
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height/2)
        
        adBannerView.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: -100)
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
