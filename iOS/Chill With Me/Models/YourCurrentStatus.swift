//
//  YourCurrentStatus.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-19.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation

// This is supposed to inherit from CurrentStatus but doing so causes EXC_BAD_ACCESS problems due to Codable
// Therefore this is mostly a duplicate class
class YourCurrentStatus: Codable {
    
    var listOfGroupIds: [String]
    var listOfFriends: [String]
    
    var statusType: String
    var statusDescription: String
    var timeUntil: String

    init(statusType: String, statusDescription: String, timeUntil: String, listOfGroupIds: [String], listOfFriends: [String]) {
        self.statusType = statusType
        self.statusDescription = statusDescription
        self.timeUntil = timeUntil
        self.listOfGroupIds = listOfGroupIds
        self.listOfFriends = listOfFriends
    }
    
    func isTimeValid() -> Bool {
        if let numericTime = Double(self.timeUntil) {
            if numericTime > NSDate().timeIntervalSince1970 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func isR2C() -> Bool {
        if self.isTimeValid() {
            if self.statusType == R2C {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func isBusy() -> Bool {
        if self.isTimeValid() {
            if self.statusType == DND {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func isBusyOrR2C() -> Bool {
        if self.isR2C() || self.isBusy() {
            return true
        } else {
            return false
        }
    }
    
    /*
    init(statusType: String, statusDescription: String, timeUntil: String, listOfGroupIds: [String], listOfFriends: [String]) {
        self.listOfGroupIds = listOfGroupIds
        self.listOfFriends = listOfFriends
        super.init(type: statusType, description: statusDescription, time: timeUntil)
    }
    
    /*
    override init() {
        self.listOfGroupIds = []
        self.listOfFriends = []
        super.init()
    }
    */
    
    private enum CodingKeys: String, CodingKey {
        case listOfGroupIds = "listOfGroupIds"
        case listOfFriends = "listOfFriends"
    }
    
    required init(from decoder: Decoder) throws {
        //fatalError("init(from:) has not been implemented")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        listOfGroupIds = try container.decode([String].self, forKey: .listOfGroupIds)
        listOfFriends = try container.decode([String].self, forKey: .listOfFriends)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)        
    }
    */
    
}
