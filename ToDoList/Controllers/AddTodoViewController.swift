//
//  AddTodoViewController.swift
//  ToDoList
//
//  Created by Mo Elahmady on 11/6/20.
//  Copyright © 2020 Mo Elahmady. All rights reserved.
//

import UIKit
import CoreData

class AddTodoViewController: UIViewController {
    
    
    //MARK: - Properties
    //this to hold the main context that comes from TodoTableViewController to save data
    var managedContext: NSManagedObjectContext!
    
    //this to hold the current todo item that comes from TodoTableViewController to edit it
    var currentTodoItem: TodoItem?
    //MARK: - Outlets
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var times = 0
    
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //listen for our keyboard notifaction and catch keyboardWillShowNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        //make the text Field starts as a first responder
        textView.becomeFirstResponder()
        
        if let nonOptionalcurrentTodoItem = self.currentTodoItem{
            self.times = 2
            textView.text = nonOptionalcurrentTodoItem.title
            segmentedControl.selectedSegmentIndex = Int(nonOptionalcurrentTodoItem.priority)
        }
    }
    
    
    func resignAndDismiss() {
        textView.resignFirstResponder()
        self.dismiss(animated: true)
    }
    
    
    
    //MARK: - Actions
    //this function is executed when the keyboardWillShowNotification happens
    @objc func keyboardWillShow(with notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            //move the stackiew above the keyboard
            self.bottomConstraint.constant = keyboardHeight
            
            //do some animation
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    //cancel button used to go back to the prevouis TodoTableViewController
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        resignAndDismiss()
    }
    
    @IBAction func segmentControlPressed(_ sender: UISegmentedControl) {
        if doneButton.isHidden == true {
            doneButton.isHidden = false
        }
    }
    
    //done button used to add a new todo item and save it
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        //check that we have title
        guard let todoItemTitle = textView.text, !todoItemTitle.isEmpty else {
            //TODO: make an alert you can't save empty todos
            let alert = UIAlertController(title: "Can't save empty item", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        //check if there is an object to edit it
        if let nonOptionalCurrentTodoItem = self.currentTodoItem {
            nonOptionalCurrentTodoItem.title = todoItemTitle
            nonOptionalCurrentTodoItem.priority = Int16(self.segmentedControl.selectedSegmentIndex)
        } else {
            //create the newTodoItem and save it at the context
            let newTodoItem = TodoItem(context: self.managedContext)
            newTodoItem.title = todoItemTitle
            newTodoItem.priority = Int16(self.segmentedControl.selectedSegmentIndex)
            newTodoItem.date = Date()
        }
        
        //save our context
        do {
            try self.managedContext.save()
            // go back to the previous view
            self.resignAndDismiss()
        } catch {
            print("Error saving TodoItem\(error)")
        }
    }
    
    
    
    
}


//MARK: - text field delegate methods

extension AddTodoViewController : UITextFieldDelegate{
    
    //whenever the textField changes (select it, type a letter or even when it starts responding)
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        self.times  = self.times + 1
        
        if self.times == 2 && doneButton.isHidden == true {
            //remove all the text and change the color
            textView.text?.removeAll()
            textView.textColor = .white
            
            //show the done button by some animation
            doneButton.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
        }
        
        if self.times == 4 && doneButton.isHidden == true {
            //show the done button by some animation
            doneButton.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
        }

    }
}


