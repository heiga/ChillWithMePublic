//
//  Colors.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-24.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

extension UIColor {
    static let backgroundGray = BasicController.hexToUIColor(color: "#404040")
    static let darkGray = BasicController.hexToUIColor(color: "#202020")
    static let barBlue = BasicController.hexToUIColor(color: "#22bbee")
    static let buttonColor = BasicController.hexToUIColor(color: "#0099cc")
    static let defaultButton = BasicController.hexToUIColor(color: "#5a595b")
    
    static let redString = "#FF4444"
    static let textRed = BasicController.hexToUIColor(color: redString)
    static let pinkString = "#f05c94"
    static let textPink = BasicController.hexToUIColor(color: pinkString)
    static let purpleString = "#ce6ddf"
    static let textPurple = BasicController.hexToUIColor(color: purpleString)
    static let deepPurpleString = "#986ce0"
    static let textDeepPurple = BasicController.hexToUIColor(color: deepPurpleString)
    static let indigoString = "#7985d2"
    static let textIndigo = BasicController.hexToUIColor(color: indigoString)
    static let blueString = "#1093f5"
    static let textBlue = BasicController.hexToUIColor(color: blueString)
    static let lightBlueString = "#00a6f6"
    static let textLightBlue = BasicController.hexToUIColor(color: lightBlueString)
    static let cyanString = "#00bbd5"
    static let textCyan = BasicController.hexToUIColor(color: cyanString)
    static let tealString = "#009687"
    static let textTeal = BasicController.hexToUIColor(color: tealString)
    static let greenString = "#46af4a"
    static let textGreen = BasicController.hexToUIColor(color: greenString)
    static let lightGreenString = "#88c440"
    static let textLightGreen = BasicController.hexToUIColor(color: lightGreenString)
    static let limeString = "#ccdd1e"
    static let textLime = BasicController.hexToUIColor(color: limeString)
    static let yellowString = "#ffec16"
    static let textYellow = BasicController.hexToUIColor(color: yellowString)
    static let amberString = "#ffc100"
    static let textAmber = BasicController.hexToUIColor(color: amberString)
    static let orangeString = "#ff9800"
    static let textOrange = BasicController.hexToUIColor(color: orangeString)
    static let deepOrangeString = "#ff7433"
    static let textDeepOrange = BasicController.hexToUIColor(color: deepOrangeString)
    static let brownString = "#9c7769"
    static let textBrown = BasicController.hexToUIColor(color: brownString)
    static let grayString = "#9d9d9d"
    static let textGray = BasicController.hexToUIColor(color: grayString)
    static let blueGrayString = "#7684a2"
    static let textBlueGray = BasicController.hexToUIColor(color: blueGrayString)
    static let whiteString = "#FFFFFF"
    
    // display name, color string, string to send
    static let colorPickerTupleArray = [
        ("Red", redString, redString),
        ("Pink", pinkString, pinkString),
        ("Purple", purpleString, purpleString),
        ("Deep Purple", deepPurpleString, deepPurpleString),
        ("Indigo", indigoString, indigoString),
        ("Blue", blueString, blueString),
        ("Light Blue", lightBlueString, lightBlueString),
        ("Cyan", cyanString, cyanString),
        ("Teal", tealString, tealString),
        ("Green", greenString, greenString),
        ("Light Green", lightGreenString, lightGreenString),
        ("Lime", limeString, limeString),
        ("Yellow", yellowString, yellowString),
        ("Amber", amberString, amberString),
        ("Orange", orangeString, orangeString),
        ("Deep Orange", deepOrangeString, deepOrangeString),
        ("Brown", brownString, brownString),
        ("Gray", grayString, grayString),
        ("Blue Gray", blueGrayString, blueGrayString),
        ("White", whiteString, whiteString)
        ]
}
