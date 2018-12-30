//
//  CoreDataDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 12/29/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import Foundation

protocol CoreDataDataSource {
    
    associatedtype ResultType: NSFetchRequestResult

    var coreDataStack: CoreDataStack! { get set }

    var fetchedResultsController: NSFetchedResultsController<ResultType> { get }
    
    var delegate: NSFetchedResultsControllerDelegate? { get set }
    
    var sections: [NSFetchedResultsSectionInfo]? { get }

    var fetchedObjects: [ResultType]? { get }
    
    func performFetch() throws
    
    func save()
    
    func object(at indexPath: IndexPath) -> ResultType

}

extension CoreDataDataSource {
    
    var context: NSManagedObjectContext {
        return coreDataStack.mainContext
    }

    var delegate: NSFetchedResultsControllerDelegate? {
        get {
            return fetchedResultsController.delegate
        }
        set {
            fetchedResultsController.delegate = newValue
        }
    }
    
    var sections: [NSFetchedResultsSectionInfo]? {
        return fetchedResultsController.sections
    }

    var fetchedObjects: [ResultType]? {
        return fetchedResultsController.fetchedObjects
    }
    
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }

    func save() {
        coreDataStack.saveMainContext()
    }

    func object(at indexPath: IndexPath) -> ResultType {
        return fetchedResultsController.object(at: indexPath)
    }

}
