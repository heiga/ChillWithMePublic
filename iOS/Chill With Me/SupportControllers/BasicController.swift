//
//  BasicController.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-09-08.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import MaterialComponents.MaterialTextFields

class BasicController {
    
    // https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values
    static func hexToUIColor(color: String) -> UIColor {
        var preparedString = color.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (preparedString.hasPrefix("#")) {
            preparedString.remove(at: preparedString.startIndex)
        }
        if ((preparedString.count) != 6) {
            return UIColor.white
        }
        var rgbValue:UInt32 = 0
        Scanner(string: preparedString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
    static func isThereInternet() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    static func isStringValid(string: String) -> Bool{
        return string.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    static func convertToReadable(numericStringTime: String) -> String {
        var returnString = ""
        if let timeDouble = Double(numericStringTime) {
            let todaysDate = Date.init()
            let inputDate = Date.init(timeIntervalSince1970: timeDouble)
            let calendar = Calendar.current
            let todaysDay = calendar.component(.day, from: todaysDate)
            let inputDay = calendar.component(.day, from: inputDate)
            

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            returnString += dateFormatter.string(from: inputDate)
            
            if todaysDay != inputDay {
                returnString += " tomorrow"
            }
        }
        return returnString
    }
    
    static func standardTextFieldController(placeholderText: String) -> (textField: MDCTextField, controller: MDCTextInputControllerOutlined) {
        let returnTextField = MDCTextField()
        returnTextField.translatesAutoresizingMaskIntoConstraints = false
        let returnController = MDCTextInputControllerOutlined(textInput: returnTextField)
        let white = UIColor.white
        returnController.placeholderText = placeholderText
        returnController.trailingUnderlineLabelTextColor = white
        returnController.floatingPlaceholderActiveColor = white
        returnController.normalColor = white
        returnController.activeColor = white
        returnController.inlinePlaceholderColor = white
        returnController.textInputClearButtonTintColor = white
        returnController.floatingPlaceholderActiveColor = white
        returnController.floatingPlaceholderNormalColor = white
        returnTextField.textColor = white
        return (textField: returnTextField, controller: returnController)
    }
    
    static func standardMultilineTextFieldController(placeholderText: String) -> (textField: MDCMultilineTextField, controller: MDCTextInputControllerOutlinedTextArea) {
        let returnTextField = MDCMultilineTextField()
        returnTextField.translatesAutoresizingMaskIntoConstraints = false
        let returnController = MDCTextInputControllerOutlinedTextArea(textInput: returnTextField)
        let white = UIColor.white
        returnController.placeholderText = placeholderText
        returnController.trailingUnderlineLabelTextColor = white
        returnController.floatingPlaceholderActiveColor = white
        returnController.normalColor = white
        returnController.activeColor = white
        returnController.inlinePlaceholderColor = white
        returnController.textInputClearButtonTintColor = white
        returnController.floatingPlaceholderActiveColor = white
        returnController.floatingPlaceholderNormalColor = white
        returnTextField.textColor = white
        return (textField: returnTextField, controller: returnController)
    }
    
    static func hasTopNotch() -> Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}






























