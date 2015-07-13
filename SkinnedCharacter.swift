//
//  SkinnedCharacter.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/15/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SceneKit
import QuartzCore

class SkinnedCharacter : SCNNode {
    var health:Int = 100
    var mainSkeleton:SCNNode!
    var animationsDict = Dictionary<String, CAAnimation>()

    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    /*
    init(rootNode:SCNNode) {
        super.init()
        
        println("Root node name in scene:\(rootNode.name)")
        
        rootNode.enumerateChildNodesUsingBlock({
            child, stop in
            // do something with node or stop
            println("Child node name:\(child.name)")
            if let skeleton = child.skinner {
                self.mainSkeleton = child.skinner.skeleton
                println("Main skeleton name: \(self.mainSkeleton.name)")
                stop.memory = true
            }
        })
        self.addChildNode(rootNode)

    }
    */
    init(rootNode:SCNNode) {
        super.init()
        
        println("Root node name in scene:\(rootNode.name)")
        
        rootNode.enumerateChildNodesUsingBlock({
            child, stop in
            // do something with node or stop
            println("Child node name:\(child.name)")
            if let skeleton = child.skinner {
                self.mainSkeleton = child.skinner!.skeleton
                println("Main skeleton name: \(self.mainSkeleton.name)")
                stop.memory = true
                self.addChildNode(child.skinner!.skeleton)
            }
        })
        
        rootNode.enumerateChildNodesUsingBlock({
            child, stop in
            // do something with node or stop
            if let geometry = child.geometry {
                println("Child node with geometry name:\(child.name)")
                self.addChildNode(child)
            }
        })

        
    }

    
    func cachedAnimationForKey(key:String) -> CAAnimation! {
        return animationsDict[key]
    }
    
    class func loadAnimationNamed(animationName:String, fromSceneNamed sceneName:String, withSkeletonNode skeletonNode:String) -> CAAnimation!
    {
        var animation:CAAnimation!
        
        //Load the animation
        let scene = SCNScene(named: sceneName)
    
/*
        for child in scene.rootNode.childNodes {
            let node = child as SCNNode
            println("Child node name is \(node.name)")
        }
*/
        //Grab the node and its animation
        if let node = scene!.rootNode.childNodeWithName(skeletonNode, recursively: true) {
            animation = node.animationForKey(animationName)
            if(animation == nil) {
                println("No animation for key \(animationName)")
                return nil
            }
        } else {
            return nil
        }
    
        // Blend animations for smoother transitions
        animation.fadeInDuration = 0.3
        animation.fadeOutDuration = 0.3
    
        return animation;
    
    
    }
    
    func loadAndCacheAnimation(daeFile:String, withSkeletonNode skeletonNode:String, withName name:String, forKey key:String) -> CAAnimation
    {
    
        var anim = self.dynamicType.loadAnimationNamed(name, fromSceneNamed:daeFile, withSkeletonNode:skeletonNode)
    
        if ((anim) != nil) {
            self.animationsDict[key] = anim
            anim.delegate = self;
        }
        return anim;
    }
    
    func loadAndCacheAnimation(daeFile:String, withSkeletonNode skeletonNode:String, forKey key:String) -> CAAnimation
    {
        return loadAndCacheAnimation(daeFile, withSkeletonNode:skeletonNode, withName:key, forKey:key)
    }
    
    func chainAnimation(firstKey:String, secondKey:String)
    {
        chainAnimation(firstKey, secondKey: secondKey, fadeTime: 0.85)
    }
    
    func chainAnimation(firstKey:String, secondKey:String, fadeTime:CGFloat)
    {
        var firstAnim = self.cachedAnimationForKey(firstKey)
        var secondAnim = self.cachedAnimationForKey(secondKey)
        if (firstAnim == nil || secondAnim == nil) {
            return
        }
        
        //Need to fill in rest of logic
    }

    
}