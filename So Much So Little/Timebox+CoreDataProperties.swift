//
//  Timebox+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/29/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Timebox {

    @NSManaged var completed: NSNumber?
    @NSManaged var start: NSDate?
    @NSManaged var stop: NSDate?
    @NSManaged var interruptions: NSNumber?
    @NSManaged var activity: Activity?

}
