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
    
    var snapshot: UIView!
    var activityList: [Activity]!
    var moveIndexPathSource: NSIndexPath!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = Activity.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "(today == YES) AND (completed != YES) AND (typeValue != \(ActivityType.Reference.rawValue))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.TodayDisplayOrder, ascending: true)]
        
        let fetchedResultsController =  NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func saveSharedContext() {
        CoreDataStackManager.saveMainContext()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self

        try! fetchedResultsController.performFetch()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        
        tableView.addGestureRecognizer(longPress)
    }
    
    
    // MARK: - Actions
    
    @IBAction func longPressGestureRecognized(sender: AnyObject) {
        
        // retrieve longPress details and target indexPath
        let longPress = sender as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let location = longPress.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(location)
        
        // generate snapshot of target row
        
        switch state {
        case .Began:
            if indexPath == nil { break }
            
            activityList = fetchedResultsController.fetchedObjects as! [Activity]
            moveIndexPathSource = indexPath
            
            let cell = tableView.cellForRowAtIndexPath(moveIndexPathSource)!
            
            snapshot = customSnapshotFromView(cell)
            
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 0.0
            tableView.addSubview(snapshot)
            
            UIView.animateWithDuration(
                0.25,
                animations: {
                    center.y = location.y
                    self.snapshot.center = center
                    self.snapshot.alpha = 0.75
                    
                    cell.alpha = 0.0
                },
                completion: { (finished) in
                    cell.hidden = true
                }
            )
        case .Changed:
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            
            guard let indexPath = indexPath where indexPath != moveIndexPathSource else { break }
            
            tableView.moveRowAtIndexPath(moveIndexPathSource, toIndexPath: indexPath)
            
            let src = moveIndexPathSource.row
            let dst = indexPath.row
            (activityList[dst], activityList[src]) = (activityList[src], activityList[dst])

            moveIndexPathSource = indexPath
        default:
            let cell = tableView.cellForRowAtIndexPath(moveIndexPathSource)!
            cell.hidden = false
            cell.alpha = 0.0
            
            UIView.animateWithDuration(
                0.25,
                animations: { 
                    self.snapshot.center = cell.center
                    self.snapshot.alpha = 0.0
                    
                    cell.alpha = 1.0
                }, completion: { (finished) in
                    self.moveIndexPathSource = nil
                    self.snapshot.removeFromSuperview()
                    self.snapshot = nil
            })
            
            
            for (i, record) in activityList.enumerate() {
                if record.today_display_order != i {
                    record.today_display_order = i
                }
            }

            saveSharedContext()
        }
    }
    
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTodayActivityDetail" {
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
        let todayDisplayOrder = activity.today_display_order
        let task = activity.task
        let actualTimeboxes = activity.actual_timeboxes
        let estimatedTimeboxes = activity.estimated_timeboxes
        
        cell.taskLabel.text = "\(todayDisplayOrder): \(task)"
        cell.timeBoxTallyLabel.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
}


// MARK: - Table View Delegate

extension TodayTableViewController {
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

extension TodayTableViewController: NSFetchedResultsControllerDelegate {
    
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


// MARK: - Helpers

extension TodayTableViewController {
    func customSnapshotFromView(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
}