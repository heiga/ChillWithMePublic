//
//  SubmissionFormViewController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-11-12.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import GoogleSignIn
import StitchCore
import MaterialComponents.MaterialActivityIndicator
import AVFoundation

class SubmissionFormViewController: UIViewController {
    
    let accountController = AccountController.shared
    let client = Stitch.defaultAppClient!
    
    var selectedTextColor = NSMutableSet()
    
    var activityIndicator = MDCActivityIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5 , y: UIScreen.main.bounds.size.height * 0.5)
        self.view.addSubview(activityIndicator)
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func getSelectedColor() -> String {
        if selectedTextColor.count > 0 {
            let colorArray = selectedTextColor.allObjects
            let color = colorArray.first as! String
            return color
        } else {
            // default to white
            return UIColor.whiteString
        }
    }
    
    func isStringValid(string: String) -> Bool{
        return string.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    func successAlertGetProfile(description: String) {
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Success", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: getProfileFromDB))
        self.present(alert, animated: true)
    }
    
    func getProfileFromDB(alert: UIAlertAction!) -> Void {
        getProfileFromDB()
    }
    
    func popViewController(alert: UIAlertAction!) -> Void {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getProfileFromDB() {
        let client = Stitch.defaultAppClient!
        
        self.activityIndicator.startAnimating()
        
        client.callFunction(withName: "getProfile", withArgs: []) { (result: StitchResult<Document>) in
            switch result {
            case .success(let result):
                let decoder = JSONDecoder()
                do {
                    let jsonData = Data(result.extendedJSON.utf8)
                    let userProfile: UserProfile = try  decoder.decode(UserProfile.self, from: jsonData)
                    if self.accountController.storeUserProfile(profile: userProfile) == false {
                        self.errorAlert(message: "File system error (Error code: SF-3")
                    } else {
                        // all is good so return to main screen
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    self.activityIndicator.stopAnimating()
                } catch {
                    self.errorAlert(message: "File corrupted error (Error code: SF-2")
                }
            case .failure(_):
                self.errorAlert(message: "Failed to communicate with server (Error code: SF-1)")
            }
        }
    }
    
    func errorAlert(message: String) -> Void {
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
