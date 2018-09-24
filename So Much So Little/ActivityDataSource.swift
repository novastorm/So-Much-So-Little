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
    
    var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? { get set }

    var sections: [NSFetchedResultsSectionInfo]? { get }
    var fetchedObjects: [Activity]? { get }
    
    func object(at indexPath: IndexPath) -> Activity

    func performFetch() throws
}
