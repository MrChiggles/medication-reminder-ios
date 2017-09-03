//
//  UIBorderView.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/02.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import UIKit

class UIBorderView: UIView {
    
    public func setBorderColor(_ color: UIColor, width: CGFloat = 1){
        self.layer.borderColor = color.cgColor;
        self.layer.borderWidth = width
    }
    

}
