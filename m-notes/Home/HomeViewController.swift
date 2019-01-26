//
//  HomeViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/20/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class HomeViewController: NavigationEmbeddedViewController {
    
    var appTabBarController: UITabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appTabBarController = UITabBarController()
        self.appTabBarController.tabBar.backgroundImage = UIImage()
        self.appTabBarController.tabBar.shadowImage = UIImage()
        self.appTabBarController.tabBar.backgroundColor = .black
        self.appTabBarController.tabBar.tintColor = .white
        self.appTabBarController.selectedIndex = 0
        self.addChild(self.appTabBarController)
        self.view.addSubview(self.appTabBarController.view)
        self.appTabBarController.didMove(toParent: self)
        // self.appTabBarController.viewControllers = [categoryListNC, categoryNC, settingsNC]
    }
    

    /*
     - All notes (front channel followed by back channel)
     - front channel
     - back channel
     - color (r o y g b i v p)
     - user-specified category
     */

}
