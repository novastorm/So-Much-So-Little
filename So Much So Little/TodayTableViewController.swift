//
//  TodayViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit
import SwiftIcons

class TodayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeBoxTallyLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
}

class TodayTableViewControllerDependencies: NSObject {
    
    var coreDataStack: CoreDataStack!
    
    init(
        coreDataStack: CoreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
        ) {
        self.coreDataStack = coreDataStack
    }
}

@objcMembers
class TodayTableViewController: UITableViewController {
    
    let dependencies: TodayTableViewControllerDependencies!
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var snapshot: UIView!
    var moveIndexPathSource: IndexPath!
    
    
    // MARK: - Core Data Utilities
    
    lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        
        fetchRequest.predicate = NSPredicate(format: "(today == YES) AND (completed != YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.TodayDisplayOrder, ascending: true)]
        
        let fetchedResultsController =  NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    var coreDataStack: CoreDataStack {
        return dependencies.coreDataStack
    }
    
    var mainContext: NSManagedObjectContext {
        return coreDataStack.mainContext
    }

    func saveMainContext() {
        coreDataStack.saveMainContext()
    }
    
    
    // MARK: - View Lifecycle
    
    @objc init?(
        coder aDecoder: NSCoder?,
        dependencies: TodayTableViewControllerDependencies
    ) {
        self.dependencies = dependencies
        if let aDecoder = aDecoder {
            super.init(coder: aDecoder)
        }
        else {
            super.init()
        }
        tabBarItem.setIcon(icon: .fontAwesomeRegular(.calendarMinus), textColor: .lightGray)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(
            coder: aDecoder,
            dependencies: TodayTableViewControllerDependencies()
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem.setIcon(icon: .fontAwesomeRegular(.calendarMinus), textColor: .lightGray, selectedTextColor: self.view.tintColor )

        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self

        try! fetchedResultsController.performFetch()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        
        tableView.addGestureRecognizer(longPress)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "Today"
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    
    // MARK: - Actions
    
    @IBAction func showTimer(_ sender: Any) {
        tabBarController?.dismiss(animated: true, completion: nil)
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

    
    // MARK: - Helpers
    
    @objc func longPressGestureRecognized(_ sender: AnyObject) {
        
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
            // move snapshot
            guard snapshot != nil else { break }
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            
            guard let indexPath = indexPath, indexPath != moveIndexPathSource else { break }
            
            let activityList = fetchedResultsController.fetchedObjects!
            
            tableView.moveRow(at: moveIndexPathSource, to: indexPath)
            
            let src = moveIndexPathSource.row
            let dst = (indexPath as NSIndexPath).row
            (activityList[dst].todayDisplayOrder, activityList[src].todayDisplayOrder) = (activityList[src].todayDisplayOrder, activityList[dst].todayDisplayOrder)

            moveIndexPathSource = indexPath
        case .ended:
            guard moveIndexPathSource != nil else {
                break
            }
            
            let cell = tableView.cellForRow(at: moveIndexPathSource)!

            cell.isHidden = false
            cell.alpha = 0.0
            
            UIView.animate(
                withDuration: 0.25,
                animations: { 
                    self.snapshot.center = cell.center
                    self.snapshot.alpha = 0.0
                    
                    cell.alpha = 1.0
                },
                completion: { (finished) in
                    self.moveIndexPathSource = nil
                    self.snapshot.removeFromSuperview()
                    self.snapshot = nil
                })
                saveMainContext()
        default:
            break
        }
    }
    
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


// MARK: - Table View Data Source

extension TodayTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let activity = fetchedResultsController.object(at: indexPath)
        
        var todayOption: UIContextualAction!
        var completedOption: UIContextualAction!
        
        if activity.today {
            todayOption = UIContextualAction(style: .normal, title: "Postpone") { (action, view, successHandler) in
                print("\(indexPath.row): Postpone tapped")
                activity.today = false
                activity.todayDisplayOrder = 0
                activity.displayOrder = 0
                self.saveMainContext()
            }
        }
        else {
            todayOption = UIContextualAction(style: .normal, title: "Today") { (action, view, successHandler) in
                print("\(indexPath.row): Today tapped")
                activity.today = true
                activity.todayDisplayOrder = 0
                self.saveMainContext()
            }
        }
        
        if activity.completed {
            completedOption = UIContextualAction(style: .normal, title: "Reactivate") { (action, view, successHandler) in
                print("\(indexPath.row): Reactivate tapped")
                activity.completed = false
                activity.displayOrder = 0
                self.saveMainContext()
            }
        }
        else {
            completedOption = UIContextualAction(style: .normal, title: "Complete") { (action, view, successHandler) in
                print("\(indexPath.row): Complete tapped")
                activity.completed = true
                activity.displayOrder = 0
                activity.today = false
                activity.todayDisplayOrder = 0
                self.saveMainContext()
            }
        }
        
        return UISwipeActionsConfiguration(actions: [todayOption, completedOption])
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
        @unknown default:
            fatalError()
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
        
//        saveMainContext()
    }
}
