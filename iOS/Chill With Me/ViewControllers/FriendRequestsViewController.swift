//
//  FriendRequestsViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-24.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import StitchCore

class FriendRequestsViewController: DatabaseTableViewController, FriendRequestCellDelegate {

    var friendRequests: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userProfile = accountController.userProfile
        
        view.backgroundColor = UIColor.backgroundGray
        self.navigationItem.title = "Friend Requests"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.tableView.refreshControl = newRefreshControl
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // if friend is added, it will no longer be in the friends request list
        if accountController.tableViewRequiresReload == true {
            accountController.tableViewRequiresReload = false
            redraw()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userProfile = userProfile {
            return userProfile.friendRequestList.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let userProfile = userProfile {
            let friendRequestCell = FriendRequestCell.init(style: .default, reuseIdentifier: "friendRequestCell", requestName: userProfile.friendRequestList[indexPath.row])
            friendRequestCell.delegate = self
            return friendRequestCell
        } else {
            return RegularCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Mark: My Functions
    
    func friendAcceptPressed(username: String) {
        DispatchQueue.main.async {
            let addFriendViewController = AddOrEditFriendViewController()
            addFriendViewController.usernameFromFriendRequests = username
            self.navigationController?.pushViewController(addFriendViewController, animated: true)
        }
    }
    
    func friendDeletePressed(username: String) {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(username)'s request?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in
            self.deleteFriendRequest(username: username)
            }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func deleteFriendRequest(username: String) {
        activityIndicator.startAnimating()
        
        let client = Stitch.defaultAppClient!
        client.callFunction(withName: "deleteFriendRequest", withArgs: [username]) { (result: StitchResult<String>) in
            switch result {
            case .success(let result):
                if result == "Successful delete" {
                    self.getProfileFromDB()
                } else {
                    self.errorAlert(message: "Server error (Error code: R-2)")
                }
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: R-1")
            }
        }
    }
}
