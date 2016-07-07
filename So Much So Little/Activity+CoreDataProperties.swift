//
//  Activity+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/7/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Activity {

    @NSManaged var completed: NSNumber?
    @NSManaged var completed_date: NSDate?
    @NSManaged var deferred_to: String?
    @NSManaged var deferred_to_response_due_date: NSDate?
    @NSManaged var display_order: NSNumber?
    @NSManaged var due_date: NSDate?
    @NSManaged var estimated_timeboxes: NSNumber?
    @NSManaged var scheduled_end: NSDate?
    @NSManaged var scheduled_start: NSDate?
    @NSManaged var task: String?
    @NSManaged var task_info: String?
    @NSManaged var today: NSNumber?
    @NSManaged var today_display_order: NSNumber?
    @NSManaged var typeValue: NSNumber?
    @NSManaged var milestone: Milestone?
    @NSManaged var project: Project?
    @NSManaged var roles: NSSet?
    @NSManaged var timeboxes: NSSet?

}
