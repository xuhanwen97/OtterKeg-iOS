//
//  OtterKegTabBarController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/20/22.
//

import UIKit

class OtterKegTabBarController: UITabBarController, UITabBarControllerDelegate {
        
    override func viewDidLoad() {
        self.delegate = self
        
        self.selectedIndex = 1

        self.tabBar.barTintColor = ColorConstants.otterKegBackground
        self.tabBar.tintColor = UIColor .white
        
        self.tabBar.items?[0].title = "Kegs"
        self.tabBar.items?[0].image = UIImage .strokedCheckmark
        
        self.tabBar.items?[1].title = "Pours"
        self.tabBar.items?[1].image = UIImage .strokedCheckmark
        
        self.tabBar.items?[2].title = "Drinkers"
        self.tabBar.items?[2].image = UIImage .strokedCheckmark
        
    }

}
