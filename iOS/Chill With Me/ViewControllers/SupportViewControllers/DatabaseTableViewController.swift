//
//  DatabaseTableViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-19.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation
import UIKit
import StitchCore
import StitchCoreSDK
import GoogleSignIn
import MaterialComponents.MaterialActivityIndicator

class DatabaseTableViewController: UITableViewController {
    
    var accountController = AccountController.shared
    var userProfile: UserProfile?
    
    var activityIndicator = MDCActivityIndicator()
    
    lazy var newRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        let refreshAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: refreshAttributes)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5 , y: UIScreen.main.bounds.size.height * 0.4)
        self.view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
    }
    
    func isSignedIn() -> Bool {
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    
    func isProfileOnFile() -> Bool {
        return accountController.isProfileOnFile()
    }
    
    func redraw() -> Void {
        userProfile = accountController.userProfile
        DispatchQueue.main.async {
            self.tableView.reloadData()
            DispatchQueue.main.async {
                if let refreshControl = self.refreshControl {
                    refreshControl.endRefreshing()
                }
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func checkIfProfileUpdated() -> Void {
        if BasicController.isThereInternet() == false {
            self.redraw()
            return
        }
 
        if accountController.isProfileOnFile() {
            let client = Stitch.defaultAppClient!
            accountController.loadProfileFromFile()
            if let userProfile = accountController.userProfile {
                client.callFunction(withName: "checkIfProfileUpdated", withArgs: [userProfile.refreshToken]) {
                    (result: StitchResult<Bool>) in
                    switch result {
                    case .success(let result):
                        if result == true {
                            self.getProfileFromDB()
                        } else {
                            DispatchQueue.main.async {
                                self.redraw()
                            }
                        }
                        
                    case .failure(_):
                        self.errorAlert(message: "Failed to communicate with server (Error code DC-2)")
                        DispatchQueue.main.async {
                            self.redraw()
                        }
                    }
                }
                
            } else {
                errorAlert(message: "File system corrupt (Error code DC-1)")
                DispatchQueue.main.async {
                    self.redraw()
                }
            }
        }
    }
    
    func getProfileFromDB() -> Void {
        let client = Stitch.defaultAppClient!
        client.callFunction(withName: "getProfile", withArgs: []) {
            (result: StitchResult<Document>) in
            switch result {
            case .success(let result):
                let decoder = JSONDecoder()
                do {
                    let jsonData = Data(result.extendedJSON.utf8)
                    let userProfile: UserProfile = try decoder.decode(UserProfile.self, from: jsonData)
                    if self.accountController.storeUserProfile(profile: userProfile) == false {
                        self.errorAlert(message: "File system error (Error code DC-4)")
                        DispatchQueue.main.async {
                            self.redraw()
                        }
                    } else {
                        // all is good
                        DispatchQueue.main.async {
                            self.redraw()
                        }
                    }
                } catch {
                    self.errorAlert(message: "File corrupted error (Error code DC-5)")
                    DispatchQueue.main.async {
                        self.redraw()
                    }
                }
            case .failure(_):
                self.errorAlert(message: "Server communication failed (Error code DC-3)")
                DispatchQueue.main.async {
                    self.redraw()
                }
            }
        }
    }
    
    func errorAlert(message: String) -> Void {
        self.redraw()
        doNothingAlert(title: "Error", message: message, buttonText: "Ok")
    }
    
    func doNothingAlert(title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    @objc func refreshData(sender: UIRefreshControl) {
        if BasicController.isThereInternet() == false {
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }
            return
        } else {
            checkIfProfileUpdated()
        }
    }
}
