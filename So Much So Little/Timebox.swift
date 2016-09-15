//
//  Timebox.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


class Timebox: NSManagedObject {

    struct Keys {
        static let Completed = "completed"
        static let ExternalInterruptions = "external_interruptions"
        static let InternalInterruptions = "internal_interruptions"
        static let Start = "start"
        static let Stop = "stop"

        static let Activity = "activity"
    }
    
    typealias CompletedType = Bool
    typealias ExtenralInterruptionsType = Int
    typealias IntenralInterruptionsType = Int
    typealias StartType = Date
    typealias StopType = Date

    typealias ActivityType = Activity

    convenience init(task: String = "", context: NSManagedObjectContext) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
    }
    
    static var fetchRequest: NSFetchRequest<AnyObject> {
        let fetchRequest = NSFetchRequest(entityName: className)
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
}
