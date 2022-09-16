//
//  TasksTableViewController.swift
//  Realm App
//
//  Created by Apple Macbook Pro 13 on 13.09.22.
//

import UIKit
import RealmSwift

protocol UpdateTask {
    func updateTask()
}

class TasksTableViewController: UITableViewController {

    var taskList: TasksList?
    
    var notCompletedTasks: Results<Task>!
    var completedTasks: Results<Task>!
    
//    var tasks: Results<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
        title = "Tasks"
        let add = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(alertAddOrEditTaskSelector)
        )
        navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }
    
    
    // MARK: - Private
    
    @objc private func alertAddOrEditTaskSelector() {
        alertAddOrEditTask {
            
        }
    }
    
    private func alertAddOrEditTask(task: Task? = nil, completion: (@escaping () -> Void)) {
        let title = task == nil ? "Add" : "Update"
        let message = "Write the task"
        let doneButton = task == nil ? "Add" : "Update"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var alertNameTF: UITextField? = nil
        var alertNoteTF: UITextField? = nil
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        let action = UIAlertAction(title: doneButton, style: .default) { [weak self] _ in
            guard
                let nameTextField = alertNameTF,
                let nameText = nameTextField.text,
                let noteTextField = alertNoteTF,
                let noteText = noteTextField.text,
                !noteText.isEmpty,
                !nameText.isEmpty,
                let self = self,
                let list = self.taskList
            else {
                return
            }
            if let task = task {
                StorageManager.editTask(
                    oldTask: task,
                    newTitle: nameText,
                    newNote: noteText,
                    completion: completion
                )
            } else {
                let task = Task()
                task.name = nameText
                task.note = noteText
                StorageManager.saveTask(list: list, task: task)
                self.loadTasks()
            }
        }
        
        alert.addTextField { textField in
            alertNameTF = textField
            if let task = task {
                alertNameTF?.text = task.name
            }
            textField.placeholder = "task title"
        }
        
        alert.addTextField { textField in
            alertNoteTF = textField
            if let task = task {
                alertNoteTF?.text = task.note
            }
            textField.placeholder = "task note"
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
    
    private func loadTasks() {
        if let list = taskList {
            notCompletedTasks = list.tasks.filter("isComplete = false")
            completedTasks = list.tasks.filter("isComplete = true")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? notCompletedTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = indexPath.section == 0
        ? notCompletedTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        cell.accessoryType = task.isComplete ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let currentTask = indexPath.section == 0
        ? notCompletedTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        let delete = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { _, _, _ in
            StorageManager.removeTask(task: currentTask)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let edit = UIContextualAction(
            style: .destructive,
            title: "Edit"
        ) { _, _, _ in
            self.alertAddOrEditTask(task: currentTask) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let done = UIContextualAction(
            style: .destructive,
            title: "Done"
        ) { _, _, _ in
            StorageManager.makeDone(currentTask)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        done.backgroundColor = .green
        edit.backgroundColor = .orange
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit, done])
        return swipe
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Not completed tasks" : "Completed tasks"
    }
    
    // MARK: - Table view delegate
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let task = indexPath.section == 0
//        ? notCompletedTasks[indexPath.row]
//        : completedTasks[indexPath.row]
//
//        StorageManager.makeDone(task)
//        loadTasks()
//    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            let detailTaskVC = segue.destination as? DetailTaskViewController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            let task = indexPath.section == 0
                ? notCompletedTasks[indexPath.row]
                : completedTasks[indexPath.row]
            detailTaskVC.task = task
            detailTaskVC.delegate = self
        }
    }
}

extension TasksTableViewController: UpdateTask {
    func updateTask() {
        tableView.reloadData()
    }
}
