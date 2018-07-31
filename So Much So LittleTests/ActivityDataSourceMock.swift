//
//  ActivityDataSourceMock.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

@testable import So_Much_So_Little

@objc
class ActivityDataSourceMock: NSObject, ActivityDataSource {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "So_Much_So_Little")
        let description = NSPersistentStoreDescription()
        description.configuration = "Default"
        description.type = NSInMemoryStoreType
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            // empty
        })
        
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var activityObjects: [Int:[Activity]]! = {
        return [
            0: [
                Activity(
                    insertInto: context,
                    with: ActivityOptions(
                        completed: false,
                        completedDate: nil,
                        deferredTo: nil,
                        deferredToResponseDueDate: nil,
                        displayOrder: 0,
                        dueDate: nil,
                        estimatedTimeboxes: 0,
                        info: nil,
                        kind: .flexible,
                        name: "A 1",
                        scheduledEnd: nil,
                        scheduledStart: nil,
                        today: false,
                        todayDisplayOrder: 0
                    )
                ),
                Activity(
                    insertInto: context,
                    with: ActivityOptions(
                        completed: false,
                        completedDate: nil,
                        deferredTo: nil,
                        deferredToResponseDueDate: nil,
                        displayOrder: 1,
                        dueDate: nil,
                        estimatedTimeboxes: 0,
                        info: nil,
                        kind: .flexible,
                        name: "A 2",
                        scheduledEnd: nil,
                        scheduledStart: nil,
                        today: false,
                        todayDisplayOrder: 0
                    )
                )
            ]
        ]
    }()
    
    func saveMainContext() {
        // code
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // code
        return (activityObjects[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    var fetchedObjects: [Activity]? {
        get {
             return activityObjects[0]
        }
    }
    
    var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? {
        get {
            return nil
        }
        set {
            print ("Set Activity NSFetchedResultsControllerDelegate")
        }
        
    }

    func performFetch() throws {
        // code
    }
    
    func object(at indexPath: IndexPath) -> Activity {
        return Activity()
    }
}
