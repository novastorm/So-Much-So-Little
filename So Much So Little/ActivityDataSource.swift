//
//  ActivityDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

protocol ActivityDataSource: UITableViewDataSource {
    
    var fetchedObjects: [Activity]? { get }
    
    var delegate: NSFetchedResultsControllerDelegate? { get set }

    func performFetch() throws
    
    func object(at indexPath: IndexPath) -> Activity
    
    func saveMainContext()
}
