//
//  TasksTableViewController.swift
//  Realm App
//
//  Created by Apple Macbook Pro 13 on 13.09.22.
//

import UIKit
import RealmSwift

class TasksTableViewController: UITableViewController {

    // MARK: - Properties
    var notificationTokenForCompletedTasks: NotificationToken?
    var notificationTokenForNotCompletedTasks: NotificationToken?
    var taskList: TasksList?
    var notCompletedTasks: Results<Task>!
    var completedTasks: Results<Task>!
        
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
        title = taskList?.name
        let add = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(alertAddOrEditTaskSelector)
        )
        navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
        addTasksObserver()
    }
    
    
    // MARK: - Private
    
    @objc private func alertAddOrEditTaskSelector() {
        alertAddOrEditTask()
    }
    
    private func alertAddOrEditTask(task: Task? = nil) {
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
                StorageManager.editTask(oldTask: task, newTitle: nameText, newNote: noteText)
            } else {
                let task = Task()
                task.name = nameText
                task.note = noteText
                StorageManager.saveTask(list: list, task: task)
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
    
    private func addTasksObserver() {
        notificationTokenForCompletedTasks = completedTasks.observe{[weak self] change in
            self?.taskObserver(section: 1, change: change)
        }
        notificationTokenForNotCompletedTasks = notCompletedTasks.observe{[weak self] change in
            self?.taskObserver(section: 0, change: change)
        }
    }
    
    private func taskObserver(section: Int, change: RealmCollectionChange<Results<Task>>) {
        switch change {
        case .initial:
            print("Initial case")
        case .update(_, let deletions, let insertions, let modifications):
            if !modifications.isEmpty {
                var indexPaths: [IndexPath] = []
                for row in modifications {
                    indexPaths.append(IndexPath(row: row, section: section))
                }
                loadTasks()
            }
            
            if !deletions.isEmpty {
                var indexPaths: [IndexPath] = []
                for row in deletions {
                    indexPaths.append(IndexPath(row: row, section: section))
                }
                loadTasks()
            }
            
            if !insertions.isEmpty {
                var indexPaths: [IndexPath] = []
                for row in insertions {
                    indexPaths.append(IndexPath(row: row, section: section))
                }
                loadTasks()
            }
            
        case .error(let error):
            print("Observer error - \(error)")
        }
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
        let doneButton = currentTask.isComplete ? "Not done" : "Done"
        let delete = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { _, _, _ in
            StorageManager.removeTask(task: currentTask)
        }
        
        let edit = UIContextualAction(
            style: .destructive,
            title: "Edit"
        ) { _, _, _ in
            self.alertAddOrEditTask(task: currentTask)
        }
        
        let done = UIContextualAction(
            style: .destructive,
            title: doneButton
        ) { _, _, _ in
            StorageManager.makeDone(currentTask)
        }
        
        done.backgroundColor = .green
        edit.backgroundColor = .orange
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit, done])
        return swipe
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Not completed tasks" : "Completed tasks"
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section {
            let task = sourceIndexPath.section == 0
                ? notCompletedTasks[sourceIndexPath.row]
                : completedTasks[sourceIndexPath.row]
            StorageManager.makeDone(task)
            tableView.reloadData()
        }
    }
    
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
        }
    }
}
