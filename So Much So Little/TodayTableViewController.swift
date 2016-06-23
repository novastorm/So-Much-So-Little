//
//  TodayViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class TodayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeBoxTallyLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
}

class TodayTableViewController: UITableViewController {
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.mainContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = Activity.fetchRequest
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController =  NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance.saveMainContext()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self

        try! fetchedResultsController.performFetch()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saveContext), name: CoreDataStackNotifications.ImportingTaskDidFinish.rawValue, object: nil)
    }
    
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowActivityDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destinationViewController as! ActivityDetailViewController
            
            destinationVC.activity = fetchedResultsController.objectAtIndexPath(indexPath) as? Activity
        }
    }
}


// MARK: - Table View Data Source

extension TodayTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo =  fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "TodayCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! TodayTableViewCell
        
        configureTodayCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureTodayCell(cell: TodayTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let activity = fetchedResultsController.objectAtIndexPath(indexPath) as! Activity
        let actualTimeboxes = activity.actual_timeboxes!
        let estimatedTimeboxes = activity.estimated_timeboxes!
        
        cell.taskLabel.text = activity.task
        cell.timeBoxTallyLabel.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
//    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//        let stringToMove = self.reordering
//    }
}


// MARK: - Table View Delegate

extension TodayTableViewController {
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let unlist = UITableViewRowAction(style: .Normal, title: "Unlist") { (action, todayIndexPath) in
            print("\(todayIndexPath.row): Unlist tapped")
        }
        
        let complete = UITableViewRowAction(style: .Normal, title: "Complete") { (action, completeIndexPath) in
            print("\(completeIndexPath.row): Complete tapped")
        }
        
        return [unlist, complete]
    }
}


// MARK: - Fetched Results Controller Delegate

extension TodayTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {

        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        case .Move:
            deletedIndexPaths.append(indexPath!)
            insertedIndexPaths.append(newIndexPath!)
//        default:
//            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {

        tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: .Fade)
        tableView.deleteRowsAtIndexPaths(deletedIndexPaths, withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths(updatedIndexPaths, withRowAnimation: .Automatic)
        
        tableView.endUpdates()
    }
}
