//
//  Project+CoreDataClass.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData


public class Project: NSManagedObject {
    
    struct Keys {
        static let Active = "active"
        static let Completed = "completed"
        static let CompletedDate = "completed_date"
        static let DisplayOrder = "display_order"
        static let DueDate = "due_date"
        static let Info = "info"
        static let Name = "name"
        
        static let Activities = "activities"
    }
    
    typealias ActiveType = Bool
    typealias CompletedType = Bool
    typealias CompletedDateType = Date
    typealias DisplayOrderType = NSNumber
    typealias DueDateType = Date
    typealias InfoType = String
    typealias NameType = String
    
    typealias ActivitiesType = Set<Activity>
    
    static let defaultName = "New Project"
    
    convenience init(name: String, context: NSManagedObjectContext) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        var name = name
        if name.isEmpty {
            name = type(of: self).defaultName
        }
        
        self.name = name
    }
    
    
    convenience init(context: NSManagedObjectContext) {
        self.init(name: "", context: context)
    }
    
}
