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
        case flexible
        case deferred
        case reference
        case scheduled
        
        static func fromString(_ string: String) -> Kind? {
            switch string {
            case "Flexible":
                return .flexible
            case "Deferred":
                return .deferred
            case "Reference":
                return .reference
            case "Scheduled":
                return .scheduled
            default:
                return nil
            }
        }
        
        var description: String {
            switch self {
            case .flexible: return "Flexible"
            case .deferred: return "Deferred"
            case .reference: return "Reference"
            case .scheduled: return "Scheduled"
            }
        }
    }
    
    struct Keys {
        static let Completed = "completed"
        static let CompletedDate = "completed_date"
        static let DeferredTo = "deferred_to"
        static let DeferredToResponseDueDate = "deferred_to_response_due_date"
        static let DisplayOrder = "display_order"
        static let DueDate = "due_date"
        static let EstimatedTimeboxes = "estimated_timeboxes"
        static let Kind = "kind"
        static let ScheduledEnd = "scheduled_end"
        static let ScheduledStart = "scheduled_start"
        static let Task = "task"
        static let TaskInfo = "task_info"
        static let Today = "today"
        static let TodayDisplayOrder = "today_display_order"

        static let Project = "project"
        static let Timeboxes = "timeboxes"
    }
    
    typealias CompletedType = Bool
    typealias CompletedDateType = Date
    typealias DeferredToType = String
    typealias DeferredToResponseDueDateType = Date
    typealias DisplayOrderType = NSNumber
    typealias DueDateType = Date
    typealias EstimatedTimeboxesType = NSNumber
//    typealias Kind = Kind
    typealias ScheduledEndType = Date
    typealias ScheduledStartType = Date
    typealias TaskType = String
    typealias TaskInfoType = String
    typealias TodayType = Bool
    typealias TodayDisplayOrderType = NSNumber
    
    typealias ProjectType = Project
    typealias TimeBoxesType = Set<Timebox>
    
    static let defaultTask = "New Activity"

    convenience init(task: String, context: NSManagedObjectContext) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)

        var task = task
        if task.isEmpty {
            task = type(of: self).defaultTask
        }
        
        self.task = task
        kind = .flexible
    }
    
    convenience init(context: NSManagedObjectContext) {
        self.init(task: "", context: context)
    }
    
    override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return super.fetchRequest()
    }
    
    var actual_timeboxes: Int {
        return timeboxes?.count ?? 0
    }
}
