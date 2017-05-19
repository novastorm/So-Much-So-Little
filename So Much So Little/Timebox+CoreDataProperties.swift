//
//  Timebox+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/19/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


extension Timebox {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timebox> {
        return NSFetchRequest<Timebox>(entityName: "Timebox")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var encodedCKRecord: Data?
    @NSManaged public var externalInterruptions: Int16
    @NSManaged public var internalInterruptions: Int16
    @NSManaged public var start: Date?
    @NSManaged public var stop: Date?
    @NSManaged public var activity: Activity?

}
