//
//  ActivityDataSourceMock.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

@testable import So_Much_So_Little

class ActivityDataSourceMock: NSObject, ActivityDataSource {
    
    func saveMainContext() {
        // code
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // code
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    var fetchedObjects: [Activity]? {
        get {
            return [Activity]()
        }
    }
    
    var delegate: NSFetchedResultsControllerDelegate? {
        get {
            return nil
        }
        set {
            print ("Set Activity NSFetchedResultsControllerDelegate")
        }
        
    }

    func performFetch() throws {
        // code
    }
    
    func object(at indexPath: IndexPath) -> Activity {
        return Activity()
    }
}
