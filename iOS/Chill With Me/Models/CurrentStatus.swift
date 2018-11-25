//
//  CurrentStatus.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-17.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation

let R2C = "R2C"
let NA = "NA"
let DND = "DND"

class CurrentStatus: Codable {
    
    var statusType: String
    var statusDescription: String
    var timeUntil: String
    var refreshToken: String
    
    init(type: String, description: String, time: String) {
        self.statusType = type
        self.statusDescription = description
        self.timeUntil = time
        self.refreshToken = ""
    }
    
    init() {
        self.statusType = NA
        self.statusDescription = "Not available"
        self.timeUntil = "0000000000"
        self.refreshToken = ""
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
}

























