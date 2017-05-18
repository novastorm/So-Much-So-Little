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
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var snapshot: UIView!
    var moveIndexPathSource: IndexPath!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        fetchRequest.predicate = NSPredicate(format: "(today == YES) AND (completed != YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.TodayDisplayOrder, ascending: true)]
        
        let fetchedResultsController =  NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func saveSharedContext() {
        performUIUpdatesOnMain {
            CoreDataStackManager.saveMainContext()
        }
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
        tabBarController?.title = "Today"
        tabBarController?.navigationItem.rightBarButtonItem = nil
        tableView.reloadData()
    }
    
    
    // MARK: - Actions
    
    @IBAction func longPressGestureRecognized(_ sender: AnyObject) {
        
        // retrieve longPress details and target indexPath
        let longPress = sender as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let location = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)
        
        // generate snapshot of target row
        
        switch state {
        case .began:
            if indexPath == nil { break }
            
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
            var activityList = fetchedResultsController.fetchedObjects!

            center.y = location.y
            snapshot.center = center
            
            guard let indexPath = indexPath, indexPath != moveIndexPathSource else { break }
            
            tableView.moveRow(at: moveIndexPathSource, to: indexPath)
            
            let src = moveIndexPathSource.row
            let dst = (indexPath as NSIndexPath).row
            (activityList[dst].displayOrder, activityList[src].displayOrder) = (activityList[src].displayOrder, activityList[dst].displayOrder)

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
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTodayActivityDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destination as! ActivityDetailFormViewController
            
            destinationVC.activity = fetchedResultsController.object(at: indexPath)
        }
    }
}


// MARK: - Table View Data Source

extension TodayTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo =  fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "TodayCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! TodayTableViewCell
        
        configureTodayCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureTodayCell(_ cell: TodayTableViewCell, atIndexPath indexPath: IndexPath) {
        let activity = fetchedResultsController.object(at: indexPath)
        let todayDisplayOrder = activity.todayDisplayOrder 
        let name = activity.name
        let actualTimeboxes = activity.actualTimeboxes
        let estimatedTimeboxes = activity.estimatedTimeboxes
        
        cell.taskLabel.text = "\(todayDisplayOrder): \(name)"
        cell.timeBoxTallyLabel.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
}


// MARK: - Table View Delegate

extension TodayTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let activity = fetchedResultsController.object(at: indexPath)
        
        var todayOption: UITableViewRowAction!
        var completedOption: UITableViewRowAction!
        
        if activity.today {
            todayOption = UITableViewRowAction(style: .normal, title: "Postpone") { (action, activityIndexPath) in
                print("\((activityIndexPath as NSIndexPath).row): Postpone tapped")
                activity.today = false
                activity.todayDisplayOrder = 0
                activity.displayOrder = 0
                self.saveSharedContext()
            }
        }
        else {
            todayOption = UITableViewRowAction(style: .normal, title: "Today") { (action, activityIndexPath) in
                print("\((activityIndexPath as NSIndexPath).row): Today tapped")
                activity.today = true
                activity.todayDisplayOrder = 0
                self.saveSharedContext()
            }
        }
        
        if activity.completed {
            completedOption = UITableViewRowAction(style: .normal, title: "Reactivate") { (action, completedIndexPath) in
                print("\((completedIndexPath as NSIndexPath).row): Reactivate tapped")
                activity.completed = false
                activity.displayOrder = 0
                self.saveSharedContext()
            }
        }
        else {
            completedOption = UITableViewRowAction(style: .normal, title: "Complete") { (action, completedIndexPath) in
                print("\((completedIndexPath as NSIndexPath).row): Complete tapped")
                activity.completed = true
                activity.displayOrder = 0
                activity.today = false
                activity.todayDisplayOrder = 0
                self.saveSharedContext()
            }
        }
        
        return [todayOption, completedOption]
    }
}


// MARK: - Fetched Results Controller Delegate

extension TodayTableViewController: NSFetchedResultsControllerDelegate {
    
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
        
        let activityList = fetchedResultsController.fetchedObjects!
        
        for (i, record) in activityList.enumerated() {
            let i = Activity.TodayDisplayOrderType(i)
            if record.todayDisplayOrder != i {
                record.todayDisplayOrder = i
            }
        }
        
        saveSharedContext()
    }
}


// MARK: - Helpers

extension TodayTableViewController {
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
