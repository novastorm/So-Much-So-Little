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
        static let ScheduledStart = "scheduled_start"
        static let ScheduledEnd = "scheduled_end"
        static let Task = "task"
        static let TaskInfo = "task_info"
        static let TodayDisplayOrder = "today_display_order"
        static let Today = "today"
        static let Type = "type"
        static let TypeValue = "typeValue"

        static let Milestone = "milestone"
        
        static let ProjectTags = "project_tags"
        static let Roles = "roles"
        static let Timeboxes = "timeboxes"
    }
    
    typealias CompletedType = Bool
    typealias CompletedDateType = NSDate
    typealias DeferredToType = String
    typealias DeferredToResponseDueType = NSDate
    typealias DisplayOrderType = Int
    typealias DueDateType = NSDate
    typealias EstimatedTimeboxesType = Int
    typealias ScheduledEndType = NSDate
    typealias ScheduledStartType = NSDate
    typealias TaskType = String
    typealias TaskInfoType = String
    typealias TodayType = Bool
    typealias TodayDisplayOrderType = Int
    typealias TypeValueType = NSNumber
    
    typealias MilestoneType = Milestone
    typealias ProjectType = Project
    typealias RolesType = Set<Role>
    typealias TimeBoxesType = Set<Timebox>

    var type: ActivityType {
        get {
            return ActivityType(rawValue: typeValue as! Int)!
        }
        set {
            typeValue = newValue.rawValue
        }
    }
    
    convenience init(withTaskNamed task: String = "", context: NSManagedObjectContext) {
        let className = self.dynamicType.className
        let entity = NSEntityDescription.entityForName(className, inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)

        var task = task
        if task.isEmpty {
            task = "New Activity"
        }
        
        self.task = task
        type = .Flexible
    }
    
    convenience init(data: [String:AnyObject], context: NSManagedObjectContext) {
        let task = data[Keys.Task] as! TaskType
        self.init(withTaskNamed: task, context: context)
        
        completed = data[Keys.Completed] as? CompletedType ?? false
        completed_date = data[Keys.CompletedDate] as? CompletedDateType
        deferred_to = data[Keys.DeferredTo] as? DeferredToType
        deferred_to_response_due_date = data[Keys.DeferredToResponseDue] as? DeferredToResponseDueType
        display_order = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        due_date = data[Keys.DueDate] as? DueDateType
        estimated_timeboxes = data[Keys.EstimatedTimeboxes] as? EstimatedTimeboxesType ?? 0
        scheduled_end = data[Keys.ScheduledEnd] as? ScheduledEndType
        scheduled_start = data[Keys.ScheduledStart] as? ScheduledStartType
        task_info = data[Keys.TaskInfo] as? TaskInfoType
        today = data[Keys.Today] as? TodayType ?? false
        today_display_order = data[Keys.TodayDisplayOrder] as? TodayDisplayOrderType ?? 0
        typeValue = data[Keys.TypeValue] as? TypeValueType ?? ActivityType.Flexible.rawValue
    }
    
    static var fetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: className)
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    var actual_timeboxes: Int {
        return timeboxes.count
    }
}
