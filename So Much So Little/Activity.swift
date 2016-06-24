//
//  Activity.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/16/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import Foundation

class Activity: NSManagedObject {
    
    struct Keys {
        static let Complete = "complete"
        static let CompleteDate = "complete_date"
        static let DeferredTo = "deferred_to"
        static let DeferredToResponseDue = "deferred_to_response_due_date"
        static let DisplayOrder = "display_order"
        static let DueDate = "due_date"
        static let EstimatedTimeboxes = "estimated_timeboxes"
        static let Interruptions = "interruptions"
        static let Reference = "reference"
        static let ScheduledStart = "scheduled_start"
        static let ScheduledEnd = "scheduled_end"
        static let Task = "task"
        static let TaskInfo = "task_info"
        static let TodayDisplayOrder = "today_display_order"
        static let Today = "today"

        static let Milestone = "milestone"
        
        static let Timeboxes = "timeboxes"
        static let ProjectTags = "project_tags"
        static let Roles = "roles"
    }
    
    struct Type {
        typealias Complete = NSNumber
        typealias CompleteDate = NSDate
        typealias DeferredTo = String
        typealias DeferredToResponseDue = NSDate
        typealias DisplayOrder = NSNumber
        typealias DueDate = NSData
        typealias EstimatedTimeboxes = NSNumber
        typealias Interruptions = Int16
        typealias Reference = NSNumber
        typealias ScheduledEnd = NSDate
        typealias ScheduledStart = NSDate
        typealias Task = String
        typealias TaskInfo = String
        typealias Today = NSNumber
        typealias TodayDisplayOrder = Int64
    }
    
    convenience init(task: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Activity", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.task = task
    }
    
    static var fetchRequest: NSFetchRequest {
        return NSFetchRequest(entityName: "Activity")
    }
    
    static let mockActivityList: [[String:AnyObject]] = [
        [
            Keys.Task: "Activity Alpha",
            Keys.EstimatedTimeboxes: 4,
            Keys.Today: NSNumber(bool: true)
        ],
        [
            Keys.Task: "Activity Bravo",
            Keys.EstimatedTimeboxes: 2,
            Keys.Today: NSNumber(bool: true),
            Keys.Complete: NSNumber(bool: true)
        ],
        [
            Keys.Task: "Activity Charlie"
        ],
        [
            Keys.Task: "Activity Delta",
            Keys.Complete: NSNumber(bool: true)
        ],
        [
            Keys.Task: "Activity Echo",
            Keys.EstimatedTimeboxes: 4,
            Keys.Today: NSNumber(bool: true)
        ]
    ]
    
    static func populateActivityList() {
        let context = CoreDataStackManager.mainContext
        
        for (i, record) in mockActivityList.enumerate() {
            let activity = Activity(task: (record[Keys.Task] as! Type.Task), context: context)
            
            if (record.indexForKey(Keys.EstimatedTimeboxes) != nil) {
                activity.estimated_timeboxes = record[Keys.EstimatedTimeboxes] as? Type.EstimatedTimeboxes
            }
            
            if (record.indexForKey(Keys.Today) != nil) {
                activity.today = record[Keys.Today] as? Type.Today
                activity.today_display_order = i
            }
            
            if (record.indexForKey(Keys.Complete) != nil) {
                activity.complete = record[Keys.Complete] as? Type.Complete
            }

            activity.display_order = i
        }
        
        CoreDataStackManager.saveMainContext()
    }
    
    var actual_timeboxes: Int? {
        return timeboxes?.count ?? 0
    }
}
