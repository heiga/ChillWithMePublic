//
//  ColoredSelectTableView.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-10-30.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit

class ColoredSelectTableViewController: UITableViewController {
    
    var selectedStrings: NSMutableSet?
    var tupleArray: [(displayName: String, color: String, stringToSend: String)]
    var isMultiSelect: Bool
    var navigationTitle: String
    var currentSelectedIndexPath: IndexPath?
    
    init(title: String, tupleArray: [(displayName: String, color: String, stringToSend: String)], isMultiSelect: Bool) {
        self.tupleArray = tupleArray
        self.navigationTitle = title
        self.isMultiSelect = isMultiSelect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.navigationTitle
        self.view.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsMultipleSelection = self.isMultiSelect
        
        // REQUIRED FOR IPAD
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tupleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.backgroundGray
        cell.selectionStyle = .none
        cell.tintColor = UIColor.white
        
        let currentItem = tupleArray[row]
        let title = currentItem.displayName
        let color = currentItem.color
        let stringToSend = currentItem.stringToSend

        var nameAttributes = [NSAttributedStringKey: Any]()
            nameAttributes[.foregroundColor] = BasicController.hexToUIColor(color: color)
        
        cell.textLabel?.attributedText = NSAttributedString(string: title, attributes: nameAttributes)

        if let selectedStrings = selectedStrings {
            if selectedStrings.contains(stringToSend) == true {
                cell.accessoryType = .checkmark
                if isMultiSelect == false {
                    currentSelectedIndexPath = indexPath
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dealWithCell(tableView: tableView, indexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        dealWithCell(tableView: tableView, indexPath: indexPath)
    }
    
    // Mark: My Function
    
    func dealWithCell(tableView: UITableView, indexPath: IndexPath) {
        let stringInQuestion = tupleArray[indexPath.row].stringToSend
        
        if isMultiSelect == false {
            if (selectedStrings?.count)! > 0 {
                selectedStrings?.removeAllObjects()
                
                if let current = currentSelectedIndexPath {
                    if let cell = tableView.cellForRow(at: current) {
                        cell.accessoryType = .none
                    }
                }
            }
            if let cell = tableView.cellForRow(at: indexPath) {
                selectedStrings?.add(stringInQuestion)
                cell.accessoryType = .checkmark
                currentSelectedIndexPath = indexPath
            }
            
        } else {
            if selectedStrings?.contains(stringInQuestion) == false {
                selectedStrings?.add(stringInQuestion)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                }
            } else {
                selectedStrings?.remove(stringInQuestion)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .none
                }
            }
        }
    }
}
