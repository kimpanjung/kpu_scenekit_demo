//
//  FireGestureRecognizer.swift
//  FPSControls
//
//  Created by Nick Lockwood on 09/11/2014.
//  Copyright (c) 2014 Nick Lockwood. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class FireGestureRecognizer: UIGestureRecognizer {
    
    var timeThreshold = 0.15
    var distanceThreshold = 5.0
    private var startTimes = NSMutableDictionary()
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        //let touch = (touches.first as! UITouch).timestamp
        
        //record the start times of each touch
        for touch in touches {
            startTimes[touch.hash] = (touches.first as! UITouch).timestamp
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        //discard any touches that have moved
        for touch in touches {
            let touch = touches.first as? UITouch
            
            let newPos = touch!.locationInView(view)
            let oldPos = touch!.previousLocationInView(view)
            let distanceDelta = Double(max(abs(newPos.x - oldPos.x), abs(newPos.y - oldPos.y)))
            if (distanceDelta >= distanceThreshold) {
                startTimes.removeObjectForKey(touch!.hash)
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in touches {
            
            let startTime = startTimes[touch.hash] as! NSTimeInterval?
            if let startTime = startTime {
                
                //check if within time
                let timeDelta = (touches.first as! UITouch).timestamp - startTime
                if timeDelta < timeThreshold {
                    
                    //recognized
                    state = .Ended
                }
            }
        }
        reset()
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        reset()
    }
    
    override func reset() {
        
        if state == .Possible {
            state = .Failed
        }
    }
}
