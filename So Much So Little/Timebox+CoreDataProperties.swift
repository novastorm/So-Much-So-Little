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

    @NSManaged var completed: Bool
    @NSManaged var external_interruptions: NSNumber
    @NSManaged var internal_interruptions: NSNumber
    @NSManaged var start: Date?
    @NSManaged var stop: Date?
    
    @NSManaged var activity: Activity?

}
