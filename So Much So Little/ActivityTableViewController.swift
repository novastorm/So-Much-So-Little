//
//  ActivityTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class ActivityTableViewController: UITableViewController {
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var activityList: [Activity]!
    var sourceMoveIndexPath: NSIndexPath!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
}
