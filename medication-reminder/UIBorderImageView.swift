//
//  UIBorderImageView.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/01.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import UIKit

class UIBorderImageView: UIImageView {
    
    public func setBorderColor(_ color: UIColor, width: CGFloat = 1){
        self.layer.borderColor = color.cgColor;
        self.layer.borderWidth = width
    }

}
