//
//  CategoryViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/20/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class CategoryViewController: NavigationEmbeddedViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // TODO: Ability to edit
    }
}

extension NavigationEmbeddedViewController: UICollectionViewDelegate {
    
}

extension NavigationEmbeddedViewController: UICollectionViewDataSource {
    
}
