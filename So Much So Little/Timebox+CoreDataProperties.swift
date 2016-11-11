//
//  Timebox+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/16/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData

extension Timebox {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timebox> {
        return NSFetchRequest<Timebox>(entityName: "Timebox");
    }

    @NSManaged public var ckRecordID: Data?
    @NSManaged public var completed: Bool
    @NSManaged public var externalInterruptions: NSNumber
    @NSManaged public var internalInterruptions: NSNumber
    @NSManaged public var start: Date?
    @NSManaged public var stop: Date?
    @NSManaged public var activity: Activity?

}
