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
        static let Label = "label"
        static let Info = "info"
        static let Completed = "completed"
        static let DueDate = "due_date"

        static let Activities = "activities"
        static let Milestones = "milestones"
        static let Parent = "parent"
        static let Roles = "roles"
        static let Subprojects = "subprojects"
    }
    
    typealias LabelType = String
    typealias InfoType = String
    typealias CompletedType = Bool
    typealias DueDateType = NSDate
    
    typealias ActivitiesType = Set<Activity>
    typealias MilestonesType = Set<Milestone>
    typealias ParentType = Project
    typealias Roles = Set<Role>
    typealias SubprojectsType = Set<Project>
    
    static let defaultLabel = "New Project"
    
    convenience init(withTask label: String = "", inContext context: NSManagedObjectContext) {
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