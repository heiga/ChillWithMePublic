//
//  FriendRequestCell.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-24.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

class FriendRequestCell: UITableViewCell {
    
    var requestName: String?
    weak var delegate: FriendRequestCellDelegate?
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, requestName: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.requestName = requestName
        
        // setup view
        self.backgroundColor = UIColor.backgroundGray
        
        let nameLabel = UILabel()
        nameLabel.font = nameLabel.font.withSize(16)
        nameLabel.textColor = UIColor.white
        
        let acceptButton = RoundButton()
        acceptButton.cornerRadius = 8
        acceptButton.setTitle("Accept", for: UIControlState.normal)
        acceptButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        acceptButton.borderColor = UIColor.white
        acceptButton.borderWidth = 1
        acceptButton.backgroundColor = UIColor.buttonColor
        acceptButton.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        acceptButton.addTarget(self, action: #selector(acceptButtonPressed(sender:)), for: .touchUpInside)
        
        let deleteButton = RoundButton()
        deleteButton.cornerRadius = 8
        deleteButton.setTitle("Delete", for: UIControlState.normal)
        deleteButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        deleteButton.borderColor = UIColor.white
        deleteButton.borderWidth = 1
        deleteButton.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed(sender:)), for: .touchUpInside)
        
        if let requestName = requestName {
            nameLabel.text = requestName
        }
        
        self.addSubview(nameLabel)
        self.addSubview(acceptButton)
        self.addSubview(deleteButton)
        
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        nameLabel.autoPinEdge(.right, to: .left, of: acceptButton, withOffset: -4)
        
        deleteButton.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        deleteButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        deleteButton.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        
        acceptButton.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        acceptButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        acceptButton.autoPinEdge(.right, to: .left, of: deleteButton, withOffset: -8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func acceptButtonPressed(sender: UIButton!) {
        delegate?.friendAcceptPressed(username: self.requestName!)
    }
    
    @objc func deleteButtonPressed(sender: UIButton!) {
        delegate?.friendDeletePressed(username: self.requestName!)
    }
}

protocol FriendRequestCellDelegate : class {
    func friendAcceptPressed(username: String)
    func friendDeletePressed(username: String)
}
