//
//  RealmManager.swift
//  Realm App
//
//  Created by Apple Macbook Pro 13 on 13.09.22.
//

import Foundation
import RealmSwift

let realm = try! Realm()

final class StorageManager {
    
    static func addNewTaskList(taskList: TasksList) {
        do {
            try realm.write {
                realm.add(taskList)
            }
        } catch {
            print("Adding error - \(error)")
        }
    }
    
    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self).sorted(byKeyPath: "name")
    }
    
    static func removeTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                let tasks = tasksList.tasks
                realm.delete(tasks)
                realm.delete(tasksList)
            }
        } catch {
            print("Delete error - \(error)")
        }
    }
    
    static func editTasksList(
        oldList: TasksList,
        newTitle: String,
        completion: @escaping () -> Void
    ) {
        do {
            try realm.write {
                oldList.name = newTitle
                completion()
            }
        } catch {
            print("Edit error - \(error)")
        }
    }
    
    static func doneTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                tasksList.tasks.setValue(true, forKey: "isComplete")
            }
        } catch {
            print("Done error - \(error)")
        }
    }
    
}
