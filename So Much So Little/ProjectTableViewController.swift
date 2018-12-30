//
//  ProjectTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

struct ProjectTableViewControllerDependencies {
    
    var coreDataStack: CoreDataStack!
    
    init(
        coreDataStack: CoreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
        ) {
        self.coreDataStack = coreDataStack
    }
}

class ProjectTableViewController: UITableViewController {
    
    let dependencies: ProjectTableViewControllerDependencies!
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var snapshot: UIView!
    var moveIndexPathSource: IndexPath!
    
    
    // MARK: - Core Data Utilities
    
    lazy var fetchedResultsController: NSFetchedResultsController<Project> = {
        let fetchRequest = Project.fetchRequest() as NSFetchRequest<Project>
        // get Project that are not complete
        fetchRequest.predicate = NSPredicate(format: "completed != YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.DisplayOrder, ascending: true)]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchResultsController
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
    
    
    // MARK: - View Life Cycle
    
    required init?(coder aDecoder: NSCoder?, dependencies: ProjectTableViewControllerDependencies) {
        self.dependencies = dependencies
        if let aDecoder = aDecoder {
            super.init(coder: aDecoder)
        }
        else {
            super.init()
        }
        tabBarItem.setIcon(icon: .fontAwesomeSolid(.chartPie), textColor: .lightGray)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(
            coder: aDecoder,
            dependencies: ProjectTableViewControllerDependencies()
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem.setIcon(icon: .fontAwesomeSolid(.chartPie), textColor: .lightGray, selectedTextColor: self.view.tintColor )

        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPresssGestureRecognizer(_:)))
        
        tableView.addGestureRecognizer(longPress)
        refreshControl?.addTarget(self, action: #selector(refreshProjectIndexFromRemote(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "Project"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createProject))
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProjectDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destination as! ProjectDetailFormViewController
            
            destinationVC.project = fetchedResultsController.object(at: indexPath)
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func showTimer(_ sender: Any) {
        tabBarController?.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Helpers
    
    @objc func longPresssGestureRecognizer(_ sender: AnyObject) {
        
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

            var projectList = fetchedResultsController.fetchedObjects!

            tableView.moveRow(at: moveIndexPathSource, to: indexPath)
            
            let src = moveIndexPathSource.row
            let dst = (indexPath as NSIndexPath).row
            (projectList[dst].displayOrder, projectList[src].displayOrder) = (projectList[src].displayOrder, projectList[dst].displayOrder)
            
            moveIndexPathSource = indexPath
        case.ended:
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
    
    @objc func createProject() {
        performSegue(withIdentifier: "CreateProjectDetail", sender: self)
    }
    
    @objc private func refreshProjectIndexFromRemote(_ sender: Any) {
        performUIUpdatesOnMain {
//            print("\(#function)")
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}


// MARK: - Table View Data Source

extension ProjectTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ProjectCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        configureProjectCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureProjectCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let project = fetchedResultsController.object(at: indexPath)
        let name = project.name
        let displayOrder = project.displayOrder
        
        cell.textLabel!.text = "\(displayOrder): \(name)"
    }
}


// MARK: - Fetched Results Controller Delegate

extension ProjectTableViewController: NSFetchedResultsControllerDelegate {
    
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
        
        let projectList = fetchedResultsController.fetchedObjects!
        
        for (i, record) in projectList.enumerated() {
            let i = Project.DisplayOrderType(i)
            if record.displayOrder != i {
                record.displayOrder = i
            }
        }

//        saveMainContext()
    }
}
