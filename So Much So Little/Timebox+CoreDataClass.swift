//
//  Timebox+CoreDataClass.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData


public class Timebox: NSManagedObject {
    
    struct Keys {
        static let CKRecordID = "ckRecordID"
        static let Completed = "completed"
        static let ExternalInterruptions = "externalInterruptions"
        static let InternalInterruptions = "internalInterruptions"
        static let Start = "start"
        static let Stop = "stop"
        
        static let Activity = "activity"
    }
    
    typealias CKRecordIDType = Data
    typealias CompletedType = Bool
    typealias ExternalInterruptionsType = NSNumber
    typealias InternalInterruptionsType = NSNumber
    typealias StartType = Date
    typealias StopType = Date
    
    typealias ActivityType = Activity
    
    convenience init(task: String = "", context: NSManagedObjectContext) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
    }

    public override func didSave() {
        print("Timebox didSave")
    }
}
