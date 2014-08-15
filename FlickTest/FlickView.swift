//
//  FlickView.swift
//  FlickTest
//
//  Created by Michael Teeuw on 28-06-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import UIKit

enum FlickViewAllowMovement {
    case Both
    case Horizontal
    case Vertical
}

class FlickView: UIView, UIDynamicAnimatorDelegate {
    
    
    var allowMovement = FlickViewAllowMovement.Vertical
    
    var animator = UIDynamicAnimator()
    var attachmentBehavior: UIAttachmentBehavior!
    
    var snapPoints = [CGPoint]()
    var snapPoint: CGPoint?
    
    
    
    var minMaxSnapPoints:(minX:CGFloat, minY:CGFloat, maxX:CGFloat, maxY:CGFloat)?
    {
        if snapPoints.count <= 0 {
            return nil
        }
        
        var snapPointMin = CGPoint(x: snapPoints[0].x, y: snapPoints[0].y)
        var snapPointMax = CGPoint(x: snapPoints[0].x, y: snapPoints[0].y)
        
        for snapPoint in snapPoints {
            if (snapPoint.x < snapPointMin.x) {
                snapPointMin.x = snapPoint.x
            }
            if (snapPoint.y < snapPointMin.y) {
                snapPointMin.y = snapPoint.y
            }
            if (snapPoint.x > snapPointMax.x) {
                snapPointMax.x = snapPoint.x
            }
            if (snapPoint.y > snapPointMax.y) {
                snapPointMax.y = snapPoint.y
            }
        }
        
        
        return (minX:snapPointMin.x, minY:snapPointMin.y, maxX:snapPointMax.x, maxY:snapPointMax.y)
    }
    
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }

    
    func setup()
    {
        if (snapPoints.count > 0) {
            snapPoint = snapPoints[0]
        }
        
        if let snapPoint = self.snapPoint {
            var currentFrame = self.frame
            currentFrame.origin = snapPoint
            self.frame = currentFrame
        }
        
        animator.delegate = self
        
        setupDefaultBehaviors()
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGesture:"))
    }
    
    
    func setupDefaultBehaviors()
    {
        if self.frame.size.width * self.frame.size.height == 0 {
            return
        }
        
        var dynamic = UIDynamicItemBehavior(items: [self])
        dynamic.allowsRotation = false
        animator.addBehavior(dynamic)
        
        
        
        if let sPoint = self.snapPoint {
            let realSnapPoint = CGPoint(x: sPoint.x + self.frame.size.width/2, y: sPoint.y + self.frame.size.height/2)
            let snapBehavior = UISnapBehavior(item: self, snapToPoint: realSnapPoint)
            snapBehavior.damping = 0.1
            
            animator.addBehavior(snapBehavior)
        }

    }
    

    

    
    
    func panGesture(gesture:UIPanGestureRecognizer)
    {
        var velocity = gesture.velocityInView(self.superview)
        var locationInView = gesture.locationInView(self.superview)
        var offset = UIOffset(horizontal:  gesture.locationInView(self).x - self.frame.width/2, vertical: gesture.locationInView(self).y - self.frame.height/2)

        
//      velocity.x = 0
//      locationInView.x = self.center.x
//      offset.horizontal = 0


        if self.allowMovement == FlickViewAllowMovement.Horizontal {
            velocity.y = 0
            locationInView.y = self.center.y
            offset.vertical = 0
        } else if self.allowMovement == FlickViewAllowMovement.Vertical {
            velocity.x = 0
            locationInView.x = self.center.x
            offset.horizontal = 0
        }
 
        
        switch gesture.state {
        case .Began:
            animator.removeAllBehaviors()
            
            attachmentBehavior = UIAttachmentBehavior(item: self, offsetFromCenter:offset, attachedToAnchor: locationInView)
            attachmentBehavior.length = 0
            attachmentBehavior.damping = 0
            attachmentBehavior.frequency = 0
            
            animator.addBehavior(attachmentBehavior)
            setupDefaultBehaviors()
            
        case .Changed:
            

            if let minMaxSnapPoints = self.minMaxSnapPoints {
                
                if  self.frame.origin.x < minMaxSnapPoints.minX ||
                    self.frame.origin.y < minMaxSnapPoints.minY ||
                    self.frame.origin.x > minMaxSnapPoints.maxX ||
                    self.frame.origin.y > minMaxSnapPoints.maxY {
                        
                        gesture.enabled = false
                        gesture.enabled = true
                        
                } else {
                    attachmentBehavior.anchorPoint = locationInView
                }
            }



        default:
            animator.removeAllBehaviors()
            
            self.snapPoint = closestSnapPointTo(self.frame.origin)
            
            var dynamic = UIDynamicItemBehavior(items: [self])
            dynamic.addLinearVelocity(velocity, forItem: self)
            dynamic.resistance = 10
            animator.addBehavior(dynamic)
            setupDefaultBehaviors()
            
        }
        gesture.setTranslation(CGPointZero, inView: self)
    }
    

    
    func closestSnapPointTo(point:CGPoint)-> CGPoint? {
        
        
        if snapPoints.count < 1 {
            return nil
        }
        
        func distanceBetween(pointA:CGPoint, andPoint pointB:CGPoint) -> Float {
            let dx = pointA.x - pointB.x
            let dy = pointA.y - pointB.y
            return sqrtf(Float(dx*dx+dy*dy))
        }
        
        var closestSnapPoint = snapPoints[0]
        
        if snapPoints.count > 1 {
            
            var distance = distanceBetween(point, andPoint: closestSnapPoint)
            
            for snapPoint in snapPoints {
                
                let thisDistance = distanceBetween(point, andPoint: snapPoint)
                
                if thisDistance < distance {
                    distance = thisDistance
                    closestSnapPoint = snapPoint
                }
            }
        }
        
        return closestSnapPoint
    }

    func addSnapPoint(point:CGPoint)
    {
        snapPoints.append(point)
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator!)
    {
        animator.removeAllBehaviors()
    }    
}
