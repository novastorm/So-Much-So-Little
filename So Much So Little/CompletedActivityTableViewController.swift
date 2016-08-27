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
    
    enum ProjectSections: Int, CustomStringConvertible {
        case
        Activity,
        Project
        
        static func count() -> Int {
            return ProjectSections.Project.rawValue + 1
        }
        
        var description: String {
            switch self {
            case .Activity:
                return "Activity"
            case .Project:
                return "Project"
            }
        }
    }
    
    // Mark: - Core Data Utilities
    
    lazy var frcActivity: NSFetchedResultsController = {
        let fetchRequest = Activity.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "(completed == YES) AND (kind != \(Activity.Kind.Reference.rawValue))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.CompletedDate, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    lazy var frcProject: NSFetchedResultsController = {
        let fetchRequest = Project.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "completed == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.CompletedDate, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    // lazy var activityFRC
    // lazy var projectFRC
    
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
        
        frcActivity.delegate = self
        
        try! frcActivity.performFetch()
        try! frcProject.performFetch()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    
    // MARK: - Actions
    
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ShowCompletedActivityDetail" :
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destinationViewController as! ActivityDetailFormViewController
            
            destinationVC.activity = frcActivity.objectAtIndexPath(indexPath) as? Activity
        case  "ShowCompletedProjectDetail" :
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destinationViewController as! ProjectDetailFormViewController
            let projectIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            
            destinationVC.project = frcProject.objectAtIndexPath(projectIndexPath) as? Project
        default:
            break
        }
    }
}


// MARK: - Table View Data Source

extension CompletedActivityTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ProjectSections.count()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Completed Section: [\(section)]")
        var count: Int

        switch ProjectSections(rawValue: section)! {
        case .Activity:
            let sectionInfo = frcActivity.sections!.first
            count = sectionInfo!.numberOfObjects
        case .Project:
            let sectionInfo = frcProject.sections!.first
            count = sectionInfo!.numberOfObjects
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ProjectSections(rawValue: section)?.description
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        var cell: UITableViewCell!
        
        switch ProjectSections(rawValue: section)! {
        case .Activity:
            let identifier = "CompletedActivityCell"
            cell = tableView.dequeueReusableCellWithIdentifier(identifier)!
            
            configureActivityCell(cell, atIndexPath: indexPath)
        case .Project:
            let identifier = "CompletedProjectCell"
            cell = tableView.dequeueReusableCellWithIdentifier(identifier)!
            configureProjectCell(cell, atIndexPath: indexPath)
        }
        
        return cell
    }
    
    func configureActivityCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let activity = frcActivity.objectAtIndexPath(indexPath) as! Activity
        let task = activity.task
        let actualTimeboxes = activity.actual_timeboxes
        let estimatedTimeboxes = activity.estimated_timeboxes
        
        cell.textLabel!.text = "\(task)"
        cell.detailTextLabel!.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
    
    func configureProjectCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let projectIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        let project = frcProject.objectAtIndexPath(projectIndexPath) as! Project
        let label = project.label
        let displayOrder = project.display_order
        
        cell.textLabel!.text = "\(displayOrder): \(label)"
    }
}


// MARK: - Table View Delegate

extension CompletedActivityTableViewController {
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print(indexPath)
//    }
//    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let activity = frcActivity.objectAtIndexPath(indexPath) as! Activity
        
        var todayOption: UITableViewRowAction!
        var completedOption: UITableViewRowAction!
        
        if activity.today {
            todayOption = UITableViewRowAction(style: .Normal, title: "Postpone") { (action, activityIndexPath) in
                print("\(activityIndexPath.row): Postpone tapped")
                activity.today = false
                activity.today_display_order = 0
                activity.display_order = 0
                self.saveSharedContext()
            }
        }
        else {
            todayOption = UITableViewRowAction(style: .Normal, title: "Today") { (action, activityIndexPath) in
                print("\(activityIndexPath.row): Today tapped")
                activity.today = true
                activity.today_display_order = 0
                self.saveSharedContext()
            }
        }
        
        if activity.completed {
            completedOption = UITableViewRowAction(style: .Normal, title: "Reactivate") { (action, completedIndexPath) in
                print("\(completedIndexPath.row): Reactivate tapped")
                activity.completed = false
                activity.display_order = 0
                self.saveSharedContext()
            }
        }
        else {
            completedOption = UITableViewRowAction(style: .Normal, title: "Complete") { (action, completedIndexPath) in
                print("\(completedIndexPath.row): Complete tapped")
                activity.completed = true
                activity.display_order = 0
                activity.today = false
                activity.today_display_order = 0
                self.saveSharedContext()
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
        
        saveSharedContext()
    }
}
