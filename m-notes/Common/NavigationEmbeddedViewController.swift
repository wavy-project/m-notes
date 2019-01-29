//
//  NavigationEmbeddedViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 6/8/18.
//  Copyright © 2018 wavy-project. All rights reserved.
//

import UIKit

class NavigationEmbeddedViewController: UIViewController {
    
    var navigationBarTintColor: UIColor = .black
    var navigationBarIsHidden = false
    var navigationBarBarTintColor: UIColor?
    var navigationBarFont: UIFont = UIFont(name: "Inconsolata LGC", size: 15)!
    
    override func viewDidLoad() {
        setupNavigationController()
        // setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavigationController()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    func setupNavigationController() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        if let barTintColor = self.navigationBarBarTintColor {
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.barTintColor = barTintColor
        } else {
            self.navigationController?.navigationBar.isTranslucent = true
        }
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        self.navigationController?.navigationBar.isHidden = self.navigationBarIsHidden
        self.navigationController?.navigationBar.tintColor = self.navigationBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: self.navigationBarTintColor,
            NSAttributedString.Key.font: self.navigationBarFont]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
