//
//  YourGroupsViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-16.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

class YourGroupsViewController: DatabaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userProfile = accountController.userProfile
        
        view.backgroundColor = UIColor.backgroundGray
        setupNavigationBar()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
        self.tableView.refreshControl = newRefreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        userProfile = accountController.userProfile
        redraw()
    }
 
    func setupNavigationBar() {
        self.navigationItem.title = "Your Groups"
        navigationController?.navigationBar.barTintColor = UIColor.barBlue
        let whiteTitleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = whiteTitleAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = whiteTitleAttributes
    }
    
    // Mark: Tableview functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // one for complete friend list, one for user's groups
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userProfile = userProfile {
            if section == 0 {
                return 1
            } else {
                return userProfile.listOfFriendGroups.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if let userProfile = userProfile {
            if section == 0 {
                let groupCell = YourGroupsCell(style: .default, reuseIdentifier: "groupCell", group: userProfile.completeFriendList)
                return groupCell
            } else {
                let listOfFriendGroups = userProfile.listOfFriendGroups
                let row = indexPath.row
                let groupCell = YourGroupsCell(style: .default, reuseIdentifier: "groupCell", group: listOfFriendGroups[row])
                return groupCell
            }
        } else {
            return RegularCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        // Complete Friends List selected
        if section == 0 {
            let selectedGroupController = SelectedGroupViewController()
            selectedGroupController.friendGroup = userProfile?.completeFriendList
            self.navigationController?.pushViewController(selectedGroupController, animated: true)
        } else {
            // Group selected
            let selectedGroupController = SelectedGroupViewController()
            selectedGroupController.friendGroup = userProfile?.listOfFriendGroups[row]
            self.navigationController?.pushViewController(selectedGroupController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
