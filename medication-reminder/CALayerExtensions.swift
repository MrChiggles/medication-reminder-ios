//
//  CALayerExtensions.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/03.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import Foundation
import UIKit

extension CAShapeLayer {
    
    /**
     Sets up the existing layer as a circle
    */
    func createAnimatableCircleBorder(x: CGFloat, y: CGFloat, radius: CGFloat, strokeColor: UIColor, fillColor: UIColor, lineWidth: CGFloat, strokeEnd: CGFloat = 0) {
        
        //create the circle's path
        let circleCenter = CGPoint(x: x, y: y)
        let circle = UIBezierPath(arcCenter: circleCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        
        //put the circe into core graphics and add some flavour
        self.path = circle.cgPath
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor.cgColor
        self.fillColor = fillColor.cgColor
        
        //circle should start drawing at 0 and end at where ever is required
        self.strokeStart = 0
        self.strokeEnd = strokeEnd
        
    }
    
    func createAnimatableCircleBorder(center: CGPoint, radius: CGFloat, strokeColor: UIColor, fillColor: UIColor, lineWidth: CGFloat, strokeEnd: CGFloat = 0){
        createAnimatableCircleBorder(x: center.x, y: center.y, radius: radius, strokeColor: strokeColor, fillColor: fillColor, lineWidth: lineWidth, strokeEnd: strokeEnd)
    }
    
}
