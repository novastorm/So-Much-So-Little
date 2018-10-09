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
    
    @objc optional func objects() -> [Activity]
    
    @objc optional func object(withId id: NSManagedObjectID) -> Activity
    
    // Store
    func store(with options: ActivityOptions) -> Activity
    
    // Update
    func update(_ activity: Activity)
    
    // Destroy
    func destroy(_ activity: Activity)
}
