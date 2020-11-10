//
//  TodoTableViewController.swift
//  ToDoList
//
//  Created by Mo Elahmady on 11/6/20.
//  Copyright © 2020 Mo Elahmady. All rights reserved.
//

import UIKit
import CoreData


class TodoTableViewController: UITableViewController {
    
    
    //MARK: - Properties
    var resultsController: NSFetchedResultsController<TodoItem>!
    let coreDataStack = CoreDataStack()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //MARK: - Reload the last saved data
        //create a request to fetch the data
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        //get the data sort accoring to its saved date
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        //add the sortDescriptors to the request
        request.sortDescriptors = [sortDescriptors]
        
        //initialize our result controller
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        //perform the fetch
        do {
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error \(error)")
        }
        
        //Set the delegate to the current class so we can use NSFetchedResultsController
        resultsController.delegate = self
        
        
    }
    
    
    
    //MARK: - Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let registerVC = storyboard?.instantiateViewController(identifier: "AddTodoViewController") as! AddTodoViewController
        //2- pass data if you want
        registerVC.managedContext = coreDataStack.managedContext
        //3- present the required view controller
        present(registerVC, animated: true, completion: nil)
        
    }
    
    
    //MARK: - table view data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        //write the cell title
        let todoItem = resultsController.object(at: indexPath)
        cell.textLabel?.text = todoItem.title        
        return cell
    }
    
    
    
    
    
    //MARK: - table view delegate methods
    //this function used for swipe actions (trailing)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //create the action when trialing swipe
        let action = UIContextualAction(
            style: .destructive,
            title: "Delete") { (action, view, completion) in
                
                //TODO: Delete the object from the core data
                
                //get the current object
                let currentTodoItem = self.resultsController.object(at: indexPath)
                //delete it
                self.resultsController.managedObjectContext.delete(currentTodoItem)
                //save the context
                do {
                    try self.resultsController.managedObjectContext.save()
                    completion(true)
                } catch {
                    print("Error saving the context\(error)")
                    completion(false)
                }
        }
        
        //set image to the swipen action
        action.image = #imageLiteral(resourceName: "trash-2")
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    //this function used for swipe actions (Leading)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //create the action when leading swipe
        //create the action when trialing swipe
        let action = UIContextualAction(
            style: .destructive,
            title: "Edit") { (action, view, completion) in
                
                //TODO: Edit the cell
                
                //get the current object
                let currentTodoItem = self.resultsController.object(at: indexPath)
                
                //we want to move to the second view and pass the currentTodoItem to edit and update it
                let registerVC = self.storyboard?.instantiateViewController(identifier: "AddTodoViewController") as! AddTodoViewController
                //2- pass data if you want
                registerVC.managedContext = self.resultsController.managedObjectContext
                registerVC.currentTodoItem = currentTodoItem
                //3- present the required view controller
                self.present(registerVC, animated: true, completion: nil)
                
                completion(true)
        }
        
        //set image to the swipen action
        action.image = #imageLiteral(resourceName: "check")
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this to remove the highlight from the row when it is selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



//MARK: - NSFetchedResultsControllerDelegate methods
// to use functions that handle the changes (CRUD) in our resultsController
extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    
    //before any changes of our resultsController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // to edit inour table view
        tableView.beginUpdates()
    }
    
    //after the changes of our resultsController
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // after this function the table view will add the new updates that we've done
        tableView.endUpdates()
    }
    
    //this function is executed when our resultsController changes (CRUD)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        //in case a new data has been inserted
        case .insert:
            //we here check on a newIndexPath because we are inside an insert section (new item)
            if let nonOptionalNewIndexPath = newIndexPath {
                //add a new row to our table view
                tableView.insertRows(at: [nonOptionalNewIndexPath], with: .automatic)
            }
        //in case an existing data has been deleted
        case .delete:
            //we here check on a indexPath because we are inside a delete section (exist item)
            if let nonOptionalIndexPath = indexPath {
                //delete an existing row from our table view
                tableView.deleteRows(at: [nonOptionalIndexPath], with: .automatic)
            }
        //in case an existing data has been edited
        case .update:
            //we here check on a indexPath because we are inside a delete section (exist item)
            if let nonOptionalIndexPath = indexPath {
                //get the cell to update it
                if let cell = tableView.cellForRow(at: nonOptionalIndexPath) {
                    //get the updated object
                    let updatedTodoItem = resultsController.object(at: nonOptionalIndexPath)
                    //update the cell data
                    cell.textLabel?.text = updatedTodoItem.title
                }
            }
            
        default:
            break
        }
    }
    
}
