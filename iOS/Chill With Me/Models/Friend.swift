//
//  Friend.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-17.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation

class Friend: Codable {
    
    var ownerUsername: String?
    var alias: String?
    var description: String?
    var textColor: String
    var currentStatus: CurrentStatus
    var acknowledged: Bool
    
    var listOfGroupIds: [String]
    
    init(userName: String, name: String, descript: String, color: String, currentStatus: CurrentStatus, groupList: [String]) {
        self.ownerUsername = userName
        self.alias = name
        self.description = descript
        self.textColor = color
        self.currentStatus = currentStatus
        self.listOfGroupIds = groupList
        self.acknowledged = false
    }
    
    init() {
        self.ownerUsername = nil
        self.alias = nil
        self.description = nil
        self.textColor = "#FFFFFF"
        self.currentStatus = CurrentStatus.init()
        self.listOfGroupIds = [String]()
        self.acknowledged = false
    }
    
    func isR2C() -> Bool {
        return self.currentStatus.isR2C()
    }
    
    func isBusy() -> Bool {
        return self.currentStatus.isBusy()
    }
    
    func isBusyOrR2C() -> Bool {
        return self.currentStatus.isBusyOrR2C()
    }
}
















