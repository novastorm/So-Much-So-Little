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

    @NSManaged var completed: Bool
    @NSManaged var completed_date: Date?
    @NSManaged var deferred_to: String?
    @NSManaged var deferred_to_response_due_date: Date?
    @NSManaged var display_order: NSNumber
    @NSManaged var due_date: Date?
    @NSManaged var estimated_timeboxes: NSNumber
    @NSManaged var kind: Kind
    @NSManaged var scheduled_end: Date?
    @NSManaged var scheduled_start: Date?
    @NSManaged var task: String
    @NSManaged var task_info: String?
    @NSManaged var today: Bool
    @NSManaged var today_display_order: NSNumber?
    @NSManaged var typeValue: NSNumber?
    
    @NSManaged var project: Project?
    @NSManaged var timeboxes: Set<Timebox>?

}
