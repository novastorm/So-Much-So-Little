//
//  ActivityTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

@objcMembers
class ActivityTableViewController: UITableViewController {
    
    var activityDataSource: ActivityDataSource!
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var snapshot: UIView!
    var moveIndexPathSource: IndexPath!
    
    
    // MARK: - View Lifecycle
    
    @objc init? (
        coder: NSCoder?,
        activityDataSource: ActivityDataSource_v1
    ) {
        self.activityDataSource = activityDataSource
        
        if let coder = coder {
            super.init(coder: coder)
        }
        else {
            super.init()
        }

        tabBarItem.setIcon(icon: .fontAwesomeSolid(.signLanguage), textColor: .lightGray)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(
            coder: aDecoder,
            activityDataSource: ActivityDataSource_v1())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem.setIcon(icon: .fontAwesomeSolid(.signLanguage), textColor: .lightGray, selectedTextColor: self.view.tintColor )

        navigationItem.hidesBackButton = true
        
        try! activityDataSource.performFetch()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        
        tableView.addGestureRecognizer(longPress)
        refreshControl?.addTarget(self, action: #selector(refreshActivityIndexFromRemote(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationItem.title = "Activity"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createActivity))
        try! activityDataSource.performFetch()
        
        tableView.reloadData()
    }
    
    
    // MARK: - Actions
    
    @IBAction
    func showTimer(_ sender: Any) {
        tabBarController?.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destination as! ActivityDetailFormViewController
            
            destinationVC.activity = activityDataSource.object(at: indexPath)
        }
    }
    
    
    // MARK: - Helpers
    
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

            let activityList = activityDataSource.fetchedObjects!

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
            activityDataSource.save()
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

    func createActivity() {
        performSegue(withIdentifier: "CreateActivityDetail", sender: self)
    }
    
    @objc
    private func refreshActivityIndexFromRemote(_ sender: Any) {
        try! activityDataSource.performFetch()
        performUIUpdatesOnMain {
//            print("\(#function)")
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}


// MARK: - Table View Delegate

extension ActivityTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let activity = activityDataSource.object(at: indexPath)

        if activity.kind == .reference {
            let referenceOption = UIContextualAction(style: .normal, title: "Project") { (action, view, successHandler) in
//                print("Project tapped")
            }
            return UISwipeActionsConfiguration(actions: [referenceOption])
        }
        
        var todayOption: UIContextualAction!
        var completedOption: UIContextualAction!
        
        if activity.today {
            todayOption = UIContextualAction(style: .normal, title: "Postpone") { (action, view, successHandler) in
//                print("\((activityIndexPath as NSIndexPath).row): Postpone tapped")
                activity.today = false
                activity.todayDisplayOrder = 0
                activity.displayOrder = 0
                self.activityDataSource.save()
            }
        }
        else {
            todayOption = UIContextualAction(style: .normal, title: "Today") { (action, view, successHandler) in
//                print("\((activityIndexPath as NSIndexPath).row): Today tapped")
                activity.today = true
                activity.todayDisplayOrder = 0
                self.activityDataSource.save()
            }
        }
        
        if activity.completed {
            completedOption = UIContextualAction(style: .normal, title: "Reactivate") { (action, view, successHandler) in
//                print("\((completedIndexPath as NSIndexPath).row): Reactivate tapped")
                activity.completed = false
                activity.displayOrder = 0
                self.activityDataSource.save()
            }
        }
        else {
            completedOption = UIContextualAction(style: .normal, title: "Complete") { (action, view, successHandler) in
                print("\(indexPath.row): Complete tapped")
                activity.completed = true
                activity.displayOrder = 0
                activity.today = false
                activity.todayDisplayOrder = 0
                self.activityDataSource.save()
            }
        }
        
        return UISwipeActionsConfiguration(actions: [todayOption, completedOption])
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
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.insertRows(at: insertedIndexPaths, with: .fade)
        tableView.deleteRows(at: deletedIndexPaths, with: .fade)
        tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
        
        tableView.endUpdates()
        
        let activityList = activityDataSource.fetchedObjects!
        
        for (i, record) in activityList.enumerated() {
            let i = Activity.DisplayOrderType(i)
            if record.displayOrder != i {
                record.displayOrder = i
            }
        }

//        saveMainContext()
    }
}


// MARK: - Table View Data Source
extension ActivityTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityDataSource.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ActivityCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        configureActivityCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Helpers
    
    func configureActivityCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let activity = activityDataSource.object(at: indexPath)
        let displayOrder = activity.displayOrder
        let name = activity.name
        let actualTimeboxes = activity.actualTimeboxes
        let estimatedTimeboxes = activity.estimatedTimeboxes
        
        cell.textLabel!.text = "\(displayOrder): \(name)"
        cell.detailTextLabel!.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
}
