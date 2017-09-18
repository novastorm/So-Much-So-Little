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
        static let EncodedCKRecord = "encodedCKRecord"
        static let Completed = "completed"
        static let ExternalInterruptions = "externalInterruptions"
        static let InternalInterruptions = "internalInterruptions"
        static let IsSynced = "isSynced"
        static let Start = "start"
        static let Stop = "stop"
        
        static let Activity = "activity"
    }
    
    public typealias EncodedCKRecordType = Data
    public typealias CompletedType = Bool
    public typealias ExternalInterruptionsType = Int16
    public typealias InternalInterruptionsType = Int16
    public typealias StartType = Date
    public typealias StopType = Date
    
    typealias ActivityType = Activity
    
    convenience init(task: String = "", context: NSManagedObjectContext) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
    }

//    override public func didSave() {
//        print("Timebox didSave")
//    }
}
