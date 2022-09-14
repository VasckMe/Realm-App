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
    
    // MARK: - Tasks Lists
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
    
    // MARK: - Tasks
    
    static func makeDone(_ task: Task) {
        try! realm.write {
            task.isComplete.toggle()
        }
    }
    
    static func removeTask(task: Task) {
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Remove task error - \(error)")
        }
    }
    
    static func saveTask(list: TasksList, task: Task) {
        do {
            try realm.write{
                list.tasks.append(task)
            }
        } catch {
            print("Save task error - \(error)")
        }
    }
    
    static func editTask(
        oldTask: Task,
        newTitle: String,
        newNote: String,
        completion: (@escaping () -> Void)
    ) {
        do {
            try realm.write{
                oldTask.name = newTitle
                oldTask.note = newNote
                completion()
            }
        } catch {
            print("Edit task error - \(error)")
        }
    }
    
}
