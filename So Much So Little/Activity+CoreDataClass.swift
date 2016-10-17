//
//  Activity+CoreDataClass.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData


public class Activity: NSManagedObject {
    
    @objc // <- required for Core Data type compatibility
    public enum Kind: Int32, CustomStringConvertible {
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
        
        public var description: String {
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
        static let Info = "info"
        static let Kind = "kind"
        static let ScheduledEnd = "scheduled_end"
        static let ScheduledStart = "scheduled_start"
        static let Name = "name"
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
    typealias InfoType = String
    //    typealias Kind = Kind
    typealias ScheduledEndType = Date
    typealias ScheduledStartType = Date
    typealias NameType = String
    typealias TodayType = Bool
    typealias TodayDisplayOrderType = NSNumber
    
    typealias ProjectType = Project
    typealias TimeBoxesType = Set<Timebox>
    
    static let defaultName = "New Activity"
    
    convenience init(name: String, context: NSManagedObjectContext) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        var name = name
        if name.isEmpty {
            name = type(of: self).defaultName
        }
        
        self.name = name
        kind = .flexible
    }
    
    convenience init(context: NSManagedObjectContext) {
        self.init(name: "", context: context)
    }
    
    var actual_timeboxes: Int {
        return timeboxes.count 
    }
}
