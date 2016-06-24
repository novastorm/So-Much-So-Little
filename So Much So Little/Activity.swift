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
        static let Task = "task"
        static let TaskInfo = "task_info"
        static let Complete = "complete"
        static let Reference = "reference"
        static let EstimatedTimeboxes = "estimated_timeboxes"
        static let DeferredTo = "deferred_to"
        static let DeferredToResponseDue = "deferred_to_response_due_date"
        static let ScheduledStart = "scheduled_start"
        static let ScheduledEnd = "scheduled_end"
        static let DueDate = "due_date"
        static let Interruptions = "interruptions"

        static let Milestone = "milestone"
        
        static let Timeboxes = "timeboxes"
        static let ProjectTags = "project_tags"
        static let Roles = "roles"
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
            Keys.EstimatedTimeboxes: 4
        ],
        [
            Keys.Task: "Activity Bravo",
            Keys.EstimatedTimeboxes: 2
        ],
        [
            Keys.Task: "Activity Charlie",
        ]
    ]
    
    static func populateActivityList() {
        let context = CoreDataStackManager.mainContext
        
        for (i, record) in mockActivityList.enumerate() {
            let activity = Activity(task: (record[Keys.Task] as! String), context: context)
            activity.display_order = i
            
            if (record.indexForKey(Keys.EstimatedTimeboxes) != nil) {
                activity.estimated_timeboxes = record[Keys.EstimatedTimeboxes] as? Int
            }
        }
        
        CoreDataStackManager.saveMainContext()
    }
    
    var actual_timeboxes: Int? {
        return timeboxes?.count ?? 0
    }
}
