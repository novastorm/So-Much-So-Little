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
    
    @objc // <- required for Core Data type compatibility 
    enum Kind: Int32, CustomStringConvertible {
        case Flexible
        case Deferred
        case Reference
        case Scheduled
        
        static func fromString(string: String) -> Kind? {
            switch string {
            case "Flexible":
                return .Flexible
            case "Deferred":
                return .Deferred
            case "Reference":
                return .Reference
            case "Scheduled":
                return .Scheduled
            default:
                return nil
            }
        }
        
        var description: String {
            switch self {
            case .Flexible: return "Flexible"
            case .Deferred: return "Deferred"
            case .Reference: return "Reference"
            case .Scheduled: return "Scheduled"
            }
        }
    }
    
    struct Keys {
        static let Attendees = "attendees"
        static let Completed = "completed"
        static let CompletedDate = "completed_date"
        static let DeferredTo = "deferred_to"
        static let DeferredToResponseDueDate = "deferred_to_response_due_date"
        static let DisplayOrder = "display_order"
        static let DueDate = "due_date"
        static let EstimatedTimeboxes = "estimated_timeboxes"
        static let Kind = "kind"
        static let ScheduledStart = "scheduled_start"
        static let ScheduledEnd = "scheduled_end"
        static let Task = "task"
        static let TaskInfo = "task_info"
        static let TodayDisplayOrder = "today_display_order"
        static let Today = "today"

        static let Milestone = "milestone"
        static let Project = "project"
        static let Roles = "roles"
        static let Timeboxes = "timeboxes"
    }
    
    typealias Attendees = Set<String>
    typealias CompletedType = Bool
    typealias CompletedDateType = NSDate
    typealias DeferredToType = String
    typealias DeferredToResponseDueDateType = NSDate
    typealias DisplayOrderType = Int
    typealias DueDateType = NSDate
    typealias EstimatedTimeboxesType = Int
//    typealias Kind = Kind
    typealias ScheduledEndType = NSDate
    typealias ScheduledStartType = NSDate
    typealias TaskType = String
    typealias TaskInfoType = String
    typealias TodayType = Bool
    typealias TodayDisplayOrderType = Int
    
    typealias MilestoneType = Milestone
    typealias ProjectType = Project
    typealias RolesType = Set<Role>
    typealias TimeBoxesType = Set<Timebox>
    
    static let defaultTask = "New Activity"

    convenience init(task: String = "", context: NSManagedObjectContext) {
        let className = self.dynamicType.className
        let entity = NSEntityDescription.entityForName(className, inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)

        var task = task
        if task.isEmpty {
            task = self.dynamicType.defaultTask
        }
        
        self.task = task
        kind = .Flexible
    }
    
    static var fetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: className)
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    var actual_timeboxes: Int {
        return timeboxes?.count ?? 0
    }
}
