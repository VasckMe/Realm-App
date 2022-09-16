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
    
    var notificationToken: NotificationToken?
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
        addTasksListsObserver()
    }
    
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        segmentAction(segmentControlOutlet)
    }
    
    // MARK: - Private
    
    @objc private func alertAddOrUpdateListSelector() {
        alertAddOrUpdateList()
    }
    
    private func alertAddOrUpdateList(list: TasksList? = nil) {
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
        let action = UIAlertAction(title: doneButtonTitle, style: .default) { _ in
            guard
                let textField = alertTextField,
                let text = textField.text,
                !text.isEmpty
            else {
                return
            }
            
            if let list = list {
                StorageManager.editTasksList(oldList: list, newTitle: text)
            } else {
                let tasksList = TasksList()
                tasksList.name = text
                StorageManager.addNewTaskList(taskList: tasksList)
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
        cell.configureList(list: list)

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
        }
        
        let edit = UIContextualAction(
            style: .destructive,
            title: "Edit"
        ) { _, _, _ in
            self.alertAddOrUpdateList(list: currentList)
        }
        
        let done = UIContextualAction(
            style: .destructive,
            title: "Done"
        ) { _, _, _ in
            StorageManager.doneTasksList(tasksList: currentList)
        }
        
        done.backgroundColor = .green
        edit.backgroundColor = .orange
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit, done])
        return swipe
    }
    
    private func addTasksListsObserver() {
        notificationToken = tasksLists.observe {[weak self] change in
            guard let self = self else { return }
            switch change {
            case .initial(_):
                print("Initial change")
            case .update(_, let deletions, let insertions, let modifications):
                if !deletions.isEmpty {
                    var indexPaths = [IndexPath]()
                    for row in deletions {
                        indexPaths.append(IndexPath(row: row, section: 0))
                    }
                    self.tableView.deleteRows(at: indexPaths, with: .fade)
                    self.segmentAction(self.segmentControlOutlet)
                }
                if !insertions.isEmpty {
                    var indexPaths = [IndexPath]()
                    for row in insertions {
                        indexPaths.append(IndexPath(row: row, section: 0))
                    }
                    self.tableView.insertRows(at: indexPaths, with: .fade)
                    self.segmentAction(self.segmentControlOutlet)
                }
                if !modifications.isEmpty {
                    var indexPaths = [IndexPath]()
                    for row in insertions {
                        indexPaths.append(IndexPath(row: row, section: 0))
                    }
                    self.tableView.reloadRows(at: indexPaths, with: .fade)
                    self.segmentAction(self.segmentControlOutlet)
                }
                
            case .error(let error):
                print("error - \(error)")
            }
        }
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
