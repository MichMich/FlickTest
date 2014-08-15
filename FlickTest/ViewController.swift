//
//  ViewController.swift
//  FlickTest
//
//  Created by Michael Teeuw on 27-06-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    
    let flickView = FlickView()
    let containerView = UIView() //UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    var heightConstraint:NSLayoutConstraint!
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    override func viewDidLoad()
    {
        
        
        super.viewDidLoad()
        
        
        let backgroundImageView = UIImageView(image: UIImage(named: "background.jpg"))
        backgroundImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(backgroundImageView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view":backgroundImageView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view":backgroundImageView]))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        view.addSubview(containerView)
        containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view":containerView]))
        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Top,    relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        heightConstraint = NSLayoutConstraint(item: containerView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0, constant: 500)
        view.addConstraint(heightConstraint)
        containerView.backgroundColor = UIColor.redColor()
        
        
        containerView.addSubview(flickView)
        flickView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view":flickView]))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(-200)-[view(265)]", options: nil, metrics: nil, views: ["view":flickView]))
        
        flickView.backgroundColor = UIColor.blueColor()
        flickView.allowMovement = .Vertical
        
        flickView.addSnapPoint(CGPoint(x: 0, y: -200))
        flickView.addSnapPoint(CGPoint(x: 0, y: 0))
        
        flickView.addObserver(self, forKeyPath: "center", options: NSKeyValueObservingOptions.New, context: nil)
       
    }
    
    func setContainerHeight(var height: CGFloat)
    {
        heightConstraint.constant = (height > 0) ? height : 0
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafePointer<()>)
    {
        if object.isKindOfClass(FlickView.self) {
            let flickView = object as FlickView
            
            setContainerHeight(flickView.frame.size.height + flickView.frame.origin.y)
        }
    }
    
}

