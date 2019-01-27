//
//  CategoryTableViewCell.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/26/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit
import Parse

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryNameLabel: UILabel!
    
    var category: PFObject? {
        didSet {
            guard let _ = category else {
                return
            }
            self.categoryNameLabel.text = category?["name"] as? String
        }
    }
}
