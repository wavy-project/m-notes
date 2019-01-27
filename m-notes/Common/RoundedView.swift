//
//  RoundedView.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    // Ensures that left and right edges are not left partially or overly rounded if a change is made to the constant of a height constraint on the view.
    override func layoutSubviews() {
        self.awakeFromNib()
    }
}
