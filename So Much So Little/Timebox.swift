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
    typealias StartType = NSDate
    typealias StopType = NSDate

    typealias ActivityType = Activity

    convenience init(task: String = "", context: NSManagedObjectContext) {
        let className = self.dynamicType.className
        let entity = NSEntityDescription.entityForName(className, inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    static var fetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: className)
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
}
