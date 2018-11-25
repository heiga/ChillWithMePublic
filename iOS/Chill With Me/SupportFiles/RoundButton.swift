//
//  RoundButton.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-27.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    static func standardButton(title: String, wide: Bool) -> RoundButton {
        let returnButton = RoundButton()
        returnButton.cornerRadius = 8
        returnButton.setTitle(title, for: .normal)
        returnButton.setTitleColor(UIColor.white, for: .normal)
        returnButton.borderWidth = 1
        returnButton.borderColor = UIColor.gray
        returnButton.backgroundColor = UIColor.defaultButton
        if wide == true {
            returnButton.contentEdgeInsets = UIEdgeInsetsMake(16, 36, 16, 36)
        } else {
            returnButton.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        }
        return returnButton
    }
    
    static func cancelButton() -> RoundButton {
        let button = RoundButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        button.backgroundColor = UIColor.backgroundGray
        return button
    }
}
