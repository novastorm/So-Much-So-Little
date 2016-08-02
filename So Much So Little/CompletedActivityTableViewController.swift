//
//  CompletedActivityTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class CompletedActivityTableViewController: UITableViewController {
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var snapshot: UIView!
    var moveIndexPathSource: NSIndexPath!
    
    
    // Mark: - Core Data Utilities
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = Activity.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "(completed == YES) AND (typeValue != \(ActivityType.Reference.rawValue))") 
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.CompletedDate, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    func saveSharedContext() {
        CoreDataStackManager.saveMainContext()
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
    }
    
    
    // MARK: - Actions
    
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCompletedActivityDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destinationViewController as! ActivityDetailViewController
            
            destinationVC.activity = fetchedResultsController.objectAtIndexPath(indexPath) as? Activity
        }
    }
}


// MARK: - Table View Data Source

extension CompletedActivityTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo =  fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "CompletedActivityCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier)!
        
        configureActivityCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureActivityCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let activity = fetchedResultsController.objectAtIndexPath(indexPath) as! Activity
        let task = activity.task
        let actualTimeboxes = activity.actual_timeboxes
        let estimatedTimeboxes = activity.estimated_timeboxes
        
        cell.textLabel!.text = "\(task)"
        cell.detailTextLabel!.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
}


// MARK: - Table View Delegate

extension CompletedActivityTableViewController {
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let activity = fetchedResultsController.objectAtIndexPath(indexPath) as! Activity
        
        var todayOption: UITableViewRowAction!
        var completedOption: UITableViewRowAction!
        
        if activity.today {
            todayOption = UITableViewRowAction(style: .Normal, title: "Postpone") { (action, activityIndexPath) in
                print("\(activityIndexPath.row): Postpone tapped")
            }
        }
        else {
            todayOption = UITableViewRowAction(style: .Normal, title: "Today") { (action, activityIndexPath) in
                print("\(activityIndexPath.row): Today tapped")
            }
        }
        
        if activity.completed {
            completedOption = UITableViewRowAction(style: .Normal, title: "Reactivate") { (action, completedIndexPath) in
                print("\(completedIndexPath.row): Reactivate tapped")
            }
        }
        else {
            completedOption = UITableViewRowAction(style: .Normal, title: "Complete") { (action, completedIndexPath) in
                print("\(completedIndexPath.row): Complete tapped")
            }
        }
        
        return [todayOption, completedOption]
    }
}


// MARK: - Fetched Results Controller Delegate

extension CompletedActivityTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Move:
            updatedIndexPaths.append(newIndexPath!)
            updatedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: .Fade)
        tableView.deleteRowsAtIndexPaths(deletedIndexPaths, withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths(updatedIndexPaths, withRowAnimation: .Automatic)
        
        tableView.endUpdates()
    }
}
