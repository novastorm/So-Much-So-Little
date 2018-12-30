//
//  ActivityCoreDataDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

protocol ActivityCoreDataDataSource {
    
    var fetchedResultsController: NSFetchedResultsController<Activity> { get }
    
    var delegate: NSFetchedResultsControllerDelegate? { get set }
    
    var sections: [NSFetchedResultsSectionInfo]? { get }

    var fetchedObjects: [Activity]? { get }
    
    func performFetch() throws
    
    func save()
    
    func object(at indexPath: IndexPath) -> Activity
    
}
