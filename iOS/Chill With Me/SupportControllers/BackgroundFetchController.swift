//
//  BackgroundFetchController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-11-16.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import StitchCore
import StitchCoreSDK
import UserNotifications

class BackgroundFetchController {

    var client: StitchAppClient?
    var accountController: AccountController?
    
    init(client: StitchAppClient?, accountController: AccountController) {
        self.client = client
        self.accountController = accountController
    }
    
    func fetch(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        checkProfile(completionHandler)
    }
    
    func checkProfile(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if accountController?.isProfileOnFile() == false {
            fail(completionHandler)
            return
        } else {
            accountController?.loadProfileFromFile()
        }
        guard let refreshToken = accountController?.userProfile?.refreshToken else {
            fail(completionHandler)
            return
        }
        
        client?.callFunction(withName: "checkIfProfileUpdated", withArgs: [refreshToken]) { (result: StitchResult<Bool>) in
                switch result {
                case .success(let result):
                    if result == true {
                        self.getProfile(completionHandler)
                    } else {
                        self.fail(completionHandler)
                    }
                case .failure(_):
                    self.fail(completionHandler)
                }
        }
    }
    
    func getProfile(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        client?.callFunction(withName: "getProfile", withArgs: []) { (result: StitchResult<Document>) in
            switch result {
            case .success(let result):
                let decoder = JSONDecoder()
                do {
                    let jsonData = Data(result.extendedJSON.utf8)
                    let newProfile: UserProfile = try decoder.decode(UserProfile.self, from: jsonData)
                    let oldProfile = self.accountController?.userProfile
                    
                    if self.accountController?.storeUserProfile(profile: newProfile) == false {
                        self.fail(completionHandler)
                    } else {
                        self.calculateAndSendNotification(completionHandler, oldProfile: oldProfile!, newProfile: newProfile)
                    }
                } catch {
                    self.fail(completionHandler)
                }
            case .failure(_):
                self.fail(completionHandler)
            }
        }
    }
    
    func calculateAndSendNotification(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void, oldProfile: UserProfile, newProfile: UserProfile) {
        // find all friends that are ready
        var readyFriends = [String:String]()
        for friend in newProfile.completeFriendList.friendArrayList {
            if friend.isR2C() {
                readyFriends[friend.ownerUsername!] = friend.currentStatus.refreshToken
            }
        }
        
        // remove friends that were already ready before
        for friend in oldProfile.completeFriendList.friendArrayList {
            if let newRefreshToken = readyFriends[friend.ownerUsername!] {
                if friend.currentStatus.refreshToken == newRefreshToken {
                    readyFriends[friend.ownerUsername!] = nil
                }
            }
        }
        
        var messageMap = [String: Int]()
        for group in newProfile.listOfFriendGroups {
            if group.notificationsOn == true {
                var number = 0
                for friend in group.friendArrayList {
                    if readyFriends[friend.ownerUsername!] != nil {
                        number += 1
                    }
                }
                if number > 0 {
                    messageMap[group.friendListName] = number
                }
            }
        }
        
        let numberOfGroupsReady = messageMap.count
        switch numberOfGroupsReady {
        case 0:
            fail(completionHandler)
            
        case 1:
            var friendOrFriends: String
            for (groupName, numberReady) in messageMap {
                if numberReady == 1 {
                    friendOrFriends = "friend in"
                } else {
                    friendOrFriends = "friends in"
                }
                let message = "You have \(numberReady) \(friendOrFriends) \(groupName) available"
                sendNotification(completionHandler, message: message)
            }
            
        case 2:
            var secondEntry = false
            var message = "You have friends in "
            for (groupName, _) in messageMap {
                if secondEntry == true {
                    message += "and "
                } else {
                    secondEntry = true
                }
                message += ("\(groupName) ")
            }
            message += "available"
            sendNotification(completionHandler, message: message)
            
        case 2...:
            var addComma = false
            var count = 0
            var message = "You have friends in "
            for (groupName, _) in messageMap {
                if addComma == true {
                    message += ", "
                } else {
                    addComma = true
                }
                if count == 2 {
                    break
                }
                message += groupName
                count += 1
            }
            let remainder = numberOfGroupsReady - 2
            if remainder == 1 {
                message += "and one other group available"
            } else {
                message += "and \(remainder) other groups available"
            }
            sendNotification(completionHandler, message: message)
        default:
            fail(completionHandler)
        }
    }
    
    func sendNotification(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void, message: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert]) { (granted, error) in
            if granted == false {
                self.fail(completionHandler)
                return
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Friends Available"
        content.body = message
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "statusUpdatedLocalNotification", content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            self.fail(completionHandler)
            /*
            if let error = error {
                // maybe log it
                // print(error.localizedDescription)
            }
            */
        }
        
        // Successful notification
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func fail(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.noData)
    }
}

























