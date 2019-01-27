//
//  SignUpViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    var emailAddress: String?
    var password: String?
    var giftedPlanID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController!.navigationBar.frame.height
        self.scrollViewContentContainerViewHeightConstraint.constant = UIScreen.main.bounds.height - (statusBarHeight + navigationBarHeight + view.safeAreaInsets.bottom)
        self.fullNameTextField.delegate = self
        self.fullNameTextField.returnKeyType = .next
        self.emailTextField.text = self.emailAddress
        self.emailTextField.delegate = self
        self.emailTextField.returnKeyType = .next
        self.passwordTextField.text = self.password
        self.passwordTextField.delegate = self
        self.passwordTextField.returnKeyType = .next
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.emailAddress != nil {
            self.emailTextField.text = self.emailAddress
        }
        if self.password != nil {
            self.passwordTextField.text = self.password
        }
    }
    
    @IBAction func onViewTapped(_ sender: Any) {
        self.view.endEditing(true)
    }

    @IBAction func onTermsOfUseCheckboxButtonTapped(_ sender: Any) {
        self.termsOfUseCheckboxButton.isSelected = !self.termsOfUseCheckboxButton.isSelected
        self.view.endEditing(true)
    }
    
    @IBAction func onTermsOfUseLinkButtonTapped(_ sender: Any) {
        Utilities.openTermsOfUseURL()
    }
    
    @IBAction func onPrivacyPolicyLinkButtonTapped(_ sender: Any) {
        Utilities.openPrivacyPolicyURL()
    }
    
    @IBAction func onSignUpButtonTapped(_ sender: Any) {
        self.signUp()
        self.view.endEditing(true)
    }
    
    @IBAction func onLogInButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.presentLoginViewController(animated: true, email: self.emailTextField.text, password: self.passwordTextField.text)
    }

}

// MARK: - Parse

extension SignUpViewController {
    private func isValidFullName(_ fullName: String) -> Bool {
        let fullNameArray = fullName.components(separatedBy: " ")
        return fullNameArray.count >= 2
    }
    
    fileprivate func signUp() {
        let fullName = self.fullNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let emailAddress = self.emailTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        let password = self.passwordTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let selectedLocation = self.locationPickerView.selectedRow(inComponent: 0)
        let preferredLocation = (self.locationPickerView.view(forRow: selectedLocation, forComponent: 0) as! UILabel).text!.lowercased()
        
        if fullName.count == 0 || !isValidFullName(fullName) {
            let alertController = UIAlertController(title: "First and Last Name", message: "Please enter a valid first and last name.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fix", style: .default, handler: { _ in
                self.fullNameTextField.becomeFirstResponder()
            }))
            self.present(alertController, animated: true)
            return
        } else if emailAddress.count == 0 || !Utilities.isValidEmail(emailAddress) {
            let alertController = UIAlertController(title: "Email Address", message: "Please enter a valid email address.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fix", style: .default, handler: { _ in
                self.emailTextField.becomeFirstResponder()
            }))
            self.present(alertController, animated: true)
            return
        } else if password.count == 0 {
            let alertController = UIAlertController(title: "Password", message: "Please enter a valid password.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fix", style: .default, handler: { _ in
                self.passwordTextField.becomeFirstResponder()
            }))
            self.present(alertController, animated: true)
            return
        } else if !self.termsOfUseCheckboxButton.isSelected {
            let alertController = UIAlertController(title: "Terms of Use and Privacy Policy", message: "In order to register with Kilouett you must read and accept our Terms of Use and Privacy Policy.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true)
            return
        }
        
        func presentSignUpErrorAlert(forErrorCode errorCode: Int, withCompletionOnRetry completionOnRetry: (() -> ())? = nil) {
            var ac: UIAlertController!
            switch errorCode {
            case 202:
                ac = UIAlertController(title: "Account Already Exists", message: "Please use a different email address or try logging in instead.", preferredStyle: UIAlertControllerStyle.alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            default:
                ac = UIAlertController(title: "Unable to Sign Up", message: "Please check your Internet connection and try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                ac.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { _ in
                    completionOnRetry?()
                }))
            }
            present(ac, animated: true)
        }
        
        func signUpNewUser(withCompletionOnSuccess completionOnSuccess: (() -> ())? = nil) {
            let newUser = PFUser()
            newUser["fullName"] = fullName
            newUser.email = emailAddress
            newUser.username = emailAddress
            newUser.password = password
            newUser["preferredLocation"] = preferredLocation
            newUser["agreedToTermsOfService"] = self.termsOfUseCheckboxButton.isSelected
            newUser["agreedToTermsOfServiceAt"] = Date()
            newUser["receiveEmails"] = self.receiveEmailsCheckboxButton.isSelected
            startLoadingViewAnimation()
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                self.stopLoadingViewAnimation()
                if success {
                    print("Parse: Signup successful")
                    completionOnSuccess?()
                } else if let _ = error {
                    
                    // TODO: PING AMPLITUDE
                    
                    print("Parse: Error signing up -", error!._code, "-", error?.localizedDescription as Any)
                    presentSignUpErrorAlert(forErrorCode: error!._code) {
                        signUpNewUser(withCompletionOnSuccess: completionOnSuccess)
                    }
                } else {
                    
                    // TODO: PING AMPLITUDE
                    
                    print("Parse: Unknown error")
                    Utilities.presentErrorAlert(from: self, withTitle: "An Unknown Error Occurred", message: "Sorry. Support has been pinged.", completionOnRetrySelected: {
                        signUpNewUser(withCompletionOnSuccess: completionOnSuccess)
                    })
                }
            }
        }
        
        signUpNewUser() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let _ = self.giftedPlanID {
                self.redeemGiftedPlan() {
                    appDelegate.presentHomeTabBarController(animated: true)
                }
            } else {
                appDelegate.presentCoffeePreferenceSurveyViewController(animated: true)
            }
        }
}
