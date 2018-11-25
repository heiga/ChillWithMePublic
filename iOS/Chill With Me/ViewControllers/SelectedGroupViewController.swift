//
//  SelectedGroupViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-24.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import StitchCore

class SelectedGroupViewController: DatabaseTableViewController, SelectedGroupFriendCellDelegate,  SelectedGroupDescriptionCellDelegate {
    
    var friendGroup: FriendGroup?
    var friendGroupId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfile = accountController.userProfile
        view.backgroundColor = UIColor.backgroundGray
        setupNavigationBar()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
        self.tableView.refreshControl = newRefreshControl
        
        if let friendGroup = friendGroup {
            self.friendGroupId = friendGroup.groupId
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        if accountController.tableViewRequiresReload == true {
            accountController.tableViewRequiresReload = false
            redraw()
        }
    }
    
    func setupNavigationBar() {
        if let friendGroup = friendGroup {
            let titleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: BasicController.hexToUIColor(color: friendGroup.groupTextColor)]
            navigationController?.navigationBar.titleTextAttributes = titleAttributes
            navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
            navigationController?.navigationBar.barTintColor = UIColor.darkGray
            self.navigationItem.title = friendGroup.friendListName
        }
    }
    
    override func redraw() {
        // have new profile, use id to get new group object
        if let userProfile = accountController.userProfile {
            if self.friendGroupId! == "0" {
                self.friendGroup = userProfile.completeFriendList
            } else {
                var foundGroup: FriendGroup?
                for group in userProfile.listOfFriendGroups {
                    if group.groupId == self.friendGroupId! {
                        foundGroup = group
                        break
                    }
                }
                // if no group found, then it has been deleted -> activity is done
                if foundGroup == nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.friendGroup = foundGroup
                }
            }
            setupNavigationBar()
            super.redraw()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // group description section, friends section
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friendGroup = friendGroup {
            if section == 0 {
                // if complete friends list, no description section
                if friendGroup.groupId == "0" {
                    return 0
                } else {
                    return 1
                }
            } else {
                return friendGroup.friendArrayList.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if let friendGroup = friendGroup {
            if section == 0 {
                let descriptionCell = SelectedGroupDescriptionCell(style: .default, reuseIdentifier: "descriptionCell", group: friendGroup)
                descriptionCell.delegate = self
                return descriptionCell
            } else {
                let friendCell = SelectedGroupCell(style: .default, reuseIdentifier: "friendCell", friend: friendGroup.friendArrayList[row])
                friendCell.delegate = self
                return friendCell
            }
        } else {
            return RegularCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Mark: My Functions
    
    func overflowButtonPressed(friend: Friend, sender: UIButton) {
        let actionSheet = UIAlertController(title: "Edit or delete \(friend.alias!)?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            self.editFriend(friend: friend)
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deleteFriendAlert(friend: friend)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        }))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func overflowButtonPressed(group: FriendGroup, sender: UIButton) {
        let actionSheet = UIAlertController(title: "Edit or delete \(group.friendListName)?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            self.editGroup(group: group)
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deleteGroupAlert(group: group)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
        }))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func editFriend(friend: Friend) {
        DispatchQueue.main.async {
            let editFriendViewController = AddOrEditFriendViewController()
            editFriendViewController.friendToEdit = friend
            self.navigationController?.pushViewController(editFriendViewController, animated: true)
        }
    }
    
    func deleteFriendAlert(friend: Friend) {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(friend.alias!)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.deleteFriendFromDatabase(friend: friend)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
        }))
        
        self.present(alert, animated: true)
    }
    
    func editGroup(group: FriendGroup) {
        DispatchQueue.main.async {
            let editGroupViewController = AddOrEditGroupViewController()
            editGroupViewController.groupToEdit = group
            self.navigationController?.pushViewController(editGroupViewController, animated: true)
        }
    }
    
    func deleteGroupAlert(group: FriendGroup) {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(group.friendListName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.deleteGroupFromDatabase(group: group)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
        }))
        
        self.present(alert, animated: true)
    }
    
    func deleteFriendFromDatabase(friend: Friend) {
        guard let username = friend.ownerUsername else {
            return
        }
        
        activityIndicator.startAnimating()
        
        let client = Stitch.defaultAppClient!
        client.callFunction(withName: "deleteFriend", withArgs: [username]) { (result: StitchResult<String>) in
            switch result {
            case .success(let result):
                if result == "Successful delete" {
                    self.getProfileFromDB()
                } else if result == "Invalid input" {
                    self.errorAlert(message: "Error code: S-1")
                } else if result == "writeConcernError" {
                    self.errorAlert(message: "Error code: S-2")
                } else if result == "writeError" {
                    self.errorAlert(message: "Error code: S-3")
                } else {
                    self.errorAlert(message: "Error code: S-4")
                }
                
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: S-5")
            }
        }
    }
    
    func deleteGroupFromDatabase(group: FriendGroup) {
        activityIndicator.startAnimating()
        
        let client = Stitch.defaultAppClient!
        client.callFunction(withName: "deleteGroup", withArgs: [group.groupId]) { (result: StitchResult<String>) in
            switch result {
            case .success(let result):
                if result == "Successful delete" {
                    self.getProfileFromDB()
                } else if result == "Invalid input" {
                    self.errorAlert(message: "Error code: S-6")
                } else if result == "writeConcernError" {
                    self.errorAlert(message: "Error code: S-7")
                } else if result == "writeError" {
                    self.errorAlert(message: "Error code: S-8")
                } else {
                    self.errorAlert(message: "Error code: S-9")
                }
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: S-10")
            }
        }
    }
}
