//
//  YourStatusCell.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-19.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import PureLayout

class YourStatusCell: UITableViewCell {

    let accountController = AccountController.shared
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // setup view
        self.backgroundColor = UIColor.backgroundGray
        
        if let userProfile = accountController.userProfile {
            let yourCurrentStatus = userProfile.yourCurrentStatus
            
            let usernameLabel = UILabel()
            let statusLabel = UILabel()
            let groupsLabel = UILabel()
            let statusImage = UIImageView()
            
            usernameLabel.text = accountController.userProfile?.userName
            usernameLabel.textColor = UIColor.white
            usernameLabel.font = usernameLabel.font.withSize(28)
            
            groupsLabel.textColor = UIColor.white
            
            statusLabel.textColor = UIColor.white
            statusLabel.font = statusLabel.font.withSize(18)
            statusLabel.numberOfLines = 0
            statusLabel.lineBreakMode = .byWordWrapping
            statusLabel.sizeToFit()
            
            let groupString = NSMutableAttributedString(string: "Groups your status was sent to: \n")
            
            // if is Busy or R2C
            if yourCurrentStatus.isBusyOrR2C() {
                if yourCurrentStatus.isR2C() == true {
                    statusImage.image = #imageLiteral(resourceName: "R2CIcon")
                } else if yourCurrentStatus.isBusy() == true {
                    statusImage.image = #imageLiteral(resourceName: "BusyIcon")
                } else {
                    statusImage.image = #imageLiteral(resourceName: "NAIcon")
                }
                
                var count = 0
                for group in userProfile.listOfFriendGroups {
                    if yourCurrentStatus.listOfGroupIds.contains(group.groupId) {
                        if count > 0 {
                            groupString.append(NSAttributedString(string: ", "))
                        }
                        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: BasicController.hexToUIColor(color: group.groupTextColor)]
                        let attributedGroup = NSAttributedString(string: group.friendListName, attributes: attributes)
                        groupString.append(attributedGroup)
                        count += 1
                    }
                }
                
                let untilStringAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.lightGray]
                let untilString = NSAttributedString(string: " until: ", attributes: untilStringAttributes)
                let statusString = NSMutableAttributedString(string: yourCurrentStatus.statusDescription)
                statusString.append(untilString)
                statusString.append(NSAttributedString(string: BasicController.convertToReadable(numericStringTime: yourCurrentStatus.timeUntil)))
                
                statusLabel.attributedText = statusString
                groupsLabel.attributedText = groupString
                
            } else {
                // is Not available
                statusImage.image = #imageLiteral(resourceName: "NAIcon")
                statusLabel.text = "Not Available"
                groupsLabel.attributedText = NSAttributedString(string: "All groups see you as: Not Available")
            }
            
            statusImage.contentMode = .center
            
            groupsLabel.font = groupsLabel.font.withSize(14)
            groupsLabel.numberOfLines = 0
            groupsLabel.lineBreakMode = .byWordWrapping
            groupsLabel.sizeToFit()
            groupsLabel.layoutIfNeeded()
            
            self.addSubview(statusImage)
            self.addSubview(usernameLabel)
            self.addSubview(statusLabel)
            self.addSubview(groupsLabel)
            
            statusImage.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            statusImage.autoPinEdge(.bottom, to: .bottom, of: usernameLabel, withOffset: 0)
            statusImage.autoPinEdge(.top, to: .top, of: usernameLabel, withOffset: 0)
            
            usernameLabel.autoPinEdge(.left, to: .right, of: statusImage, withOffset: 12)
            usernameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
            
            statusLabel.autoPinEdge(.top, to: .bottom, of: usernameLabel, withOffset: 0)
            statusLabel.autoPinEdge(.left, to: .left, of: usernameLabel, withOffset: 0)
            statusLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            
            groupsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            groupsLabel.autoPinEdge(.top, to: .bottom, of: statusLabel, withOffset: 8)
            groupsLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
            groupsLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            
            statusLabel.sizeToFit()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




















