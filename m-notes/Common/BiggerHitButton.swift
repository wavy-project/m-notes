//
//  BiggerHitButton.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class BiggerHitButton: UIButton {
    
    let kMinimumButtonWidthHeight: CGFloat = 30
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let buttonSize = self.frame.size
        let widthToAdd = max(kMinimumButtonWidthHeight - buttonSize.width, 0)
        let heightToAdd = max(kMinimumButtonWidthHeight - buttonSize.height, 0)
        let largerFrame = CGRect(x: 0 - (widthToAdd), y: 0 - (heightToAdd / 2), width: buttonSize.width + widthToAdd * 2, height: buttonSize.height + heightToAdd)
        return largerFrame.contains(point) ? self : nil
    }
}
