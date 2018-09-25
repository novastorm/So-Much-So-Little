//
//  ActivityDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

protocol ActivityDataSource {

    func performFetch() throws

    var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? { get set }

    var sections: [NSFetchedResultsSectionInfo]? { get }
    
    // Index
    var fetchedObjects: [Activity]? { get }
    
    // Show
    func object(at indexPath: IndexPath) -> Activity
    
    // Create
    func create(with options: ActivityOptions) -> Activity
    
    // Update
    func update(activity: Activity)
    
    // Delete
    func delete(activity: Activity)
}
