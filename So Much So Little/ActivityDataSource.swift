//
//  ActivityDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

@objc
protocol ActivityDataSource {

    @objc optional var fetchedResultsController: NSFetchedResultsController<Activity> { get }
    
    var delegate: NSFetchedResultsControllerDelegate? { get set }
    
    var sections: [NSFetchedResultsSectionInfo]? { get }
    
    @objc var objects: [Activity]? { get }
    @objc var fetchedObjects: [Activity]? { get }

    @objc optional func object(withId id: NSManagedObjectID) -> Activity
    
    // Store
    @discardableResult
    func store(with options: ActivityOptions) -> Activity
    
    // Update
    func update(_ activity: Activity)
    
    // Destroy
    func destroy(_ activity: Activity)
    
    func performFetch() throws
    
    func object(at indexPath: IndexPath) -> Activity
    
}
