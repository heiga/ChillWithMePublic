//
//  MainScreenViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-17.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import GoogleSignIn
import StitchCore
import MaterialComponents.MaterialActivityIndicator
import AVFoundation

class MainScreenViewController: DatabaseTableViewController, GIDSignInUIDelegate {
    
    let workSection = ["Your Groups", "Change your status", "Add Friend", "Add Group", "Friend Requests"]
    let supportSection = ["Help", "Feedback"]
    let signInSection = ["Sign In"]
    let signOutSection = ["Sign Out"]
    
    var isSpinning = false
    var taps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfile = accountController.userProfile
        GIDSignIn.sharedInstance().uiDelegate = self
        
        setupNavigationBar()
        self.view.backgroundColor = UIColor.backgroundGray
        
        // REQUIRED FOR IPAD
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        self.tableView.alwaysBounceVertical = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEntersForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        if isProfileOnFile() == true {
            initialize()
        }
    }
    
    func setupNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Chill With Me"
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        navigationBar?.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationBar?.barTintColor = UIColor.barBlue
        navigationBar?.tintColor = UIColor.white
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if (signIn.currentUser) != nil {
            initialize()
        }
        if accountController.manuallySignedOut == true {
            if activityIndicator.isAnimating == true {
                accountController.manuallySignedOut = false
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewAppears()
    }
    
    @objc func appEntersForeground() {
        viewAppears()
    }
    
    func viewAppears() {
        if isSignedIn() == true {
            if accountController.isProfileOnFile() == false {
                initialize()
            } else {
                redraw()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = BasicController.hexToUIColor(color: "#545454")
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isProfileOnFile() == true {
            return 4
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isProfileOnFile() {
            if section == 1 {
                return 5
            } else if section == 2 {
                return 2
            } else {
                return 1
            }
        } else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RegularCell()
        let section = indexPath.section
        let row = indexPath.row
        
        var name: String = ""
        if isProfileOnFile() {
            switch section {
            case 0:
                let statusCell = YourStatusCell()
                return statusCell
            case 1:
                name = workSection[row]
                cell.accessoryType = .disclosureIndicator
            case 2:
                name = supportSection[row]
            case 3:
                name = signOutSection[row]
            default:
                name = "Error"
            }
        } else {
            name = signInSection[row]
        }
        
        cell.backgroundColor = UIColor.backgroundGray
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if isProfileOnFile() {
            switch section {
            case 0:
                // status cell
                stopTapping()
            case 1:
                switch row {
                case 0:
                    // Your Groups
                    DispatchQueue.main.async {
                        let yourGroupsController = YourGroupsViewController()
                        self.navigationController?.pushViewController(yourGroupsController, animated: true)
                    }
                case 1:
                    // Change your status
                    DispatchQueue.main.async {
                        let changeStatusViewController = ChangeStatusViewController()
                        self.navigationController?.pushViewController(changeStatusViewController, animated: true)
                    }
                case 2:
                    // Add Friend
                    DispatchQueue.main.async {
                        let addFriendViewController = AddOrEditFriendViewController()
                        self.navigationController?.pushViewController(addFriendViewController, animated: true)
                    }
                case 3:
                    // Add Group
                    DispatchQueue.main.async {
                        let addGroupViewController = AddOrEditGroupViewController()
                        self.navigationController?.pushViewController(addGroupViewController, animated: true)
                    }
                case 4:
                    // Friend Requests
                    DispatchQueue.main.async {
                        let friendRequestsController = FriendRequestsViewController()
                    self.navigationController?.pushViewController(friendRequestsController, animated: true)
                    }
                default:
                    break
                }
            case 2:
                switch row {
                case 0:
                    // Help
                    helpPressedAlert()
                case 1:
                    // Feedback
                    feedbackPressedAlert()
                default:
                    break
                }
            case 3:
                // Sign out
                GIDSignIn.sharedInstance().disconnect()
                GIDSignIn.sharedInstance().signOut()
                _ = accountController.deleteProfileOnFile()
                DispatchQueue.main.async {
                self.tableView.reloadData()
                }
                
            default:
                break
            }
        } else {
            // Sign in
            if activityIndicator.isAnimating == false {
                activityIndicator.startAnimating()
                _ = accountController.deleteProfileOnFile()
                GIDSignIn.sharedInstance().signIn()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Mark: My Functions
    
    func initialize() -> Void {
        // if no internet
        if BasicController.isThereInternet() == false {
            // if there is a profile on file
            if accountController.isProfileOnFile() == true {
                accountController.loadProfileFromFile()
                if let loadedProfile = accountController.userProfile {
                    userProfile = loadedProfile
                    redraw()
                }
            } else {
                // They signed in before but never created a profile then nothing can be done
                if activityIndicator.isAnimating == true {
                    activityIndicator.stopAnimating()
                }
                noInternetAlert()
            }
        } else {
            // HAS internet
            if activityIndicator.isAnimating == false {
                activityIndicator.startAnimating()
            }
            
            if accountController.isProfileOnFile() == true {
                accountController.loadProfileFromFile()
                if let loadedProfile = accountController.userProfile {
                    userProfile = loadedProfile
                }
                if Stitch.defaultAppClient!.auth.isLoggedIn == false {
                    notLoggedInAlert()
                    return
                } else {
                    activityIndicator.startAnimating()
                    checkIfProfileUpdated()
                }
            } else {
                // profile not on device
                // check if they have a profile
                checkDBForProfile()
            }
        }
    }
    
    override func redraw() -> Void {
        // redraw whole table
        DispatchQueue.main.async {
            self.tableView.reloadData()
            DispatchQueue.main.async {
                if self.activityIndicator.isAnimating == true {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func checkDBForProfile() -> Void {
        let client = Stitch.defaultAppClient!
        
        if client.auth.isLoggedIn == false {
            notLoggedInAlert()
            return
        }
        
        client.callFunction(withName: "checkForProfile", withArgs: []) {
            (result: StitchResult<Bool>) in
            switch result {
            case .success(let result):
                if result == false {
                    DispatchQueue.main.async {
                        self.gotoCreateProfile()
                    }
                } else {
                    self.getProfileFromDB()
                }
            case .failure(_):
                self.failureCheckDBForProfile()
            }
        }
    }
    
    func gotoCreateProfile() -> Void {
        let createProfileViewController = CreateProfileViewController()
        self.navigationController?.pushViewController(createProfileViewController, animated: true)
    }
    
    func helpPressedAlert() {
        let alert = UIAlertController(title: "Need help?", message: "email: help@chillwithme.ca?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: sendHelpEmail))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func sendHelpEmail(alert: UIAlertAction!) -> Void {
        composeEmail(emailAddress: "help@chillwithme.ca")
    }
    
    func feedbackPressedAlert() {
        let alert = UIAlertController(title: "Send feedback?", message: "email: feedback@chillwithme.ca", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: sendFeedbackEmail))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func sendFeedbackEmail(alert: UIAlertAction!) -> Void {
        composeEmail(emailAddress: "feedback@chillwithme.ca")
    }
    
    func composeEmail(emailAddress: String) {
        if let url = URL(string: "mailto:\(emailAddress)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func checkDBForProfileRetry(alert: UIAlertAction!) -> Void {
        checkDBForProfile()
    }
    
    func failureCheckDBForProfile() -> Void {
        let alert = UIAlertController(title: "Error", message: "Failed to communicate with server (Error code M-1)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: checkDBForProfileRetry))
        self.present(alert, animated: true)
    }
    
    func notLoggedInAlert() -> Void {
        let alert = UIAlertController(title: "Error", message: "Failed to authenticate with server (Error code M-2)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: notLoggedInSoLogOut))
        self.present(alert, animated: true)
    }
    
    func notLoggedInSoLogOut(alert: UIAlertAction!) -> Void {
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        self.tableView.reloadData()
    }
    
    func noInternetAlert() -> Void {
        doNothingAlert(title: "Error", message: "You are not connected to the internet", buttonText: "Ok")
    }
    
    // the only easter egg
    func stopTapping() {
        switch taps {
        case 7:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            doNothingAlert(title: "Hey", message: "Tapping here does nothing, trust me", buttonText: "Ok")
        case 14:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            doNothingAlert(title: "Hey", message: "Please stop, your iphone may not be able to take it", buttonText: "Ok")
        case 21:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            doNothingAlert(title: "HEY", message: "I think your iphone is bending from all this tapping, I recommend stopping", buttonText: "Ok I'll stop, I promise")
        default:
            break
        }
        if taps < 22 {
            taps += 1
        }
    }
}
