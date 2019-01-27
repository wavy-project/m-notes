//
//  PasswordResetRequestViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit
import Parse

class PasswordResetRequestViewController: NavigationEmbeddedViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContentContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submitButtonTitleLabel: UILabel!
    @IBOutlet weak var loadingBackgroundView: UIView!
    @IBOutlet weak var loadingView: LoadingView!
    
    var emailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController!.navigationBar.frame.height
        self.scrollViewContentContainerViewHeightConstraint.constant = UIScreen.main.bounds.height - (statusBarHeight + navigationBarHeight + view.safeAreaInsets.bottom)
        self.emailContainerView.layer.cornerRadius = self.emailContainerView.frame.height / 2
        self.emailTextField.delegate = self
        self.emailTextField.keyboardAppearance = .light
        self.emailTextField.returnKeyType = .go
        if let email = self.emailAddress {
            self.emailTextField.text = email
        }
        self.submitButtonTitleLabel.attributedText = NSAttributedString(string: self.submitButtonTitleLabel.text!, attributes: [.kern : 1.8])
        self.loadingBackgroundView.isHidden = true
        self.loadingView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingBackgroundView.isHidden = true
        self.loadingView.isUserInteractionEnabled = false
    }
    
    @IBAction func onViewTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onSubmitButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        resetPassword()
    }
    
    func onGoKeyPressed() {
        self.onSubmitButtonTapped(self)
        self.view.endEditing(true)
    }
}

// MARK: - Parse

extension PasswordResetRequestViewController {
    fileprivate func resetPassword() {
        let emailAddress = self.emailTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        if emailAddress.count == 0 || !Utilities.isValidEmail(emailAddress) {
            let alertController = UIAlertController(title: "Please enter a valid email address.", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fix", style: .default, handler: { _ in
                self.emailTextField.becomeFirstResponder()
            }))
            self.present(alertController, animated: true)
            return
        }
        
        startLoadingViewAnimation()
        self.emailTextField.isEnabled = false
        self.emailContainerView.alpha = 0.5
        self.submitButton.isEnabled = false
        self.submitButtonTitleLabel.alpha = 0.5
        PFUser.requestPasswordResetForEmail(inBackground: emailAddress) { (success: Bool, error: Error?) in
            self.stopLoadingViewAnimation()
            if !success || error != nil {
                print("Parse: Error resetting password -", error!._code as Any, "-", error!.localizedDescription as Any)
                self.presentPasswordResetErrorAlert(withCode: error!._code)
            } else {
                self.presentPasswordResetSuccess()
            }
        }
    }
    
    fileprivate func presentPasswordResetErrorAlert(withCode errorCode: Int) {
        var ac: UIAlertController!
        switch errorCode {
        case 101:
            ac = UIAlertController(title: "Unable to Reset Password", message: "Invalid email.", preferredStyle: UIAlertControllerStyle.alert)
        case 205:
            ac = UIAlertController(title: "Unable to Reset Password", message: "Email not found.", preferredStyle: UIAlertControllerStyle.alert)
        default:
            ac = UIAlertController(title: "Unable to Reset Password", message: "Please check your Internet connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        }
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    fileprivate func presentPasswordResetSuccess() {
        let alertController = UIAlertController(title: "Check Your Email", message: "You will receive an email from Kilouett with instructions to reset your password. You may need to check your spam folder.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
}

// MARK: - Text Field Delegate

extension PasswordResetRequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .go:
            self.onGoKeyPressed()
        default:
            textField.nextTextField?.becomeFirstResponder()
        }
        return true
    }
}

// MARK: - Animation

extension PasswordResetRequestViewController {
    func startLoadingViewAnimation() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.loadingView.startAnimating()
        self.loadingView.isUserInteractionEnabled = true // Block any further touches
        self.loadingBackgroundView.alpha = 0
        self.loadingBackgroundView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
            self.loadingBackgroundView.alpha = 0.5
        }, completion: nil)
    }
    
    func stopLoadingViewAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
            self.loadingBackgroundView.alpha = 0
        }, completion: { _ in
            self.loadingBackgroundView.isHidden = true
        })
        self.loadingView.isUserInteractionEnabled = false
        self.loadingView.stopAnimating()
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
}
