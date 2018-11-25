//
//  AddOrEditGroupViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-11-03.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import StitchCore
import MaterialComponents.MaterialTextFields

class AddOrEditGroupViewController: SubmissionFormViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var groupToEdit: FriendGroup?
    
    let scrollView = UIScrollView()
    var groupNameTextField: MDCTextField?
    var descriptionTextField: MDCMultilineTextField?
    var groupNameController: MDCTextInputControllerOutlined?
    var descriptionController: MDCTextInputControllerOutlinedTextArea?
    let notificationSwitch = UISwitch()
    let textColorButton = RoundButton.standardButton(title: "Text Color", wide: false)
    let pickFriendsButton = RoundButton.standardButton(title: "Pick Friends", wide: false)
    let selectedFriendsLabel = UILabel()
    var confirmButton: RoundButton?
    var cancelButton: RoundButton?

    let selectedFriendSet = NSMutableSet()
    
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
        
        pickFriendsButton.addTarget(self, action: #selector(activateFriendsPicker(sender:)), for: .touchUpInside)
        textColorButton.addTarget(self, action: #selector(activateColorPicker(sender:)), for: .touchUpInside)
        
        let groupNameTuple =  BasicController.standardTextFieldController(placeholderText: "Group Name*")
        groupNameTextField = groupNameTuple.textField
        groupNameController = groupNameTuple.controller
        groupNameController?.characterCountMax = 80
        groupNameTextField?.delegate = self
        textFieldControllers.append(groupNameController!)
        
        let descriptionTuple = BasicController.standardMultilineTextFieldController(placeholderText: "Group Description")
        descriptionTextField = descriptionTuple.textField
        descriptionController = descriptionTuple.controller
        descriptionController?.characterCountMax = 140
        descriptionTextField?.textView?.delegate = self
        descriptionTextField?.clearButton.addTarget(self, action: #selector(descriptionCleared(sender:)), for: .touchUpInside)
        textFieldControllers.append(descriptionController!)
        
        selectedFriendsLabel.textColor = UIColor.white
        selectedFriendsLabel.numberOfLines = 0
        selectedFriendsLabel.lineBreakMode = .byWordWrapping
        selectedFriendsLabel.textAlignment = .center
        
        if let groupToEdit = groupToEdit {
            self.navigationItem.title =  "Edit Group"
            
            confirmButton = RoundButton.standardButton(title: "Edit Group", wide: true)
            
            groupNameTextField?.text = groupToEdit.friendListName
            descriptionTextField?.text = groupToEdit.groupDescription
            
            if groupToEdit.notificationsOn == true {
                notificationSwitch.setOn(true, animated: true)
            }
            
            textColorButton.setTitleColor(BasicController.hexToUIColor(color: groupToEdit.groupTextColor), for: .normal)
            selectedTextColor.add(groupToEdit.groupTextColor)
            
            for friend in groupToEdit.friendArrayList  {
                selectedFriendSet.add(friend.ownerUsername!)
            }
            
        } else {
            self.navigationItem.title = "Add Group"
            confirmButton = RoundButton.standardButton(title: "Add Group", wide: true)
        }
        
        confirmButton?.backgroundColor = UIColor.buttonColor
        confirmButton?.addTarget(self, action: #selector(confirmButtonPressed(selector:)), for: .touchUpInside)
        
        cancelButton = RoundButton.cancelButton()
        cancelButton?.addTarget(self, action: #selector(cancelButtonPressed(selector:)), for: .touchUpInside)
        
        notificationSwitch.onTintColor = UIColor.barBlue
        let notificationsLabel = UILabel()
        notificationsLabel.textColor = UIColor.white
        notificationsLabel.text = "Notifications"
        let notificationStackView = UIStackView(arrangedSubviews: [notificationsLabel, notificationSwitch])
        notificationStackView.axis = .horizontal
        notificationStackView.alignment = .fill
        notificationStackView.spacing = 10
        
        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(groupNameTextField!)
        scrollView.addSubview(descriptionTextField!)
        scrollView.addSubview(notificationStackView)
        scrollView.addSubview(textColorButton)
        scrollView.addSubview(pickFriendsButton)
        scrollView.addSubview(selectedFriendsLabel)
        
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

        groupNameTextField?.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        groupNameTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        groupNameTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        groupNameTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        descriptionTextField?.autoPinEdge(.top, to: .bottom, of: groupNameTextField!, withOffset: 12)
        descriptionTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        descriptionTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        descriptionTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        notificationStackView.autoPinEdge(.top, to: .bottom, of: descriptionTextField!, withOffset: 8)
        notificationStackView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        textColorButton.autoPinEdge(.top, to: .bottom, of: notificationSwitch, withOffset: 24)
        textColorButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        pickFriendsButton.autoPinEdge(.top, to: .bottom, of: textColorButton, withOffset: 24)
        pickFriendsButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        selectedFriendsLabel.autoPinEdge(.top, to: .bottom, of: pickFriendsButton, withOffset: 8)
        selectedFriendsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        selectedFriendsLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        selectedFriendsLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        self.view.bringSubview(toFront: activityIndicator)
    }
    
    @objc func confirmButtonPressed(selector: UIButton!) {
        guard let groupName = groupNameTextField?.text else {
            return
        }
        guard let groupDescription = descriptionTextField?.text else {
            return
        }
        
        if groupName.count > 80 || groupDescription.count > 140 {
            vibrate()
            return
        }
        if groupName.count == 0 {
            groupNameController?.setErrorText("Too short", errorAccessibilityValue: nil)
            vibrate()
            return
        }
        
        let color = getSelectedColor()
        let listOfFriends = selectedFriendSet.allObjects as! [String]
        
        // if group is being edited, it already has an id, otherwise default to "" to tell the server to create a new group
        let groupId = groupToEdit?.groupId ?? ""
        
        addOrEditGroup(groupId: groupId, groupName: groupName, groupDescription: groupDescription, notificationsOn: notificationSwitch.isOn, selectedColor: color, listOfFriends: listOfFriends)
    }
    
    func addOrEditGroup(groupId: String, groupName: String, groupDescription: String, notificationsOn: Bool, selectedColor: String, listOfFriends: [String])  {
        if BasicController.isThereInternet() == false {
            errorAlert(message: "No internet connection")
            vibrate()
            return
        }
        
        self.activityIndicator.startAnimating()
        
        client.callFunction(withName: "addOrEditGroup", withArgs: [groupId, groupName, groupDescription, notificationsOn, selectedColor, listOfFriends]) { (result: StitchResult<String>) in
            switch result {
            case .success(let result):
                if result == "Successful add" {
                    self.successAlertGetProfile(description: "Group added")
                    
                } else if result == "Successful edit" {
                    self.accountController.tableViewRequiresReload = true
                    self.successAlertGetProfile(description: "Group edited")
                    
                } else if result == "Invalid input" {
                    self.errorAlert(message: "Error code: AG-2")
                } else if result == "writeConcernError" {
                    self.errorAlert(message: "Error code: AG-3")
                } else if result == "writeError" {
                    self.errorAlert(message: "Error code: AG-4")
                } else {
                    self.errorAlert(message: "Error code: AG-5")
                }
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: AG-1")
            }
        }
    }
    
    @objc func cancelButtonPressed(selector: UIButton!) {
        // do nothing and return
        self.navigationController?.popViewController(animated: true)
    }
    
    func redrawFriendsLabel() {
        let friendString = NSMutableAttributedString(string: "Friends:\n")
        
        var count = 0
        for friend in (accountController.userProfile?.completeFriendList.friendArrayList)! {
            if selectedFriendSet.contains(friend.ownerUsername!) {
                if count > 0 {
                    friendString.append(NSAttributedString(string: ", "))
                }
                let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: BasicController.hexToUIColor(color: friend.textColor)]
                let attributedFriend = NSAttributedString(string: friend.alias!, attributes: attributes)
                friendString.append(attributedFriend)
                count += 1
            }
        }
        selectedFriendsLabel.attributedText = friendString
        
        if selectedTextColor.count > 0 {
            let colorArray = selectedTextColor.allObjects
            let color = colorArray.first as! String
            textColorButton.setTitleColor(BasicController.hexToUIColor(color: color), for: .normal)
        } else {
            textColorButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redrawFriendsLabel()
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
    
    @objc func activateFriendsPicker(sender: UIButton!) {
        self.view.endEditing(true)
        
        let listOfFriends = accountController.userProfile?.completeFriendList.friendArrayList
        var tupleArray = [(String,  String, String)]()
        for friend in listOfFriends! {
            tupleArray.append((friend.alias!, friend.textColor, friend.ownerUsername!))
        }
        
        let friendPickerController = ColoredSelectTableViewController(title: "Pick Friends", tupleArray: tupleArray, isMultiSelect: true)
        friendPickerController.selectedStrings = self.selectedFriendSet
        self.navigationController?.pushViewController(friendPickerController, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Mark: Textfield/view Functions
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        
        if textField == groupNameTextField {
            if  fullString.count > 80 {
                groupNameController?.setErrorText("Too long", errorAccessibilityValue: nil)
            } else {
                groupNameController?.setErrorText(nil, errorAccessibilityValue: nil)
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
    
    // required
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        _ = self.textField(textField, shouldChangeCharactersIn: NSRange.init(), replacementString: "")
        return false
    }
}
