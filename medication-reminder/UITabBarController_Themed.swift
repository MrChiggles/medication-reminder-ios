//
//  UITabBarController_Themed.swift
//  medication-reminder
//
//  Created by Wesley Schrauwen on 2017/09/03.
//  Copyright © 2017 Vikas Gandhi. All rights reserved.
//

import UIKit

class UITabBarController_Themed: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let selectedColor = UIColor(red: 128/256, green: 0, blue: 64/256, alpha: 1)
        let unselectedColor = UIColor(red: 96/256, green: 96/256, blue: 96/256, alpha: 1)
        
        self.tabBar.items?[0].image = #imageLiteral(resourceName: "hourglass_tabbar").withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[0].selectedImage = #imageLiteral(resourceName: "hourglass_selected_tabbar").withRenderingMode(.alwaysOriginal)
        
        self.tabBar.items?[1].selectedImage = #imageLiteral(resourceName: "list_selected_tabbar").withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].image = #imageLiteral(resourceName: "list_tabbar").withRenderingMode(.alwaysOriginal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : selectedColor], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : unselectedColor], for: .normal)
        
    }

}
