//
//  AddOrEditFriendViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-11-02.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import StitchCore
import MaterialComponents.MaterialTextFields

class AddOrEditFriendViewController: SubmissionFormViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var friendToEdit: Friend?
    var usernameFromFriendRequests: String?
    
    let scrollView = UIScrollView()
    var usernameTextField: MDCTextField?
    var nicknameTextField: MDCTextField?
    var descriptionTextField: MDCMultilineTextField?
    var usernameController: MDCTextInputControllerOutlined?
    var nicknameController: MDCTextInputControllerOutlined?
    var descriptionController: MDCTextInputControllerOutlinedTextArea?
    var textColorButton = RoundButton.standardButton(title: "Text Color", wide: false)
    var pickGroupsButton = RoundButton.standardButton(title: "Pick Groups", wide: false)
    var selectedGroupsLabel = UILabel()
    var confirmButton: RoundButton?
    var cancelButton: RoundButton?
    
    let selectedGroupsSet = NSMutableSet()
    
    var textFieldControllers = [MDCTextInputControllerFloatingPlaceholder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        setupNavigationBar()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.barBlue
        let whiteTitleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = whiteTitleAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = whiteTitleAttributes
    }
    
    func setupView() {
        view.backgroundColor = UIColor.backgroundGray
        
        pickGroupsButton.addTarget(self, action: #selector(activateGroupsPicker(sender:)), for: .touchUpInside)
        textColorButton.addTarget(self, action: #selector(activateColorPicker(sender:)), for: .touchUpInside)
        
        let usernameTuple = BasicController.standardTextFieldController(placeholderText: "Friend Username*")
        usernameTextField = usernameTuple.textField
        usernameController = usernameTuple.controller
        usernameTextField?.delegate = self
        textFieldControllers.append(usernameController!)
        
        let nicknameTuple = BasicController.standardTextFieldController(placeholderText: "Nickname")
        nicknameTextField = nicknameTuple.textField
        nicknameController = nicknameTuple.controller
        nicknameController?.characterCountMax = 30
        nicknameTextField?.delegate = self
        textFieldControllers.append(nicknameController!)
        
        let descriptionTuple = BasicController.standardMultilineTextFieldController(placeholderText: "Friend Description")
        descriptionTextField = descriptionTuple.textField
        descriptionController = descriptionTuple.controller
        descriptionController?.characterCountMax = 140
        descriptionTextField?.textView?.delegate = self
        textFieldControllers.append(descriptionController!)
        descriptionTextField?.clearButton.addTarget(self, action: #selector(descriptionCleared(sender:)), for: .touchUpInside)
        
        selectedGroupsLabel.textColor = UIColor.white
        selectedGroupsLabel.numberOfLines = 0
        selectedGroupsLabel.lineBreakMode = .byWordWrapping
        selectedGroupsLabel.textAlignment = .center
        
        if let friendToEdit = friendToEdit {
            self.navigationItem.title = "Edit Friend"
            confirmButton = RoundButton.standardButton(title: "Edit Friend", wide: true)
            
            usernameTextField?.text = friendToEdit.ownerUsername
            usernameTextField?.isUserInteractionEnabled = false
            let grayedOut = UIColor.lightGray
            usernameTextField?.textColor = grayedOut
            usernameController?.normalColor = grayedOut
            usernameController?.floatingPlaceholderActiveColor = grayedOut
            usernameController?.floatingPlaceholderNormalColor = grayedOut
            
            nicknameTextField?.text = friendToEdit.alias
            descriptionTextField?.text = friendToEdit.description
            textColorButton.setTitleColor(BasicController.hexToUIColor(color: friendToEdit.textColor), for: .normal)
            
            selectedTextColor.add(friendToEdit.textColor)
            for groupId in friendToEdit.listOfGroupIds {
                selectedGroupsSet.add(groupId)
            }
            
        } else {
            self.navigationItem.title = "Add Friend"
            confirmButton = RoundButton.standardButton(title: "Add Friend", wide: true)
            
            // if from friend requests
            if let username = usernameFromFriendRequests {
                usernameTextField?.text = username
                usernameTextField?.isUserInteractionEnabled = false
                let grayedOut = UIColor.lightGray
                usernameTextField?.textColor = grayedOut
                usernameController?.normalColor = grayedOut
                usernameController?.floatingPlaceholderActiveColor = grayedOut
                usernameController?.floatingPlaceholderNormalColor = grayedOut
            }
        }
        
        confirmButton?.backgroundColor = UIColor.buttonColor
        confirmButton?.addTarget(self, action: #selector(confirmButtonPressed(selector:)), for: .touchUpInside)
        
        cancelButton = RoundButton.cancelButton()
        cancelButton?.addTarget(self, action: #selector(cancelButtonPressed(selector:)), for: .touchUpInside)
        
        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(usernameTextField!)
        scrollView.addSubview(nicknameTextField!)
        scrollView.addSubview(descriptionTextField!)
        scrollView.addSubview(textColorButton)
        scrollView.addSubview(pickGroupsButton)
        scrollView.addSubview(selectedGroupsLabel)
        
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

        usernameTextField?.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        usernameTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        usernameTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        usernameTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        nicknameTextField?.autoPinEdge(.top, to: .bottom, of: usernameTextField!, withOffset: 0)
        nicknameTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        nicknameTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        nicknameTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        descriptionTextField?.autoPinEdge(.top, to: .bottom, of: nicknameTextField!, withOffset: 12)
        descriptionTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        descriptionTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        descriptionTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        textColorButton.autoPinEdge(.top, to: .bottom, of: descriptionTextField!, withOffset: 8)
        textColorButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        pickGroupsButton.autoPinEdge(.top, to: .bottom, of: textColorButton,  withOffset: 24)
        pickGroupsButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        selectedGroupsLabel.autoPinEdge(.top, to: .bottom, of: pickGroupsButton, withOffset: 8)
        selectedGroupsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        selectedGroupsLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        selectedGroupsLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        self.view.bringSubview(toFront: activityIndicator)
    }
    
    @objc func confirmButtonPressed(selector: UIButton!) {
        guard let username = usernameTextField?.text else {
            return
        }
        guard let nickname = nicknameTextField?.text else {
            return
        }
        guard let description = descriptionTextField?.text else {
            return
        }
        
        if username.count == 0 {
            usernameController?.setErrorText("Too short", errorAccessibilityValue: nil)
            vibrate()
            return
        }
        
        if username.count > 30 || isStringValid(string: username) == false  || nickname.count > 30 || description.count > 140 {
            vibrate()
            return
        }
        
        let color = getSelectedColor()
        let listOfGroupIds = selectedGroupsSet.allObjects as! [String]
        
        addOrEditFriend(username: username, nickname: nickname, description: description, selectedColor: color, listOfGroupIds: listOfGroupIds)
    }
    
    func addOrEditFriend(username: String, nickname: String, description: String, selectedColor: String, listOfGroupIds: [String]) {
        if BasicController.isThereInternet() == false {
            errorAlert(message: "No internet connection")
            vibrate()
            return
        }
        
        self.activityIndicator.startAnimating()
        
        client.callFunction(withName: "addOrEditFriend", withArgs: [username, nickname, description, selectedColor, listOfGroupIds]) { (result: StitchResult<String>) in
            switch result {
            case .success(let result):
                if result == "Successful add" {
                    if self.usernameFromFriendRequests != nil {
                        self.accountController.tableViewRequiresReload = true
                    }
                    self.successAlertGetProfile(description: "Friend added")
                    
                } else if result == "Successful edit" {
                    self.accountController.tableViewRequiresReload = true
                    self.successAlertGetProfile(description: "Friend edited")
                    
                } else if result == "Invalid input" {
                    self.errorAlert(message: "Error code: AF-2")
                } else if result == "writeConcernError" {
                    self.errorAlert(message: "Error code: AF-3")
                } else if result == "writeError" {
                    self.errorAlert(message: "Error code: AF-4")
                } else if result == "User does not exist" {
                    self.errorAlert(message: "User does not exist")
                } else {
                    self.errorAlert(message: "Error code: AF-5")
                }
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: AF-1)")
            }
        } 
    }
    
    @objc func cancelButtonPressed(selector: UIButton!) {
        // do nothing and return
        self.navigationController?.popViewController(animated: true)
    }
    
    func redrawGroupsLabel() {
        let groupString = NSMutableAttributedString(string: "Groups:\n")
        
        var count = 0
        for group in (accountController.userProfile?.listOfFriendGroups)! {
            if selectedGroupsSet.contains(group.groupId) {
                if count > 0 {
                    groupString.append(NSAttributedString(string: ", "))
                }
                let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: BasicController.hexToUIColor(color: group.groupTextColor)]
                let attributedGroup = NSAttributedString(string: group.friendListName, attributes: attributes)
                groupString.append(attributedGroup)
                count += 1
            }
        }
        
        selectedGroupsLabel.attributedText = groupString
        textColorButton.setTitleColor(BasicController.hexToUIColor(color: getSelectedColor()), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redrawGroupsLabel()
    }
    
    @objc func descriptionCleared(sender: UIButton!) {
        descriptionController?.setErrorText(nil, errorAccessibilityValue: nil)
    }
    
    @objc func activateColorPicker(sender: UIButton!) {
        self.view.endEditing(true)
        
        let tupleArray = UIColor.colorPickerTupleArray
        let colorPickerController = ColoredSelectTableViewController(title: "Pick Text Color", tupleArray: tupleArray, isMultiSelect: false)
        colorPickerController.selectedStrings = self.selectedTextColor
        self.navigationController?.pushViewController(colorPickerController, animated: true)
    }
    
    @objc func activateGroupsPicker(sender: UIButton!) {
        self.view.endEditing(true)
        
        let listOfFriendGroups = accountController.userProfile?.listOfFriendGroups
        
        var tupleArray = [(String, String, String)]()
        for group in listOfFriendGroups! {
            tupleArray.append((group.friendListName, group.groupTextColor, group.groupId))
        }
        
        let groupPickerController = ColoredSelectTableViewController.init(title: "Pick Groups", tupleArray: tupleArray, isMultiSelect: true)
        groupPickerController.selectedStrings = self.selectedGroupsSet
        self.navigationController?.pushViewController(groupPickerController, animated: true)
    }
    
    // Mark: Textfield/view Functions
    
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
            if isStringValid(string: fullString) == false || fullString.count > 30 {
                usernameController?.setErrorText("Invalid Username", errorAccessibilityValue: nil)
            } else {
                usernameController?.setErrorText(nil, errorAccessibilityValue: nil)
            }
        }
        
        if textField == nicknameTextField {
            if fullString.count > 30 {
                nicknameController?.setErrorText("Too long", errorAccessibilityValue: nil)
            } else  {
                nicknameController?.setErrorText(nil, errorAccessibilityValue: nil)
            }
        }
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let rawText = textView.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: text)
        
        if textView == descriptionTextField?.textView {
            if fullString.count > 140 {
                descriptionController?.setErrorText("Too long", errorAccessibilityValue: nil)
            } else {
                descriptionController?.setErrorText(nil, errorAccessibilityValue: nil)
            }
        }
        
        return true
    }
    
    // required for proper clearing
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        _ = self.textField(textField, shouldChangeCharactersIn: NSRange.init(), replacementString: "")
        return false
    }
}
