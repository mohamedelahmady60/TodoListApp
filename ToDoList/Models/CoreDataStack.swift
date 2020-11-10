//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Mo Elahmady on 11/9/20.
//  Copyright © 2020 Mo Elahmady. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //this is the context that we will be using it to CRUD our data
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
