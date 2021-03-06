//
//  SignUpViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: NavigationEmbeddedViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var termsOfUseAndPrivacyPolicyCheckboxButton: RoundedButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: BiggerHitButton!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var loadingBackgroundView: UIView!
    
    var emailAddress: String?
    var password: String?
    var giftedPlanID: String?
    
    override func viewDidLoad() {
        super.navigationBarIsHidden = true
        super.viewDidLoad()

        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController!.navigationBar.frame.height
        self.scrollViewContentContainerViewHeightConstraint.constant = UIScreen.main.bounds.height - (statusBarHeight + navigationBarHeight + view.safeAreaInsets.bottom)
        self.fullNameTextField.attributedPlaceholder = NSAttributedString(string: "full name", attributes: [NSAttributedString.Key.foregroundColor : Constants.gray])
        self.fullNameTextField.delegate = self
        self.fullNameTextField.returnKeyType = .next
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor : Constants.gray])
        self.emailTextField.text = self.emailAddress
        self.emailTextField.delegate = self
        self.emailTextField.returnKeyType = .next
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor : Constants.gray])
        self.passwordTextField.text = self.password
        self.passwordTextField.delegate = self
        self.passwordTextField.returnKeyType = .next
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        self.termsOfUseAndPrivacyPolicyCheckboxButton.isSelected = !self.termsOfUseAndPrivacyPolicyCheckboxButton.isSelected
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
}

// MARK: - Notification Listeners

extension SignUpViewController {
    @objc fileprivate func keyboardDidShow(notification: NSNotification) {
        if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height {
            self.scrollViewBottomConstraint.constant = height - view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        if self.scrollViewBottomConstraint.constant != 0 {
            UIView.animate(withDuration: 0.2) {
                self.scrollViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Text Field Delegate

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.nextTextField {
            nextTextField.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
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
        } else if !self.termsOfUseAndPrivacyPolicyCheckboxButton.isSelected {
            let alertController = UIAlertController(title: "Terms of Use and Privacy Policy", message: "In order to register with Kilouett you must read and accept our Terms of Use and Privacy Policy.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true)
            return
        }
        
        func presentSignUpErrorAlert(forErrorCode errorCode: Int, withCompletionOnRetry completionOnRetry: (() -> ())? = nil) {
            var ac: UIAlertController!
            switch errorCode {
            case 202:
                ac = UIAlertController(title: "Account Already Exists", message: "Please use a different email address or try logging in instead.", preferredStyle: UIAlertController.Style.alert)
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
            newUser["agreedToTermsOfService"] = self.termsOfUseAndPrivacyPolicyCheckboxButton.isSelected
            newUser["agreedToTermsOfServiceAt"] = Date()
            startLoadingViewAnimation()
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                self.stopLoadingViewAnimation()
                if success {
                    print("Parse: Signup successful")
                    completionOnSuccess?()
                } else if let _ = error {
                    print("Parse: Error signing up -", error!._code, "-", error?.localizedDescription as Any)
                    presentSignUpErrorAlert(forErrorCode: error!._code) {
                        signUpNewUser(withCompletionOnSuccess: completionOnSuccess)
                    }
                } else {
                    print("Parse: Unknown error")
                    Utilities.presentErrorAlert(from: self, withTitle: "An Unknown Error Occurred", message: "Sorry. Support has been pinged.", completionOnRetrySelected: {
                        signUpNewUser(withCompletionOnSuccess: completionOnSuccess)
                    })
                }
            }
        }
        
        signUpNewUser() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.presentHomeViewController(animated: true)
        }
    }
}

// MARK: - Animation

extension SignUpViewController {
    fileprivate func startLoadingViewAnimation() {
        self.loadingView.startAnimating()
        self.loadingView.isUserInteractionEnabled = true // Block any further touches
        self.loadingBackgroundView.alpha = 0
        self.loadingBackgroundView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
            self.loadingBackgroundView.alpha = 0.5
        }, completion: nil)
    }
    
    fileprivate func stopLoadingViewAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
            self.loadingBackgroundView.alpha = 0
        }, completion: { _ in
            self.loadingBackgroundView.isHidden = true
        })
        self.loadingView.isUserInteractionEnabled = false
        self.loadingView.stopAnimating()
    }
}
