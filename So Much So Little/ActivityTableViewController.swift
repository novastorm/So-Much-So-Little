//
//  ActivityTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit
import FontAwesomeSwift

struct ActivityTableViewControllerDependencies {
    
    var coreDataStack: CoreDataStack!
    
    init(
        coreDataStack: CoreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
        ) {
        self.coreDataStack = coreDataStack
    }
}

class ActivityTableViewController: UITableViewController {
    
    let dependencies: ActivityTableViewControllerDependencies!
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var snapshot: UIView!
    var moveIndexPathSource: IndexPath!
        
    // Mark: - Core Data Utilities
    
    lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest = Activity.fetchRequest() as NSFetchRequest<Activity>
        // get Activity that are not complete or (reference with no project).
        fetchRequest.predicate = NSPredicate(format: "(completed != YES) OR ((project == NULL) AND (kind == \(Activity.Kind.reference.rawValue)))")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]

        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: self.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
    
    init?(coder aDecoder: NSCoder?, dependencies: ActivityTableViewControllerDependencies) {
        self.dependencies = dependencies
        if let aDecoder = aDecoder {
            super.init(coder: aDecoder)
        }
        else {
            super.init()
        }
        tabBarItem.setFAIcon(icon: .FASignLanguage, textColor: .lightGray)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(
            coder: aDecoder,
            dependencies: ActivityTableViewControllerDependencies()
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem.setFAIcon(icon: .FASignLanguage, textColor: .lightGray, selectedTextColor: self.view.tintColor )

        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self

        
        try! fetchedResultsController.performFetch()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        
        tableView.addGestureRecognizer(longPress)
        refreshControl?.addTarget(self, action: #selector(refreshActivityIndexFromRemote(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.title = "Activity"
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createActivity))
        try! fetchedResultsController.performFetch()
        
        tableView.reloadData()
    }
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityDetail" {
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
            guard snapshot != nil else { break }
            // move snapshot
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            
            guard let indexPath = indexPath, indexPath != moveIndexPathSource else { break }

            var activityList = fetchedResultsController.fetchedObjects!

            tableView.moveRow(at: moveIndexPathSource, to: indexPath)
            
            let src = moveIndexPathSource.row
            let dst = (indexPath as NSIndexPath).row
            (activityList[dst].displayOrder, activityList[src].displayOrder) = (activityList[src].displayOrder, activityList[dst].displayOrder)
            
            moveIndexPathSource = indexPath
        case .ended:
            guard moveIndexPathSource != nil else { break }
            
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

    @objc func createActivity() {
        performSegue(withIdentifier: "CreateActivityDetail", sender: self)
    }
    
    @objc private func refreshActivityIndexFromRemote(_ sender: Any) {
        try! self.fetchedResultsController.performFetch()
        performUIUpdatesOnMain {
//            print("\(#function)")
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}


// MARK: - Table View Data Source

extension ActivityTableViewController {
    
//    weak var fetchedResultsController
    
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
        let activity = fetchedResultsController.object(at: indexPath)
        let displayOrder = activity.displayOrder
        let name = activity.name
        let actualTimeboxes = activity.actualTimeboxes
        let estimatedTimeboxes = activity.estimatedTimeboxes
        
        cell.textLabel!.text = "\(displayOrder): \(name)"
        cell.detailTextLabel!.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
}


// MARK: - Table View Delegate

extension ActivityTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let activity = fetchedResultsController.object(at: indexPath)

        if activity.kind == .reference {
            let referenceOption = UITableViewRowAction(style: .normal, title: "Project") { (action, activityIndexPath) in
//                print("Project tapped")
            }
            return [referenceOption]
        }
        
        var todayOption: UITableViewRowAction!
        var completedOption: UITableViewRowAction!
        
        if activity.today {
            todayOption = UITableViewRowAction(style: .normal, title: "Postpone") { (action, activityIndexPath) in
//                print("\((activityIndexPath as NSIndexPath).row): Postpone tapped")
                activity.today = false
                activity.todayDisplayOrder = 0
                activity.displayOrder = 0
                self.saveMainContext()
            }
        }
        else {
            todayOption = UITableViewRowAction(style: .normal, title: "Today") { (action, activityIndexPath) in
//                print("\((activityIndexPath as NSIndexPath).row): Today tapped")
                activity.today = true
                activity.todayDisplayOrder = 0
                self.saveMainContext()
            }
        }
        
        if activity.completed {
            completedOption = UITableViewRowAction(style: .normal, title: "Reactivate") { (action, completedIndexPath) in
//                print("\((completedIndexPath as NSIndexPath).row): Reactivate tapped")
                activity.completed = false
                activity.displayOrder = 0
                self.saveMainContext()
            }
        }
        else {
            completedOption = UITableViewRowAction(style: .normal, title: "Complete") { (action, completedIndexPath) in
                print("\((completedIndexPath as NSIndexPath).row): Complete tapped")
                activity.completed = true
                activity.displayOrder = 0
                activity.today = false
                activity.todayDisplayOrder = 0
                self.saveMainContext()
            }
        }
        
        return [todayOption, completedOption]
    }
}


// MARK: - Fetched Results Controller Delegate

extension ActivityTableViewController: NSFetchedResultsControllerDelegate {
    
//    weak var fetchedResultsController
    
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
            let i = Activity.DisplayOrderType(i)
            if record.displayOrder != i {
                record.displayOrder = i
            }
        }

//        saveMainContext()
    }
}
