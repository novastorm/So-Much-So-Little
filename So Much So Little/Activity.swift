//
//  Activity.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/16/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import Foundation

enum ActivityType: Int {
    case Flexible
    case Deferred
    case Reference
    case Scheduled
}

class Activity: NSManagedObject {
    
    struct Keys {
        static let Completed = "completed"
        static let CompletedDate = "completed_date"
        static let DeferredTo = "deferred_to"
        static let DeferredToResponseDue = "deferred_to_response_due_date"
        static let DisplayOrder = "display_order"
        static let DueDate = "due_date"
        static let EstimatedTimeboxes = "estimated_timeboxes"
        static let Interruptions = "interruptions"
        static let ScheduledStart = "scheduled_start"
        static let ScheduledEnd = "scheduled_end"
        static let Task = "task"
        static let TaskInfo = "task_info"
        static let TodayDisplayOrder = "today_display_order"
        static let Today = "today"
        static let TypeValue = "typeValue"

        static let Milestone = "milestone"
        
        static let ProjectTags = "project_tags"
        static let Roles = "roles"
        static let Timeboxes = "timeboxes"
    }
    
    typealias CompletedType = NSNumber
    typealias CompletedDateType = NSDate
    typealias DeferredToType = String
    typealias DeferredToResponseDueType = NSDate
    typealias DisplayOrderType = NSNumber
    typealias DueDateType = NSData
    typealias EstimatedTimeboxesType = NSNumber
    typealias InterruptionsType = Int16
    typealias ScheduledEndType = NSDate
    typealias ScheduledStartType = NSDate
    typealias TaskType = String
    typealias TaskInfoType = String
    typealias TodayType = NSNumber
    typealias TodayDisplayOrderType = Int64
    typealias TypeType = NSNumber
    
    typealias MilestoneType = Milestone
    typealias ProjectType = Project
    typealias RolesType = Set<Role>
    typealias TimeBoxesType = Set<Timebox>

    var isCompleted: Bool {
        get {
            return completed!.boolValue
        }
        set {
            completed = NSNumber(bool: newValue)
        }
    }
    
    var isToday: Bool {
        get {
            return today!.boolValue
        }
        set {
            today = NSNumber(bool: newValue)
        }
    }
    
    var type: ActivityType {
        get {
            return ActivityType(rawValue: typeValue as! Int)!
        }
        set  {
            typeValue = newValue.rawValue
        }
    }
    
    convenience init(task: String, context: NSManagedObjectContext) {
        let className = self.dynamicType.className
        let entity = NSEntityDescription.entityForName(className, inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.task = task
        self.type = .Flexible
        self.completed = false
        self.isCompleted = false
    }
    
    static var fetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: className)
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
//    static let mockActivityList: [[String:AnyObject]] = [
//        [
//            Keys.Task: "Activity Alpha",
//            Keys.EstimatedTimeboxes: 4,
//            Keys.Today: NSNumber(bool: true)
//        ],
//        [
//            Keys.Task: "Activity Bravo",
//            Keys.EstimatedTimeboxes: 2,
//            Keys.Today: NSNumber(bool: true),
//            Keys.Completed: NSNumber(bool: true)
//        ],
//        [
//            Keys.Task: "Activity Charlie"
//        ],
//        [
//            Keys.Task: "Activity Delta",
//            Keys.Completed: NSNumber(bool: true)
//        ],
//        [
//            Keys.Task: "Activity Echo",
//            Keys.EstimatedTimeboxes: 4,
//            Keys.Today: NSNumber(bool: true)
//        ]
//    ]
    
//    static func populateActivityList() {
//        let context = CoreDataStackManager.mainContext
//        
//        var displayOrder = 0
//        var todayDisplayOrder = 0
//        
//        for record in mockActivityList {
//            let activity = Activity(task: (record[Keys.Task] as! Type.Task), context: context)
//            
//            if (record.indexForKey(Keys.EstimatedTimeboxes) != nil) {
//                activity.estimated_timeboxes = record[Keys.EstimatedTimeboxes] as? Type.EstimatedTimeboxes
//            }
//            
//            if (record.indexForKey(Keys.Completed) != nil) {
//                activity.completed = record[Keys.Completed] as? Type.Completed
//                continue
//            }
//                
//            if (record.indexForKey(Keys.Today) != nil) {
//                activity.today = record[Keys.Today] as? Type.Today
//                activity.today_display_order = todayDisplayOrder
//                todayDisplayOrder += 1
//            }
//            
//            activity.display_order = displayOrder
//            displayOrder += 1
//        }
//        
//        CoreDataStackManager.saveMainContext()
//    }
    
    var actual_timeboxes: Int? {
        return timeboxes?.count ?? 0
    }
}
