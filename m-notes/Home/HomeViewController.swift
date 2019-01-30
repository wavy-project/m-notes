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
        self.appTabBarController.viewControllers = [categoryListNavigationController(), categoryNavigationController() /* ,  settingsNavigationController() */]
    }
    
    fileprivate func categoryListNavigationController() -> UINavigationController {
        let findStoryboard = UIStoryboard(name: "CategoryList", bundle: nil)
        let findNC = findStoryboard.instantiateViewController(withIdentifier: "CategoryListNC") as! UINavigationController
        findNC.tabBarItem = UITabBarItem(title: "CATEGORY LIST", image: UIImage(named: "menu-icon"), selectedImage: nil)
        findNC.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 9)!
            ] as [NSAttributedString.Key : Any], for: .normal)
        return findNC
    }
    
    fileprivate func categoryNavigationController() -> UINavigationController {
        let findStoryboard = UIStoryboard(name: "Category", bundle: nil)
        let findNC = findStoryboard.instantiateViewController(withIdentifier: "CategoryNC") as! UINavigationController
        findNC.tabBarItem = UITabBarItem(title: "CATEGORY", image: UIImage(named: "category-icon"), selectedImage: nil)
        findNC.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 9)!
            ] as [NSAttributedString.Key : Any], for: .normal)
        return findNC
    }
}
