//
//  SelectedGroupCell.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-23.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

class SelectedGroupCell: UITableViewCell {
    
    var friend: Friend?
    weak var delegate: SelectedGroupFriendCellDelegate?
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, friend: Friend?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // setup view
        self.backgroundColor = UIColor.backgroundGray
        
        let friendNameLabel = UILabel()
        friendNameLabel.font = friendNameLabel.font.withSize(28)
        friendNameLabel.textColor = UIColor.white
        
        let statusImageView = UIImageView()
        
        let overflowButton = UIButton()
        overflowButton.setImage(#imageLiteral(resourceName: "OverflowIcon"), for: .normal)
        overflowButton.contentMode = .center
        overflowButton.addTarget(self, action: #selector(overflowPressed(sender:)), for: .touchUpInside)
        
        let descriptionTextView = UITextView()
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.isUserInteractionEnabled = true
        descriptionTextView.isEditable = false
        descriptionTextView.backgroundColor = UIColor.clear
        descriptionTextView.dataDetectorTypes = .link
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        if let friend = friend {
            self.friend = friend
            
            let friendAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: BasicController.hexToUIColor(color: friend.textColor)]
            let friendNameString = NSAttributedString(string: friend.alias!, attributes: friendAttributes)
            friendNameLabel.attributedText = friendNameString
            
            let whiteAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 16)]
            let untilStringAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 16)]
            let descriptionString = NSMutableAttributedString(string: friend.currentStatus.statusDescription, attributes: whiteAttributes)
            let untilString = NSAttributedString(string: " until: ", attributes: untilStringAttributes)
            
            if friend.currentStatus.isR2C() == true {
                statusImageView.image = #imageLiteral(resourceName: "R2CIcon")
                
                descriptionString.append(untilString)
                let timeString = NSAttributedString(string: BasicController.convertToReadable(numericStringTime: friend.currentStatus.timeUntil), attributes: whiteAttributes)
                descriptionString.append(timeString)
                descriptionTextView.attributedText = descriptionString
                
            } else if friend.currentStatus.isBusy() == true {
                statusImageView.image = #imageLiteral(resourceName: "BusyIcon")
                
                descriptionString.append(untilString)
                let timeString = NSAttributedString(string: BasicController.convertToReadable(numericStringTime: friend.currentStatus.timeUntil), attributes: whiteAttributes)
                descriptionString.append(timeString)
                descriptionTextView.attributedText = descriptionString
                
            } else {
                statusImageView.image = #imageLiteral(resourceName: "NAIcon")
                descriptionTextView.text = "Not available"
            }
        }
        
        self.addSubview(friendNameLabel)
        self.addSubview(descriptionTextView)
        self.addSubview(statusImageView)
        self.addSubview(overflowButton)
        
        statusImageView.contentMode = .center
        statusImageView.sizeToFit()
        overflowButton.contentMode = .center
        overflowButton.sizeToFit()
        
        statusImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        statusImageView.autoPinEdge(.top, to: .top, of: friendNameLabel)
        statusImageView.autoPinEdge(.bottom, to: .bottom, of: friendNameLabel)
        
        overflowButton.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
        overflowButton.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        
        friendNameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 44)
        friendNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        friendNameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 24)
        friendNameLabel.sizeToFit()
        
        descriptionTextView.autoPinEdge(toSuperviewEdge: .left, withInset: 40)
        descriptionTextView.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        descriptionTextView.autoPinEdge(.top, to: .bottom, of: friendNameLabel)
        descriptionTextView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
    }
    
    @objc func overflowPressed(sender: UIButton!) {
        delegate?.overflowButtonPressed(friend: self.friend!, sender: sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol SelectedGroupFriendCellDelegate: class {
    func overflowButtonPressed(friend: Friend, sender: UIButton)
}
