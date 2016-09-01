//
//  ProjectTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class ProjectTableViewController: UITableViewController {
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // MARK: - Core Data Utilities
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = Project.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "completed != YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.DisplayOrder, ascending: true)]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    func saveSharedContext() {
        CoreDataStackManager.saveMainContext()
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowProjectDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destinationViewController as! ProjectDetailFormViewController
            
            destinationVC.project = fetchedResultsController.objectAtIndexPath(indexPath) as? Project
        }
    }
}


// MARK: - Table View Data Source

extension ProjectTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "ProjectCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier)!
        
        configureProjectCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureProjectCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let project = fetchedResultsController.objectAtIndexPath(indexPath) as! Project
        let label = project.label
        let displayOrder = project.display_order
        
        cell.textLabel!.text = "\(displayOrder): \(label)"
    }
}


// MARK: - Table View Delegate


// MARK: - Fetched Results Controller Delegate

extension ProjectTableViewController: NSFetchedResultsControllerDelegate {
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
        
        let projectList = fetchedResultsController.fetchedObjects as! [Project]
        
        for (i, record) in projectList.enumerate() {
            if record.display_order != i {
                record.display_order = i
            }
        }
        
        saveSharedContext()
    }
}
