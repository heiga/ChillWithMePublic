//
//  YourGroupsCell.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-21.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

class YourGroupsCell: UITableViewCell {
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, group: FriendGroup?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // setup view
        self.backgroundColor = UIColor.backgroundGray
        
        let listNameLabel = UILabel()
        listNameLabel.font = listNameLabel.font.withSize(28)
        listNameLabel.textColor = UIColor.white
        
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = UIColor.lightGray
        descriptionLabel.font = descriptionLabel.font.withSize(16)
        
        let numberLabel = UILabel()
        numberLabel.font = numberLabel.font.withSize(24)
        
        let R2CImageView = UIImageView()
        
        if let friendGroup = group {
            let friendListAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: BasicController.hexToUIColor(color: friendGroup.groupTextColor)]
            let friendListNameAttributedString = NSAttributedString(string: friendGroup.friendListName, attributes: friendListAttributes)
            
            listNameLabel.attributedText = friendListNameAttributedString
            
            if friendGroup.groupDescription == "" {
                descriptionLabel.text = " "
            } else {
                descriptionLabel.text = friendGroup.groupDescription
            }
    
            if friendGroup.getNumberOfFriendsR2C() > 0 {
                numberLabel.textColor = UIColor.white
                numberLabel.text = String(friendGroup.getNumberOfFriendsR2C())
                R2CImageView.image = #imageLiteral(resourceName: "R2CIcon")
            } else {
                numberLabel.textColor = UIColor.lightGray
                numberLabel.text = "–"
                R2CImageView.image = nil
            }
            
            R2CImageView.contentMode = .center
            listNameLabel.numberOfLines = 0
            listNameLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            
            self.addSubview(listNameLabel)
            self.addSubview(descriptionLabel)
            self.addSubview(numberLabel)
            self.addSubview(R2CImageView)
            
            listNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
            listNameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            
            descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            descriptionLabel.autoPinEdge(.top, to: .bottom, of: listNameLabel, withOffset: 4)
            
            numberLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
            numberLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
            
            R2CImageView.autoPinEdge(.top, to: .top, of: numberLabel)
            R2CImageView.autoPinEdge(.bottom, to: .bottom, of: numberLabel)
            R2CImageView.autoPinEdge(.right, to: .left, of: numberLabel, withOffset: -8)
            
            listNameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 48)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
            
            R2CImageView.sizeToFit()
            listNameLabel.sizeToFit()
            descriptionLabel.sizeToFit()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
