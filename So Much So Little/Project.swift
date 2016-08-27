//
//  Project.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import Foundation

class Project: NSManagedObject {
    
    struct Keys {
        static let Completed = "completed"
        static let CompletedDate = "completed_date"
        static let DisplayOrder = "display_order"
        static let DueDate = "due_date"
        static let Info = "info"
        static let Label = "label"
        static let Active = "active"

        static let Activities = "activities"
        static let Milestones = "milestones"
        static let Parent = "parent"
        static let Roles = "roles"
        static let Subprojects = "subprojects"
    }
    
    typealias CompletedType = Bool
    typealias CompletedDateType = NSDate
    typealias DisplayOrder = Int
    typealias DueDateType = NSDate
    typealias InfoType = String
    typealias LabelType = String
    typealias ActiveType = Bool
    
    typealias ActivitiesType = Set<Activity>
    typealias MilestonesType = Set<Milestone>
    typealias ParentType = Project
    typealias Roles = Set<Role>
    typealias SubprojectsType = Set<Project>
    
    static let defaultLabel = "New Project"
    
    convenience init(label: String = "", context: NSManagedObjectContext) {
        let className = self.dynamicType.className
        let entity = NSEntityDescription.entityForName(className, inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)

        var label = label
        if label.isEmpty {
            label = self.dynamicType.defaultLabel
        }
        
        self.label = label
    }
    
    static var fetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: className)
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
}