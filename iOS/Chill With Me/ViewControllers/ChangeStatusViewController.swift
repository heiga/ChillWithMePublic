//
//  ChangeStatusViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-16.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import StitchCore
import SwiftyPickerPopover
import MaterialComponents.MaterialTextFields

class ChangeStatusViewController: SubmissionFormViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let scrollView = UIScrollView()
    var descriptionTextField: MDCMultilineTextField?
    var descriptionController: MDCTextInputControllerOutlinedTextArea?
    var durationTextField: MDCTextField?
    var durationController: MDCTextInputControllerOutlined?
    var pickGroupsButton = RoundButton.standardButton(title: "Pick Groups", wide: false)
    var selectedGroupsLabel = UILabel()
    let confirmButton = RoundButton.standardButton(title: "Update Status", wide: true)
    
    var currentStatusPickerState = "R2C"
    var hours: Int?
    var minutes: Int?
    let selectedGroupsSet = NSMutableSet()
    
    var textFieldControllers = [MDCTextInputControllerFloatingPlaceholder]()
    
    let R2CAttributedString: NSMutableAttributedString = {
        let attributedString = NSMutableAttributedString()
        
        let attachedImage = NSTextAttachment()
        attachedImage.image = #imageLiteral(resourceName: "R2CIcon")
        let imageString = NSAttributedString(attachment: attachedImage)
        attributedString.append(imageString)
        
        let whiteTitleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 26)]
        let textString = NSAttributedString(string: " Ready 2 Chill", attributes: whiteTitleAttributes)
        attributedString.append(textString)
        
        return attributedString
    }()
    
    let BusyAttributedString: NSMutableAttributedString = {
        let attributedString = NSMutableAttributedString()
        
        let attachedImage = NSTextAttachment()
        attachedImage.image = #imageLiteral(resourceName: "BusyIcon")
        let imageString = NSAttributedString(attachment: attachedImage)
        attributedString.append(imageString)
        
        let whiteTitleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 26)]
        let textString = NSAttributedString(string: " Do Not Disturb", attributes: whiteTitleAttributes)
        attributedString.append(textString)
        
        return attributedString
    }()
    
    let NAAttributedString: NSMutableAttributedString = {
        let attributedString = NSMutableAttributedString()
        
        let attachedImage = NSTextAttachment()
        attachedImage.image = #imageLiteral(resourceName: "NAIcon")
        let imageString = NSAttributedString(attachment: attachedImage)
        attributedString.append(imageString)
        
        let whiteTitleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 26)]
        let textString = NSAttributedString(string: " Not Available", attributes: whiteTitleAttributes)
        attributedString.append(textString)
        
        return attributedString
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Change Your Status"
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        setupView()
    }

    func setupView() {
        view.backgroundColor = UIColor.backgroundGray
    
        let statusButton = RoundButton.standardButton(title: "", wide: false)
        statusButton.setAttributedTitle(R2CAttributedString, for: .normal)
        statusButton.addTarget(self, action: #selector(activateStatusPicker(sender:)), for: .touchUpInside)
        
        pickGroupsButton.addTarget(self, action: #selector(activateGroupsPicker(sender:)), for: .touchUpInside)
    
        let descriptionTuple = BasicController.standardMultilineTextFieldController(placeholderText: "Status Description")
        descriptionTextField = descriptionTuple.textField
        descriptionController = descriptionTuple.controller
        descriptionController?.characterCountMax = 140
        descriptionTextField?.textView?.delegate = self
        descriptionTextField?.clearButton.addTarget(self, action: #selector(descriptionCleared(sender:)), for: .touchUpInside)
        textFieldControllers.append(descriptionController!)
        
        let durationTuple = BasicController.standardTextFieldController(placeholderText: "Duration")
        durationTextField = durationTuple.textField
        durationController = durationTuple.controller
        durationTextField?.inputView = UIView()
        durationTextField?.clearButtonMode = .never
        durationTextField?.delegate = self
        textFieldControllers.append(durationController!)
        
        selectedGroupsLabel.textColor = UIColor.white
        selectedGroupsLabel.numberOfLines = 0
        selectedGroupsLabel.lineBreakMode = .byWordWrapping
        selectedGroupsLabel.textAlignment = .center
        
        confirmButton.backgroundColor = UIColor.buttonColor
        confirmButton.addTarget(self, action: #selector(confirmPressed(sender:)), for: .touchUpInside)

        let cancelButton = RoundButton.cancelButton()
        cancelButton.addTarget(self, action: #selector(cancelPressed(sender:)), for: .touchUpInside)
        
        // required
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(statusButton)
        scrollView.addSubview(descriptionTextField!)
        scrollView.addSubview(durationTextField!)
        scrollView.addSubview(pickGroupsButton)
        scrollView.addSubview(selectedGroupsLabel)

        self.view.addSubview(scrollView)
        self.view.addSubview(confirmButton)
        self.view.addSubview(cancelButton)
        
        scrollView.autoPinEdge(toSuperviewEdge: .top)
        scrollView.autoPinEdge(toSuperviewEdge: .left)
        scrollView.autoPinEdge(toSuperviewEdge: .right)
        scrollView.autoPinEdge(.bottom, to: .top, of: confirmButton, withOffset: -16)
        
        statusButton.autoPinEdge(toSuperviewEdge: .top, withInset: 24)
        statusButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        descriptionTextField?.autoPinEdge(.top, to: .bottom, of: statusButton, withOffset: 24)
        descriptionTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        descriptionTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        descriptionTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        durationTextField?.autoPinEdge(.top, to: .bottom, of: descriptionTextField!, withOffset: 0)
        durationTextField?.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        durationTextField?.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        durationTextField?.autoAlignAxis(toSuperviewAxis: .vertical)
        
        pickGroupsButton.autoPinEdge(.top, to: .bottom, of: durationTextField!, withOffset: 8)
        pickGroupsButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        selectedGroupsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        selectedGroupsLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        selectedGroupsLabel.autoPinEdge(.top, to: .bottom, of: pickGroupsButton, withOffset: 8)
        selectedGroupsLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        cancelButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        confirmButton.autoPinEdge(toSuperviewEdge: .left, withInset: 16)

        // if iphone X
        if BasicController.hasTopNotch() == true {
            confirmButton.autoPinEdge(toSuperviewSafeArea: .bottom)
            cancelButton.autoPinEdge(toSuperviewSafeArea: .bottom)
        } else {
            confirmButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            cancelButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        }
        
        self.view.bringSubview(toFront: activityIndicator)
    }
    
    @objc func confirmPressed(sender: UIButton!) {
        let statusType = currentStatusPickerState
        guard let description = descriptionTextField?.text else {
            return
        }
        if description.count > 140 {
            vibrate()
            return
        }
        
        let listOfGroupIds = selectedGroupsSet.allObjects as! [String]
        
        // duration can be nil only if statusType == NA
        // 0 groups allowed only if statusType == NA
        if statusType != "NA" {
            if self.hours == nil || self.minutes == nil {
                durationController?.setErrorText("Please pick a duration", errorAccessibilityValue: nil)
                vibrate()
                return
            }
            if listOfGroupIds.count == 0 {
                selectedGroupsLabel.textColor = UIColor.red
                vibrate()
                return
            }
        }
        
        let hours = self.hours ?? 0
        let minutes = self.minutes ?? 0
        
        changeStatus(statusType: statusType, statusDescription: description, hours: hours, minutes: minutes, listOfGroupIds: listOfGroupIds)
    }
    
    func changeStatus(statusType: String, statusDescription: String, hours: Int, minutes: Int, listOfGroupIds: [String]) {
        if BasicController.isThereInternet() == false {
            errorAlert(message: "No internet connection")
            vibrate()
            return
        }
        
        activityIndicator.startAnimating()
        
        client.callFunction(withName: "updateStatus", withArgs: [statusType, statusDescription, hours, minutes, listOfGroupIds]) { (result: StitchResult<String>) in
            switch result {
            case .success(let result):
                if result == "Successful update" {
                    self.successAlertGetProfile(description: "Status updated")
                } else if result == "writeConcernError" {
                    self.errorAlert(message: "Error code: U-2")
                } else if result == "writeError" {
                    self.errorAlert(message: "Error code: U-2")
                } else {
                    self.errorAlert(message: "Error code: U-4")
                }
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: U-1)")
            }
        }
    }
    
    @objc func cancelPressed(sender: UIButton!) {
        // do nothing and return
        self.navigationController?.popViewController(animated: true)
    }
    
    func redrawSelectedGroupsLabel() {
        let groupsString = NSMutableAttributedString(string: "Groups:\n")
        var count = 0
        for group in (accountController.userProfile?.listOfFriendGroups)! {
            if selectedGroupsSet.contains(group.groupId) {
                if count > 0 {
                    groupsString.append(NSAttributedString(string: ", "))
                }
                let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: BasicController.hexToUIColor(color: group.groupTextColor)]
                let attributedGroup = NSAttributedString(string: group.friendListName, attributes: attributes)
                groupsString.append(attributedGroup)
                count += 1
            }
        }
        selectedGroupsLabel.textColor = UIColor.white
        selectedGroupsLabel.attributedText = groupsString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redrawSelectedGroupsLabel()
    }
    
    @objc func activateGroupsPicker(sender: UIButton!) {
        let listOfFriendGroups = accountController.userProfile?.listOfFriendGroups
        var tupleArray = [(String, String, String)]()
        
        for group in listOfFriendGroups! {
            tupleArray.append((group.friendListName, group.groupTextColor, group.groupId))
        }
        
        let groupPickerController = ColoredSelectTableViewController.init(title: "Pick Groups", tupleArray: tupleArray, isMultiSelect: true)
        groupPickerController.selectedStrings = self.selectedGroupsSet

        self.navigationController?.pushViewController(groupPickerController, animated: true)
    }
    
    @objc func activateDurationPicker(sender: UITextField!) {
        self.view.endEditing(true)
        
        let durationPicker = CountdownPickerPopover(title: "Duration")
        .setSelectedTimeInterval(TimeInterval())
        .setDoneButton(action: { (popover, timeInterval) in
            let (hours, minutes) = self.secondsToHoursAndMinutes(seconds: timeInterval)
            self.hours = hours
            self.minutes = minutes
            sender.text = ("\(hours) hours, \(minutes) minutes")
            sender.endEditing(true)
        })
        .setValueChange(action: { (popover, timeInterval) in
            let (hours, minutes) = self.secondsToHoursAndMinutes(seconds: timeInterval)
            self.hours = hours
            self.minutes = minutes
            sender.text = ("\(hours) hours, \(minutes) minutes")
        })
        .setCancelButton(title: "", font: nil, color: nil, action: { (popover, interval) in
        })
        .setDimmedBackgroundView(enabled: true)
        
        if let hours = hours {
            if let minutes = minutes {
                _ = durationPicker.setSelectedTimeInterval(CountdownPickerPopover.ItemType(hours * 3600 + minutes * 60))
            }
        }
        durationPicker.appear(originView: sender, baseViewController: self)
    }
    
    @objc func activateStatusPicker(sender: UIButton!) {
        self.view.endEditing(true)
        
        let statusPicker = StringPickerPopover(title: "Status Type", choices: ["Ready to Chill", "Do Not Disturb", "Not Available"])
            .setDoneButton(title: "Done", color: UIColor.white, action: { (popover, selectedRow, selectedString) in
                if selectedRow == 0 {
                    self.currentStatusPickerState = "R2C"
                    sender.setAttributedTitle(self.R2CAttributedString, for: .normal)
                } else if selectedRow == 1 {
                    self.currentStatusPickerState = "DND"
                    sender.setAttributedTitle(self.BusyAttributedString, for: .normal)
                } else {
                    self.currentStatusPickerState = "NA"
                    sender.setAttributedTitle(self.NAAttributedString, for: .normal)
                }
            })
            .setValueChange(action: { (popover, selectedRow, selectedString) in
                if selectedRow == 0 {
                    self.currentStatusPickerState = "R2C"
                    sender.setAttributedTitle(self.R2CAttributedString, for: .normal)
                } else if selectedRow == 1 {
                    self.currentStatusPickerState = "DND"
                    sender.setAttributedTitle(self.BusyAttributedString, for: .normal)
                } else {
                    self.currentStatusPickerState = "NA"
                    sender.setAttributedTitle(self.NAAttributedString, for: .normal)
                }
            })
            .setCancelButton(title: "", color: nil, action: nil)
            .setImages([#imageLiteral(resourceName: "R2CIcon"), #imageLiteral(resourceName: "BusyIcon"), #imageLiteral(resourceName: "NAIcon")])
            .setFontSize(24)
            .setFontColor(UIColor.white)
            .setDimmedBackgroundView(enabled: true)
        
        if self.currentStatusPickerState == "R2C" {
            _ = statusPicker.setSelectedRow(0)
        } else if self.currentStatusPickerState == "DND" {
            _ = statusPicker.setSelectedRow(1)
        } else {
            _ = statusPicker.setSelectedRow(2)
        }
        statusPicker.appear(originView: sender, baseViewController: self)
    }
    
    func secondsToHoursAndMinutes(seconds: Double) -> (Int, Int) {
        let secondsInteger = Int(seconds)
        return (secondsInteger / 3600, (secondsInteger % 3600) / 60)
    }
    
    // Mark: Textfield/view functions
    
    @objc func descriptionCleared(sender: UIButton!) {
        descriptionController?.setErrorText(nil, errorAccessibilityValue: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == durationTextField {
            durationController?.setErrorText(nil, errorAccessibilityValue: nil)
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == durationTextField {
            activateDurationPicker(sender: textField)
        }
        return true
    }

    // required to clear text fields properly
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        _ = self.textField(textField, shouldChangeCharactersIn: NSRange.init(), replacementString: "")
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
