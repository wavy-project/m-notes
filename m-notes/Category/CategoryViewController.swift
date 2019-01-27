//
//  CategoryViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/20/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit
import Parse

class CategoryViewController: NavigationEmbeddedViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var category: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // TODO: Edit button
        
        // TODO: START HERE: Fetch notes
    }
}

extension NavigationEmbeddedViewController: UICollectionViewDelegate {
    
}

extension NavigationEmbeddedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}
