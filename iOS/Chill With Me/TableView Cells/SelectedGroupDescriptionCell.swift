//
//  SelectedGroupDescriptionCell.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-24.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

class SelectedGroupDescriptionCell: UITableViewCell {

    var friendGroup: FriendGroup?
    var notificationsOn: Bool?
    weak var delegate: SelectedGroupDescriptionCellDelegate?
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, group: FriendGroup?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // setup view
        self.backgroundColor = UIColor.backgroundGray
        
        if let friendGroup = group {
            self.friendGroup = friendGroup
            
            let groupDescription = friendGroup.groupDescription
            let notificationsOn = friendGroup.notificationsOn
            
            let labelString = NSMutableAttributedString(string: groupDescription)
            let whiteAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white]
            let notificationsString = NSAttributedString(string: "\nNotifications: ", attributes: whiteAttributes)
            labelString.append(notificationsString)
            
            if notificationsOn == true {
                let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.red]
                let onString = NSAttributedString(string: "On", attributes: attributes)
                labelString.append(onString)
            } else {
                let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.lightGray]
                let offString = NSAttributedString(string: "Off", attributes: attributes)
                labelString.append(offString)
            }
            
            let descriptionLabel = UILabel()
            descriptionLabel.font = descriptionLabel.font.withSize(16)
            descriptionLabel.textColor = UIColor.lightGray
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.attributedText = labelString
            
            let notificationsLabel = UILabel()
            notificationsLabel.font = notificationsLabel.font.withSize(16)
            notificationsLabel.textColor = UIColor.white
            
            let overflowButton = UIButton()
            overflowButton.setImage(#imageLiteral(resourceName: "OverflowIcon"), for: .normal)
            overflowButton.contentMode = .center
            overflowButton.addTarget(self, action: #selector(overflowPressed(sender:)), for: .touchUpInside)
            
            self.addSubview(descriptionLabel)
            self.addSubview(overflowButton)
            
            overflowButton.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
            overflowButton.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
            
            descriptionLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        }
    }
    
    @objc func overflowPressed(sender: UIButton!)  {
        delegate?.overflowButtonPressed(group: self.friendGroup!, sender: sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol SelectedGroupDescriptionCellDelegate: class {
    func overflowButtonPressed(group: FriendGroup, sender: UIButton)
}
