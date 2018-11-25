//
//  AccountController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-19.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation
import UIKit

class AccountController {
    let fileName = "profile.txt"
    
    static var shared = AccountController()
    
    var userProfile: UserProfile?
    var userProfileString: String?
    var manuallySignedOut: Bool
    var tableViewRequiresReload: Bool
    
    private init() {
        userProfile = nil
        userProfileString = nil
        manuallySignedOut = false
        tableViewRequiresReload = false
    }
    
    func storeUserProfile(profile userProfileToSave: UserProfile) -> Bool {
        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                // https://stackoverflow.com/questions/44553934/using-decodable-in-swift-4-with-inheritance
                let payload: Data = try JSONEncoder().encode(userProfileToSave)
                try payload.write(to: fileURL)
                self.userProfile = userProfileToSave
            }
            catch {
                return false
            }
        }

        return true
    }
    
    func isProfileOnFile() -> Bool {
        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    func loadProfileFromFile() -> Void {
        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let fileText = try String(contentsOf: fileURL, encoding: .utf8)
                    self.userProfileString = fileText
                    
                    let jsonDecoder = JSONDecoder()
                    let profile = try jsonDecoder.decode(UserProfile.self, from: fileText.data(using: .utf8)!)
                    self.userProfile = profile
                }
                catch {
                    return
                }
            }
        }
    }
    
    func deleteProfileOnFile() -> Bool {
        if isProfileOnFile() {
            if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(fileName)
                
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    return false
                }
            }
        }
        
        return true
    }
}
