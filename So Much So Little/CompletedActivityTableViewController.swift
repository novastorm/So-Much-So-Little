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
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var snapshot: UIView!
    var moveIndexPathSource: IndexPath!
    
    enum ProjectSections: Int, CustomStringConvertible {
        case
        activity,
        project
        
        static func count() -> Int {
            return ProjectSections.project.rawValue + 1
        }
        
        var description: String {
            switch self {
            case .activity:
                return "Activity"
            case .project:
                return "Project"
            }
        }
    }
    
    // Mark: - Core Data Utilities
    
    lazy var frcActivity: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        fetchRequest.predicate = NSPredicate(format: "(completed == YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.CompletedDate, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    lazy var frcProject: NSFetchedResultsController<Project> = {
        let fetchRequest = Project.fetchRequest() as NSFetchRequest<Project>
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
        performUIUpdatesOnMain {
            CoreDataStackManager.saveMainContext()
        }
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        frcActivity.delegate = self
        
        try! frcActivity.performFetch()
        try! frcProject.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.title = "Completed"
        tabBarController?.navigationItem.rightBarButtonItem = nil
        tableView.reloadData()
    }
    
    
    // MARK: - Actions
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ShowCompletedActivityDetail" :
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destination as! ActivityDetailFormViewController
            
            destinationVC.activity = frcActivity.object(at: indexPath)
        case  "ShowCompletedProjectDetail" :
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destination as! ProjectDetailFormViewController
            let projectIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
            
            destinationVC.project = frcProject.object(at: projectIndexPath)
        default:
            break
        }
    }
}


// MARK: - Table View Data Source

extension CompletedActivityTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ProjectSections.count()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int

        switch ProjectSections(rawValue: section)! {
        case .activity:
            let sectionInfo = frcActivity.sections!.first
            count = sectionInfo!.numberOfObjects
        case .project:
            let sectionInfo = frcProject.sections!.first
            count = sectionInfo!.numberOfObjects
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ProjectSections(rawValue: section)?.description
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as NSIndexPath).section
        var cell: UITableViewCell!
        
        switch ProjectSections(rawValue: section)! {
        case .activity:
            let identifier = "CompletedActivityCell"
            cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            
            configureActivityCell(cell, atIndexPath: indexPath)
        case .project:
            let identifier = "CompletedProjectCell"
            cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            configureProjectCell(cell, atIndexPath: indexPath)
        }
        
        return cell
    }
    
    func configureActivityCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let activity = frcActivity.object(at: indexPath) 
        let name = activity.name
        let actualTimeboxes = activity.actual_timeboxes
        let estimatedTimeboxes = activity.estimated_timeboxes
        
        cell.textLabel!.text = "\(name)"
        cell.detailTextLabel!.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
    
    func configureProjectCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let projectIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        let project = frcProject.object(at: projectIndexPath) 
        let name = project.name
        let displayOrder = project.display_order
        
        cell.textLabel!.text = "\(displayOrder): \(name)"
    }
}


// MARK: - Table View Delegate

extension CompletedActivityTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print(indexPath)
//    }
//    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let activity = frcActivity.object(at: indexPath) 
        
        var todayOption: UITableViewRowAction!
        var completedOption: UITableViewRowAction!
        
        if activity.today {
            todayOption = UITableViewRowAction(style: .normal, title: "Postpone") { (action, activityIndexPath) in
                print("\((activityIndexPath as NSIndexPath).row): Postpone tapped")
                activity.today = false
                activity.today_display_order = 0
                activity.display_order = 0
                self.saveSharedContext()
            }
        }
        else {
            todayOption = UITableViewRowAction(style: .normal, title: "Today") { (action, activityIndexPath) in
                print("\((activityIndexPath as NSIndexPath).row): Today tapped")
                activity.today = true
                activity.today_display_order = 0
                self.saveSharedContext()
            }
        }
        
        if activity.completed {
            completedOption = UITableViewRowAction(style: .normal, title: "Reactivate") { (action, completedIndexPath) in
                print("\((completedIndexPath as NSIndexPath).row): Reactivate tapped")
                activity.completed = false
                activity.display_order = 0
                self.saveSharedContext()
            }
        }
        else {
            completedOption = UITableViewRowAction(style: .normal, title: "Complete") { (action, completedIndexPath) in
                print("\((completedIndexPath as NSIndexPath).row): Complete tapped")
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        case .move:
            updatedIndexPaths.append(newIndexPath!)
            updatedIndexPaths.append(indexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.insertRows(at: insertedIndexPaths, with: .fade)
        tableView.deleteRows(at: deletedIndexPaths, with: .fade)
        tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
        
        tableView.endUpdates()
        
        saveSharedContext()
    }
}
