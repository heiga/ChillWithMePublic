//
//  FriendGroup.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-17.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation

class FriendGroup: Codable {
    
    var friendListName: String
    var groupTextColor: String
    var groupId: String
    var groupDescription: String
    var notificationsOn: Bool
    var listOfFriendsUsernames: [String]
    var friendArrayList: [Friend]
    
    init(groupName: String, groupDescription: String, notifications: Bool, textColor: String, groupId: String, listOfFriends: [String]) {
        self.friendListName = groupName
        self.groupTextColor = textColor
        self.groupId = groupId
        self.groupDescription = groupDescription
        self.notificationsOn = notifications
        self.listOfFriendsUsernames = listOfFriends
        self.friendArrayList = [Friend]()
    }
    
    init() {
        self.friendListName = "Friend List"
        self.groupTextColor = "#FFFFFF"
        self.groupId = "0"
        self.groupDescription = ""
        self.notificationsOn = false
        self.listOfFriendsUsernames = [String]()
        self.friendArrayList = [Friend]()
    }
    
    func addFriend(friend: Friend) {
        self.friendArrayList.append(friend)
    }
    
    func getTotalNumberOfFriends() -> Int {
        return friendArrayList.count
    }
    
    func getNumberOfFriendsR2C() -> Int {
        var friendsReady = 0
        for friend in self.friendArrayList {
            if friend.isR2C() {
                friendsReady += 1
            }
        }
        return friendsReady
    }
}






















