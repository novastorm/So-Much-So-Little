//
//  Activity+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Activity {

    @NSManaged var task: String?
    @NSManaged var complete: NSNumber?
    @NSManaged var estimated_timeboxes: NSNumber?
    @NSManaged var deferred_to: String?
    @NSManaged var deferred_to_response_due_date: NSDate?
    @NSManaged var scheduled_start: NSDate?
    @NSManaged var scheduled_end: NSDate?
    @NSManaged var due_date: NSDate?
    @NSManaged var interruptions: NSNumber?
    @NSManaged var task_info: String?
    @NSManaged var reference: NSNumber?
    @NSManaged var projects: NSSet?
    @NSManaged var roles: NSSet?
    @NSManaged var timeboxes: NSSet?
    @NSManaged var milestone: Milestone?

}
