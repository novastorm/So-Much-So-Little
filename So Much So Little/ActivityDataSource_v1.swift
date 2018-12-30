//
//  ActivityDataSource_v1.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class ActivityDataSource_v1: NSObject, ActivityDataSource, CoreDataDataSource {
    
    static func createActivity(
        with options: ActivityOptions = ActivityOptions()) -> Activity {
        let context = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.mainContext
        return Activity(insertInto: context, with: options)
    }
    
    // MARK: - Properties
    
    var coreDataStack: CoreDataStack!
    var cloudKitClient: CloudKitClient!
    
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
    
    var objects: [Activity]? {
        return fetchedObjects
    }

}
