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
    
    convenience init(context: NSManagedObjectContext, name: String) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        var name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            name = type(of: self).defaultName
        }
        
        self.name = name
    }
    
    convenience init(context: NSManagedObjectContext) {
        self.init(context: context, name: type(of: self).defaultName)
    }

    convenience init(context: NSManagedObjectContext, data: [AnyHashable:Any]) {
        let name = data[Keys.Name] as? NameType ?? ""
        self.init(context: context, name: name)
        
        active = data[Keys.Active] as? ActiveType ?? false
        completed = data[Keys.Completed] as? CompletedType ?? false
        completed_date = data[Keys.CompletedDate] as? CompletedDateType
        display_order = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        due_date = data[Keys.DueDate] as? DueDateType
        info = data[Keys.Info] as? InfoType
    }
}
