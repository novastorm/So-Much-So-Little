//
//  ActivityDataSource_v1.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class ActivityDataSource_v1: NSObject, ActivityDataSource {

    // MARK: - Properties
    
    var coreDataStack: CoreDataStack!
    var cloudKitClient: CloudKitClient!
    
    var context: NSManagedObjectContext {
        return coreDataStack.mainContext
    }

    lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        // get Activity that are not complete or (reference with no project).
        fetchRequest.predicate = NSPredicate(format: "(completed != YES) OR ((project == NULL) AND (kind == \(Activity.Kind.reference.rawValue)))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    
    // MARK: - Initializers
    
    init(
        coreDataStack: CoreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack,
        cloudKitClient: CloudKitClient = (UIApplication.shared.delegate as! AppDelegate).cloudKitClient
    ) {
        self.coreDataStack = coreDataStack
        self.cloudKitClient = cloudKitClient
    }

    
    // MARK: - Methods
    
    func objects() -> [Activity] {
        try! fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func store(with options: ActivityOptions) -> Activity {
        let activity = Activity(insertInto: context, with: options)
        // save
        return activity
    }
    
    func update(_ activity: Activity) {
        // update
        // save
    }
    
    func destroy(_ activity: Activity) {
        // delete
        // save
    }
}
