//
//  ActivityTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class ActivityTableViewController: UITableViewController {
    
    var insertedIndexPaths = [IndexPath]()
    var deletedIndexPaths = [IndexPath]()
    var updatedIndexPaths = [IndexPath]()
    
    var snapshot: UIView!
    var moveIndexPathSource: IndexPath!
    
    
    // Mark: - Core Data Utilities
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = Activity.fetchRequest()
        // get Activity that are not complete or (reference with no project).
        fetchRequest.predicate = NSPredicate(format: "(completed != YES) OR ((project == NULL) AND (kind == \(Activity.Kind.reference.rawValue)))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    var mainContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    func saveMainContext() {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.title = "Activity"
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createActivity))
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destination as! ActivityDetailFormViewController
            
            destinationVC.activity = fetchedResultsController.object(at: indexPath) as! Activity
        }
    }
    
    
    // MARK: - Actions
    
    func longPressGestureRecognized(_ sender: AnyObject) {
        
        // retrieve longPress details and target indexPath
        let longPress = sender as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let location = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)
        
        // generate snapshot of target row
        
        switch state {
        case .began:
            if indexPath == nil { break }
            
//            activityList = fetchedResultsController.fetchedObjects as! [Activity]
            moveIndexPathSource = indexPath
            
            let cell = tableView.cellForRow(at: moveIndexPathSource)!
            
            snapshot = customSnapshotFromView(cell)
            
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 0.0
            tableView.addSubview(snapshot)
            
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    center.y = location.y
                    self.snapshot.center = center
                    self.snapshot.alpha = 0.75
                    
                    cell.alpha = 0.0
                },
                completion: { (finished) in
                    cell.isHidden = true
                }
            )
        case .changed:
            var center = snapshot.center
            var activityList = fetchedResultsController.fetchedObjects as! [Activity]
            center.y = location.y
            snapshot.center = center
            
            guard let indexPath = indexPath , indexPath != moveIndexPathSource else { break }
            
            tableView.moveRow(at: moveIndexPathSource, to: indexPath)
            
            let src = moveIndexPathSource.row
            let dst = (indexPath as NSIndexPath).row
            (activityList[dst].display_order, activityList[src].display_order) = (activityList[src].display_order, activityList[dst].display_order)
            
            moveIndexPathSource = indexPath
        default:
            let cell = tableView.cellForRow(at: moveIndexPathSource)!
            cell.isHidden = false
            cell.alpha = 0.0
            
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.snapshot.center = cell.center
                    self.snapshot.alpha = 0.0
                    
                    cell.alpha = 1.0
                }, completion: { (finished) in
                    self.moveIndexPathSource = nil
                    self.snapshot.removeFromSuperview()
                    self.snapshot = nil
            })
        }
    }
    
    func createActivity() {
        performSegue(withIdentifier: "CreateActivityDetail", sender: self)
    }
}


// MARK: - Table View Data Source

extension ActivityTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ActivityCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        configureActivityCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureActivityCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let activity = fetchedResultsController.object(at: indexPath) as! Activity
        let displayOrder = activity.display_order
        let task = activity.task
        let actualTimeboxes = activity.actual_timeboxes
        let estimatedTimeboxes = activity.estimated_timeboxes
        
        cell.textLabel!.text = "\(displayOrder): \(task)"
        cell.detailTextLabel!.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
}


// MARK: - Table View Delegate

extension ActivityTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let activity = fetchedResultsController.object(at: indexPath) as! Activity

        if activity.kind == .reference {
            let referenceOption = UITableViewRowAction(style: .normal, title: "Project") { (action, activityIndexPath) in
                print("Project tapped")
            }
            return [referenceOption]
        }
        
        var todayOption: UITableViewRowAction!
        var completedOption: UITableViewRowAction!
        
        if activity.today {
            todayOption = UITableViewRowAction(style: .normal, title: "Postpone") { (action, activityIndexPath) in
                print("\((activityIndexPath as NSIndexPath).row): Postpone tapped")
                activity.today = false
                activity.today_display_order = 0
                activity.display_order = 0
                self.saveMainContext()
            }
        }
        else {
            todayOption = UITableViewRowAction(style: .normal, title: "Today") { (action, activityIndexPath) in
                print("\((activityIndexPath as NSIndexPath).row): Today tapped")
                activity.today = true
                activity.today_display_order = 0
                self.saveMainContext()
            }
        }
        
        if activity.completed {
            completedOption = UITableViewRowAction(style: .normal, title: "Reactivate") { (action, completedIndexPath) in
                print("\((completedIndexPath as NSIndexPath).row): Reactivate tapped")
                activity.completed = false
                activity.display_order = 0
                self.saveMainContext()
            }
        }
        else {
            completedOption = UITableViewRowAction(style: .normal, title: "Complete") { (action, completedIndexPath) in
                print("\((completedIndexPath as NSIndexPath).row): Complete tapped")
                activity.completed = true
                activity.display_order = 0
                activity.today = false
                activity.today_display_order = 0
                self.saveMainContext()
            }
        }
        
        return [todayOption, completedOption]
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("move row")
    }
}


// MARK: - Fetched Results Controller Delegate

extension ActivityTableViewController: NSFetchedResultsControllerDelegate {
    
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
        
        let activityList = fetchedResultsController.fetchedObjects as! [Activity]
        
        for (i, record) in activityList.enumerated() {
            if record.display_order != NSNumber(value: i) {
                record.display_order = NSNumber(value: i)
            }
        }

        performUIUpdatesOnMain {
            self.saveMainContext()
        }
    }
}


// MARK: - Helpers

extension ActivityTableViewController {
    func customSnapshotFromView(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
}
