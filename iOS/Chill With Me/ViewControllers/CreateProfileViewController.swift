//
//  CreateProfileViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-11-05.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import GoogleSignIn
import StitchCore
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialActivityIndicator

class CreateProfileViewController: SubmissionFormViewController, UITextFieldDelegate {
    
    let scrollView = UIScrollView()
    let welcomeLabel = UILabel()
    let promptLabel = UILabel()
    var usernameTextField: MDCTextField?
    var usernameController: MDCTextInputControllerOutlined?
    var termsTextView = UITextView()
    var confirmButton: RoundButton?
    var cancelButton: RoundButton?
    
    var textFieldControllers = [MDCTextInputControllerFloatingPlaceholder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Create Profile"
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = UIColor.backgroundGray

        welcomeLabel.text = "Welcome"
        welcomeLabel.textColor = UIColor.white
        welcomeLabel.font = welcomeLabel.font.withSize(48)
        
        promptLabel.text = "Please select a username"
        promptLabel.textColor = UIColor.white
        promptLabel.font = promptLabel.font.withSize(24)
        
        let usernameTuple = BasicController.standardTextFieldController(placeholderText: "Username")
        usernameTextField = usernameTuple.textField
        usernameController = usernameTuple.controller
        usernameTextField?.delegate = self
        usernameController?.characterCountMax = 30
        textFieldControllers.append(usernameController!)
        
        let termsString = NSMutableAttributedString(string: "By using Chill With Me, you agree to its terms of service")
        let url = URL(string: "https://www.icheart.ca/chillwithme/legal")
        termsString.setAttributes([.link: url!], range: NSMakeRange(41, 16))
        termsTextView.attributedText = termsString
        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        termsTextView.isUserInteractionEnabled = true
        termsTextView.isEditable = false
        termsTextView.backgroundColor = UIColor.clear
        termsTextView.textColor = BasicController.hexToUIColor(color: "#aeaeae")
        termsTextView.center =  self.view.center
        termsTextView.font = UIFont.systemFont(ofSize: 14)
        termsTextView.isHidden = false
        termsTextView.textAlignment = .center
        
        let termsTextViewBackgroundHack = UILabel()
        termsTextViewBackgroundHack.attributedText = NSAttributedString(string: "\n\n\n\n")
        termsTextViewBackgroundHack.font = termsTextViewBackgroundHack.font.withSize(16)
        termsTextViewBackgroundHack.numberOfLines = 4
        termsTextViewBackgroundHack.lineBreakMode = .byWordWrapping
        termsTextViewBackgroundHack.textColor = UIColor.clear
        
        confirmButton = RoundButton.standardButton(title: "Confirm", wide: true)
        confirmButton?.backgroundColor = UIColor.buttonColor
        confirmButton?.addTarget(self, action: #selector(confirmPressed(sender:)), for: .touchUpInside)
        
        cancelButton = RoundButton.cancelButton()
        cancelButton?.addTarget(self, action: #selector(cancelPressed(sender:)), for: .touchUpInside)
        
        scrollView.addSubview(welcomeLabel)
        scrollView.addSubview(promptLabel)
        scrollView.addSubview(usernameTextField!)
        scrollView.addSubview(termsTextView)
        scrollView.addSubview(termsTextViewBackgroundHack)
        scrollView.alwaysBounceVertical = true
        
        self.view.addSubview(scrollView)
        self.view.addSubview(confirmButton!)
        self.view.addSubview(cancelButton!)
        
        scrollView.autoPinEdge(toSuperviewEdge: .top)
        scrollView.autoPinEdge(toSuperviewEdge: .left)
        scrollView.autoPinEdge(toSuperviewEdge: .right)
        scrollView.autoPinEdge(.bottom, to: .top, of: confirmButton!, withOffset: -16)
        
        confirmButton?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        cancelButton?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        
        // if iphone X
        if BasicController.hasTopNotch() == true {
            confirmButton?.autoPinEdge(toSuperviewSafeArea: .bottom)
            cancelButton?.autoPinEdge(toSuperviewSafeArea: .bottom)
        } else {
            confirmButton?.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            cancelButton?.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        }
        
        welcomeLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        welcomeLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        promptLabel.autoPinEdge(.top, to: .bottom, of: welcomeLabel, withOffset: 8)
        promptLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        usernameTextField?.autoPinEdge(.top, to: .bottom, of: promptLabel, withOffset: 16)
        usernameTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        usernameTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        usernameTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        termsTextViewBackgroundHack.autoPinEdge(.top, to: .bottom, of: usernameTextField!, withOffset: 20)
        termsTextViewBackgroundHack.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        termsTextViewBackgroundHack.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        termsTextViewBackgroundHack.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        termsTextView.autoPinEdge(.top, to: .bottom, of: usernameTextField!, withOffset: 16)
        termsTextView.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        termsTextView.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        termsTextView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        self.view.bringSubview(toFront: activityIndicator)
    }
    
    @objc func confirmPressed(sender: UIButton!) {
        guard let username = usernameTextField?.text else {
            return
        }
        
        let length = username.count
        if length == 0 {
            usernameController?.setErrorText("Too short", errorAccessibilityValue: nil)
            vibrate()
            return
        }
        
        let isUsernameValid = isStringValid(string: username)
        if length > 30 || isUsernameValid == false {
            vibrate()
            return
        }
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want your username to be \(username) for the rest of time?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.createProfile(username: username)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alert) in
        }))
        self.present(alert, animated: true)
    }
    
    @objc func cancelPressed(sender: UIButton!) {
        // Sign out
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
 
        self.navigationController?.popViewController(animated: true)
    }
    
    func createProfile(username: String) {
        self.activityIndicator.startAnimating()
        
        client.callFunction(withName: "createProfile", withArgs: [username]) { (result: StitchResult<String>) in
            switch result {
            case .success(let result):
                if result == "success" {
                    self.successAlertGetProfile(description: "Your profile has been created")
                } else if result == "Profile already exists" {
                    self.errorAlert(message: "Error code: C-1")
                } else if result == "Invalid username" {
                    self.errorAlert(message: "Error code: C-2")
                } else if result == "Username already taken" {
                    self.errorAlert(message: "Username already taken")
                } else {
                    self.errorAlert(message: "Error code: C-4")
                }
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: C-3")
            }
        }
    }
    
    // Mark: Textfield Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        
        if textField == usernameTextField {
            if fullString.count > 30 {
                usernameController?.setErrorText("Too long", errorAccessibilityValue: nil)
            } else if fullString.count  == 0 {
                usernameController?.setErrorText("Too short", errorAccessibilityValue: nil)
            } else if isStringValid(string: fullString) == false {
                usernameController?.setErrorText("Letters and numbers only", errorAccessibilityValue: nil)
            } else {
                usernameController?.setErrorText(nil, errorAccessibilityValue: nil)
            }
        }
        
        return true
    }
}
