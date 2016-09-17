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
    }
    
    typealias CompletedType = Bool
    typealias CompletedDateType = Date
    typealias DisplayOrder = Int
    typealias DueDateType = Date
    typealias InfoType = String
    typealias LabelType = String
    typealias ActiveType = Bool
    
    typealias ActivitiesType = Set<Activity>
    
    static let defaultLabel = "New Project"
    
    convenience init(label: String, context: NSManagedObjectContext) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)

        var label = label
        if label.isEmpty {
            label = type(of: self).defaultLabel
        }
        
        self.label = label
    }
    
    
    convenience init(context: NSManagedObjectContext) {
        self.init(label: "", context: context)
    }

}
