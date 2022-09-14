//
//  TasksListsTableViewController.swift
//  Realm App
//
//  Created by Apple Macbook Pro 13 on 13.09.22.
//

import UIKit
import RealmSwift

class TasksListsTableViewController: UITableViewController {

    // MARK: IBOutlets
    
    @IBOutlet private weak var segmentControlOutlet: UISegmentedControl!
    
    // MARK: - Properties
    
    var tasksLists: Results<TasksList>!
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tasksLists = StorageManager.getAllTasksLists()
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(alertAddOrUpdateListSelector)
        )
        navigationItem.setRightBarButtonItems([addButton, editButtonItem], animated: true)
    }
    
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        segmentAction(segmentControlOutlet)
    }
    
    // MARK: - Private
    
    @objc private func alertAddOrUpdateListSelector() {
        alertAddOrUpdateList { [weak self] in
            self?.navigationItem.title = "alertForAddAndUpdatesListTasks"
            print("ListTasks")
        }
    }
    
    private func alertAddOrUpdateList(
        list: TasksList? = nil,
        completion: (@escaping () -> Void)
    ) {
        let title = list == nil ? "Add list" : "Update list"
        let message = "Please write title"
        let doneButtonTitle = list == nil ? "Add" : "Update"

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        var alertTextField: UITextField?
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        let action = UIAlertAction(title: doneButtonTitle, style: .default) { [weak self] _ in
            guard
                let textField = alertTextField,
                let text = textField.text,
                !text.isEmpty,
                let self = self
            else {
                return
            }
            
            if let list = list {
                StorageManager.editTasksList(oldList: list, newTitle: text, completion: completion)
            } else {
                let tasksList = TasksList()
                tasksList.name = text
                StorageManager.addNewTaskList(taskList: tasksList)
                self.segmentAction(self.segmentControlOutlet)
            }
        }
        
        alert.addTextField { textField in
            alertTextField = textField
            if let list = list {
                alertTextField?.text = list.name
            }
            textField.placeholder = "tasks list"
        }

        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction private func segmentAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
        } else {
            tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let list = tasksLists[indexPath.row]

        let notDoneTasks = list.tasks.filter { task in
            task.isComplete == false
        }.count
        
        cell.textLabel?.text = list.name
        cell.accessoryType = notDoneTasks >= 1 ? .none : .checkmark
        cell.detailTextLabel?.text = notDoneTasks >= 1 ? notDoneTasks.description : ""

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let currentList = tasksLists[indexPath.row]
        
        let delete = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { _, _, _ in
            StorageManager.removeTasksList(tasksList: currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let edit = UIContextualAction(
            style: .destructive,
            title: "Edit"
        ) { _, _, _ in
            self.alertAddOrUpdateList(list: currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let done = UIContextualAction(
            style: .destructive,
            title: "Done"
        ) { _, _, _ in
            StorageManager.doneTasksList(tasksList: currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        done.backgroundColor = .green
        edit.backgroundColor = .orange
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit, done])
        return swipe
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            let tasksTVC = segue.destination as? TasksTableViewController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            tasksTVC.taskList = tasksLists[indexPath.row]
        }
    }
}
