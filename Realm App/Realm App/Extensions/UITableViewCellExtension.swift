//
//  UITableViewCellExtension.swift
//  Realm App
//
//  Created by Apple Macbook Pro 13 on 16.09.22.
//

import Foundation
import UIKit

extension UITableViewCell {
    func configureList(list: TasksList) {
        let notCompletedTasks = list.tasks.filter("isComplete = false").count
        if list.tasks.count == 0 {
            detailTextLabel?.textColor = .black
            detailTextLabel?.text = "0"
            accessoryType = .none
        } else if notCompletedTasks >= 1 {
            accessoryType = .none
            detailTextLabel?.text = notCompletedTasks.description
            detailTextLabel?.textColor = .red
        } else {
            accessoryType = .checkmark
            detailTextLabel?.text = ""
        }
        textLabel?.text = list.name
    }
}
