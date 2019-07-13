//
//  ActivityDataSource_v1.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class ActivityDataSource_v1: ActivityDataSource {
    func numberOfRowsInSection(_ section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Activity {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func save() {
        coreDataStack.saveMainContext()
    }
    
    
    // MARK: - Properties
    var fetchedObjects: [Activity]? {
        return fetchedResultsController.fetchedObjects
    }
    
    // MARK: - Initializers
    
    init(
        coreDataStack: CoreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack,
        cloudKitClient: CloudKitClient = (UIApplication.shared.delegate as! AppDelegate).cloudKitClient
    ) {
        self.coreDataStack = coreDataStack
        self.cloudKitClient = cloudKitClient
    }

    
    // MARK: - Methods
    
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    @discardableResult
    func createActivity(
        with options: ActivityOptions = ActivityOptions()) -> Activity {
        let context = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.mainContext
        return Activity(insertInto: context, with: options)
    }

    // MARK: -
    fileprivate var context: NSManagedObjectContext {
        return coreDataStack.mainContext
    }
    
    fileprivate var coreDataStack: CoreDataStack!
    fileprivate var cloudKitClient: CloudKitClient!
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        // get Activity that are not complete or (reference with no project).
        fetchRequest.predicate = NSPredicate(format: "(completed != YES) OR ((project == NULL) AND (kind == \(Activity.Kind.reference.rawValue)))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
}
