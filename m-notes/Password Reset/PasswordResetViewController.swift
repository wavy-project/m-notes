//
//  PasswordResetViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit

class PasswordResetViewController: NavigationEmbeddedViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContentContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordContainerView: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submitButtonTitleLabel: UILabel!
    @IBOutlet weak var loadingBackgroundView: UIView!
    @IBOutlet weak var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController!.navigationBar.frame.height
        self.scrollViewContentContainerViewHeightConstraint.constant = UIScreen.main.bounds.height - (statusBarHeight + navigationBarHeight + view.safeAreaInsets.bottom)
        self.passwordContainerView.layer.cornerRadius = self.passwordContainerView.frame.height / 2
        self.passwordTextField.delegate = self
        self.passwordTextField.keyboardAppearance = .light
        self.passwordTextField.returnKeyType = .next
        self.passwordTextField.nextTextField = self.confirmPasswordTextField
        self.confirmPasswordContainerView.layer.cornerRadius = self.confirmPasswordContainerView.frame.height / 2
        self.confirmPasswordTextField.delegate = self
        self.confirmPasswordTextField.keyboardAppearance = .light
        self.confirmPasswordTextField.returnKeyType = .go
        self.submitButtonTitleLabel.attributedText = NSAttributedString(string: self.submitButtonTitleLabel.text!, attributes: [.kern : 1.8])
        self.loadingBackgroundView.isHidden = true
        self.loadingView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingBackgroundView.isHidden = true
        self.loadingView.isUserInteractionEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onViewTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onSubmitButtonTapped(_ sender: Any) {
        
        // TODO: SAVE NEW PASSWORD TO USER OBJECT
        
        // TODO: PRESENT LOGIN VC WITH SLIDE/POP
    }
    
    func onGoKeyPressed() {
        self.onSubmitButtonTapped(self)
        self.view.endEditing(true)
    }
}

// MARK: - Text Field Delegate

extension PasswordResetViewController: UITextFieldDelegate {
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

extension PasswordResetViewController {
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

