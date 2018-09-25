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
    
    var context: NSManagedObjectContext!

    lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        // get Activity that are not complete or (reference with no project).
        fetchRequest.predicate = NSPredicate(format: "(completed != YES) OR ((project == NULL) AND (kind == \(Activity.Kind.reference.rawValue)))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    
    // MARK: - Initializers
    
    init(managedObjectContext context: NSManagedObjectContext) {
        self.context = context
    }

    
    // MARK: - Adaptors
    
    var sections: [NSFetchedResultsSectionInfo]? {
        return fetchedResultsController.sections
    }

    var fetchedObjects: [Activity]? {
        return fetchedResultsController.fetchedObjects
    }
    
    var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? {
        get {
            return fetchedResultsController.delegate
        }
        set {
            fetchedResultsController.delegate = newValue
        }
    }

    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    func object(at indexPath: IndexPath) -> Activity {
        return fetchedResultsController.object(at: indexPath)
    }
}
