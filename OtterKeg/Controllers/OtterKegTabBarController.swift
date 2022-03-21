//
//  OtterKegTabBarController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/20/22.
//

import UIKit

class OtterKegTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let otterKegBackground = UIColor(red: 0.13, green: 0.17, blue: 0.20, alpha: 1.00)
    
    override func viewDidLoad() {
        self.delegate = self
        
        self.tabBar.barTintColor = otterKegBackground
        self.tabBar.tintColor = UIColor .white
        self.tabBar.items?[0].title = "Pours"
        self.tabBar.items?[0].image = UIImage .strokedCheckmark

        self.tabBar.items?[1].title = "Kegs"
        self.tabBar.items?[1].image = UIImage .strokedCheckmark

    }

}
