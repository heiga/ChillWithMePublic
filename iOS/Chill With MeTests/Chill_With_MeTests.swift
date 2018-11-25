//
//  Chill_With_MeTests.swift
//  Chill With MeTests
//
//  Created by Phillip Hoang on 2018-08-22.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import XCTest
@testable import Chill_With_Me

class Chill_With_MeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEmptyCurrentStatusInit() {
        let currentStatus = CurrentStatus.init()
        XCTAssertNotNil(currentStatus)
    }
    
    func testRealCurrentStatusInit() {
        let currentStatus = CurrentStatus.init(type: "R2C", description: "Ready to Jim", time: "3400000000")
        XCTAssertNotNil(currentStatus)
    }
    
    func testValidCurrentStatusIsTimeValid() {
        let currentStatus = CurrentStatus.init(type: "R2C", description: "Ready to Jim", time: "3400000000")
        XCTAssertTrue(currentStatus.isTimeValid())
    }
    
    func testInvalidCurrentStatusIsTimeValid() {
        let currentStatus = CurrentStatus.init(type: "R2C", description: "Ready to Jim", time: "1000000000")
        XCTAssertFalse(currentStatus.isTimeValid())
    }
    
    func testBrokenTimeCurrentStatusIsTimeValid() {
        let currentStatus = CurrentStatus.init(type: "R2C", description: "Ready to Jim", time: "abc")
        XCTAssertFalse(currentStatus.isTimeValid())
    }
    
    func testCurrentStatusIsR2C() {
        let currentStatus = CurrentStatus.init(type: "R2C", description: "Ready to Jim", time: "3500000000")
        XCTAssertTrue(currentStatus.isR2C())
        XCTAssertTrue(currentStatus.isBusyOrR2C())
        XCTAssertFalse(currentStatus.isBusy())
    }
    
    func testCurrentStatusIsBusy() {
        let currentStatus = CurrentStatus.init(type: "DND", description: "Ready to Jim", time: "3500000000")
        XCTAssertTrue(currentStatus.isBusyOrR2C())
        XCTAssertTrue(currentStatus.isBusy())
        XCTAssertFalse(currentStatus.isR2C())
    }
    
    func testNACurrentStatus() {
        let currentStatus = CurrentStatus.init(type: "NA", description: "Ready to Jim", time: "3500000000")
        XCTAssertFalse(currentStatus.isBusyOrR2C())
        XCTAssertFalse(currentStatus.isBusy())
        XCTAssertFalse(currentStatus.isR2C())
    }
    
    func testFriendInit() {
        let friend = Friend.init(userName: "potato", name: "potatoman", descript: "Cool potato man", color: "#FFFF00", currentStatus: CurrentStatus.init(), groupList: [String]())
        XCTAssertNotNil(friend)
    }
    
    func testFriendGroupInit() {
        let friendGroup = FriendGroup.init(groupName: "Kool kid klub", groupDescription: "Klub for Kool Kids", notifications: true, textColor: "#00FFFF", groupId: "123", listOfFriends: ["potato"])
        XCTAssertNotNil(friendGroup)
    }
    
    func testFriendGroupAddFriend() {
        let friend = Friend.init(userName: "potato", name: "potatoman", descript: "Cool potato man", color: "#FFFF00", currentStatus: CurrentStatus.init(), groupList: [String]())
        let friendListToAdd = [friend]
        let friendGroup = FriendGroup.init(groupName: "Kool kid klub", groupDescription: "Klub for Kool Kids", notifications: true, textColor: "#00FFFF", groupId: "123", listOfFriends: ["potato"])
        
        XCTAssertTrue(friendGroup.friendArrayList.count == 0)
        friendGroup.friendArrayList += friendListToAdd
        XCTAssertFalse(friendGroup.friendArrayList.count == 0)
        XCTAssertNotNil(friendGroup.friendArrayList[0])
    }
    
    func testValidString() {
        let numbersOnly = "12345"
        XCTAssertTrue(BasicController.isStringValid(string: numbersOnly))
        
        let lowercaseLetters = "abcde"
        XCTAssertTrue(BasicController.isStringValid(string: lowercaseLetters))
        
        let capitalLetters = "ABCDE"
        XCTAssertTrue(BasicController.isStringValid(string: capitalLetters))
        
        let regularName = "potatoMan69"
        XCTAssertTrue(BasicController.isStringValid(string: regularName))
        
        let invalidOne = "abc%"
        XCTAssertFalse(BasicController.isStringValid(string: invalidOne))
        
        let invalidTwo = "abx 69"
        XCTAssertFalse(BasicController.isStringValid(string: invalidTwo))
        
        let invalidThree = "abc="
        XCTAssertFalse(BasicController.isStringValid(string:invalidThree))
    }
    
    func testFileSystem() {
        let accountController = AccountController.shared
        
        _ = accountController.deleteProfileOnFile()
        XCTAssertFalse(accountController.isProfileOnFile())
        
        _ = accountController.storeUserProfile(profile: UserProfile.init())
        XCTAssertTrue(accountController.isProfileOnFile())
        
        _ = accountController.deleteProfileOnFile()
        XCTAssertFalse(accountController.isProfileOnFile())
    }
}
