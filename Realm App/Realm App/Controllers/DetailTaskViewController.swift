//
//  DetailTaskViewController.swift
//  Realm App
//
//  Created by Apple Macbook Pro 13 on 16.09.22.
//

import UIKit

class DetailTaskViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var taskTitleLabel: UILabel!
    @IBOutlet private weak var taskNoteLabel: UILabel!
    @IBOutlet private weak var taskDateLabel: UILabel!
    @IBOutlet private weak var completeSegmentControl: UISegmentedControl!
    
    // MARK: - Properties
    
    var delegate: UpdateTask?
    var task: Task?
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fillTaskData()
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTask))
        navigationItem.rightBarButtonItem = edit
    }

    // MARK: - IBActions
    
    @IBAction func completeSegmentAction() {
        guard
            let delegate = delegate,
            let task = task
        else {
            return
        }

        let isComplete = completeSegmentControl.selectedSegmentIndex == 0
        StorageManager.completeTask(task: task, isComplete: isComplete)
        fillTaskData()
        delegate.updateTask()
    }
    
    // MARK: - Private
    
    private func fillTaskData() {
        if let task = task {
            taskTitleLabel.text = task.name
            taskNoteLabel.text = task.note
            taskDateLabel.text = task.date.description
            completeSegmentControl.selectedSegmentIndex = task.isComplete ? 0 : 1
        }
    }
    
    @objc private func editTask() {
        guard
            let task = task,
            let delegate = delegate
        else {
            return
        }
        
        let alert = UIAlertController(
            title: "Edit task",
            message: "Write new task name and note",
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        let action = UIAlertAction(title: "Update", style: .default) { [weak self]_ in
            guard let nameTextField = alert.textFields?.first,
                  let nameText = nameTextField.text,
                  let noteTextField = alert.textFields?[1],
                  let noteText = noteTextField.text,
                  !nameText.isEmpty,
                  !noteText.isEmpty
            else {
                return
            }
            
            StorageManager.editTask(oldTask: task, newTitle: nameText, newNote: noteText) {
                
            }
            self?.fillTaskData()
            delegate.updateTask()
        }
        
        alert.addTextField { textField in
            textField.text = task.name
            textField.placeholder = "task name"
        }
        
        alert.addTextField { textField in
            textField.text = task.note
            textField.placeholder = "task note"
        }
        
        alert.addAction(cancel)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}
