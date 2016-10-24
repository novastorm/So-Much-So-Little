//
//  ProjectTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class ProjectTableViewController: UITableViewController {
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // MARK: - Core Data Utilities
    
    lazy var fetchedResultsController: NSFetchedResultsController<Project> = {
        let fetchRequest = Project.fetchRequest() as NSFetchRequest<Project>
        fetchRequest.predicate = NSPredicate(format: "completed != YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Project.Keys.DisplayOrder, ascending: true)]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    func saveSharedContext() {
        performUIUpdatesOnMain {
            CoreDataStackManager.saveMainContext()
        }
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "Project"
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createProject))
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
    
    func createProject() {
        performSegue(withIdentifier: "CreateProjectDetail", sender: self)
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


// MARK: - Table View Delegate


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
            let i = i as NSNumber
            if record.displayOrder != i {
                record.displayOrder = i
            }
        }

        saveSharedContext()
    }
}
