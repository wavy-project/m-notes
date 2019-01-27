//
//  Utilities.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func openPrivacyPolicyURL() {
        UIApplication.shared.open(NSURL(string: "https://wavy-project.org")! as URL) // /pp
    }
    
    static func openTermsOfUseURL() {
        UIApplication.shared.open(NSURL(string: "https://wavy-project.org")! as URL) // /tou
    }
    
    static func presentErrorAlert(from viewController: UIViewController, withTitle title: String?, message: String?, completionOnOKSelected: (() -> ())? = nil, completionOnRetrySelected: (() -> ())? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completionOnOKSelected?()
        }))
        if let _ = completionOnRetrySelected {
            ac.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { _ in
                completionOnRetrySelected?()
            }))
        }
        viewController.present(ac, animated: true)
    }
}
