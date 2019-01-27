//
//  Utilities.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    static func openPrivacyPolicyURL() {
        UIApplication.shared.open(NSURL(string: "https://wavy-project.org")! as URL) // /pp
    }
    
    static func openTermsOfUseURL() {
        UIApplication.shared.open(NSURL(string: "https://wavy-project.org")! as URL) // /tou
    }
}
