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
    
    var coreDataStack: CoreDataStack {
        return (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    }

    lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        // get Activity that are not complete or (reference with no project).
        fetchRequest.predicate = NSPredicate(format: "(completed != YES) OR ((project == NULL) AND (kind == \(Activity.Kind.reference.rawValue)))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
//    let mainContext: NSManagedObjectContext!

    // MARK: - Initializers
    
//    init(managedObjectContext context: NSManagedObjectContext) {
//        mainContext = context
//    }

    // MARK: - Table View Data Source Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ActivityCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        configureActivityCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Helpers
    
    func configureActivityCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let activity = fetchedResultsController.object(at: indexPath)
        let displayOrder = activity.displayOrder
        let name = activity.name
        let actualTimeboxes = activity.actualTimeboxes
        let estimatedTimeboxes = activity.estimatedTimeboxes
        
        cell.textLabel!.text = "\(displayOrder): \(name)"
        cell.detailTextLabel!.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
    
    // MARK: - Adaptors

    var fetchedObjects: [Activity]? {
        return fetchedResultsController.fetchedObjects
    }
    
    var delegate: NSFetchedResultsControllerDelegate? {
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
    
    func saveMainContext() {
        coreDataStack.saveMainContext()
    }
}
