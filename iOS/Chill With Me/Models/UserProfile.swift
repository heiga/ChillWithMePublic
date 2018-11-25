//
//  UserProfile.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-19.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation

class UserProfile: Codable {
    
    var userName: String
    var yourCurrentStatus: YourCurrentStatus
    var completeFriendList: FriendGroup
    var listOfFriendGroups: [FriendGroup]
    var friendRequestList: [String]
    var refreshToken: String
    
    init(userName: String, refreshToken: String, friendGroupList: [FriendGroup], friendRequests: [String], status: YourCurrentStatus, friendList: FriendGroup) {
        self.userName = userName
        self.refreshToken = refreshToken
        self.listOfFriendGroups = friendGroupList
        self.friendRequestList = friendRequests
        self.yourCurrentStatus = status
        self.completeFriendList = friendList
    }
    
    init() {
        self.userName = ""
        self.refreshToken = ""
        self.listOfFriendGroups = [FriendGroup]()
        self.friendRequestList = [String]()
        self.yourCurrentStatus = YourCurrentStatus.init(statusType: "NA", statusDescription: "Not available", timeUntil: "0000000000", listOfGroupIds: [String](), listOfFriends: [String]())
        self.completeFriendList = FriendGroup.init()
    }
    
    func hasGroupsWithNotificationsOn() -> Bool {
        for group in self.listOfFriendGroups {
            if group.notificationsOn {
                return true
            }
        }
        return false
    }
    
    func getNumberOfFriendRequests() -> Int {
        return self.friendRequestList.count
    }
}

