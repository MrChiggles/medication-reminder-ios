//
//  UIViewExtensions.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/02.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     Creates and plays an animated ripple effect
     */
    func animateRipple(){
        
        let layer = CAShapeLayer()
        
        //get the layers properties
        let circleCenter = CGPoint(x: self.layer.frame.origin.x + self.layer.frame.width / 2,
                                   y: self.layer.frame.origin.y + self.layer.frame.height / 2)
        let radius = self.layer.frame.width / 2
        let strokeWidth: CGFloat = 4
        
        //create the layer as a circle and pass in params
        //layer is given stark default stroke and fill colors as
        //these must be overridden elsewhere
        layer.createAnimatableCircleBorder(center: circleCenter,
                                           radius: radius,
                                           strokeColor: UIColor.black,
                                           fillColor: UIColor.blue,
                                           lineWidth: strokeWidth,
                                           strokeEnd: 1)
        
        
        //####################
        //Animation Setup:
        //All these animations take place over 3 seconds and 
        //are flagged true for remove on completion.
        //####################
        
        //the opacity animation
        //fades the shape
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 3
        opacityAnimation.isRemovedOnCompletion = true
        
        //the bounds animation
        //makes the shape grow
        let newBounds = CGRect(x: self.layer.bounds.origin.x,
                              y: self.layer.bounds.origin.y,
                              width: self.layer.bounds.width * 3,
                              height: self.layer.bounds.height * 3)
        
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.fromValue = self.layer.frame
        boundsAnimation.toValue = newBounds
        boundsAnimation.duration = 3
        boundsAnimation.isRemovedOnCompletion = true
        
        //the corner radius animation
        //ensures the shape stays as a circle
        let cornerRadius = self.layer.cornerRadius * 3
        
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.fromValue = self.layer.cornerRadius
        cornerRadiusAnimation.toValue = cornerRadius
        cornerRadiusAnimation.duration = 3
        cornerRadiusAnimation.isRemovedOnCompletion = true
        
        //repeat animations forever
        opacityAnimation.repeatCount = Float.infinity
        boundsAnimation.repeatCount = Float.infinity
        cornerRadiusAnimation.repeatCount = Float.infinity
        
        //add all the animations to this layer
        self.layer.add(opacityAnimation, forKey: "alpha")
        self.layer.add(boundsAnimation, forKey: "bounds")
        self.layer.add(cornerRadiusAnimation, forKey: "cornerRadius")
        
        
        
    }
    
    /**
     Stops all animations on this UIView's layer
     */
    func stopAnimations(){
        
        self.layer.removeAllAnimations()
        
    }
    
    
    /**
     This should always be called somewhere where it is certain that the frame has been finalised.
     */
    public func makeCircular(){
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    
    /**
     Sets a shadow for this view
     Takes no params to ensure consistency over the app 
     */
    func setShadow(){
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        
    }
    
}
