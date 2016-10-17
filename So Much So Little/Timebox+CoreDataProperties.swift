//
//  Timebox+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/16/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import CoreData

extension Timebox {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timebox> {
        return NSFetchRequest<Timebox>(entityName: "Timebox");
    }

    @NSManaged public var completed: Bool
    @NSManaged public var external_interruptions: NSNumber
    @NSManaged public var internal_interruptions: NSNumber
    @NSManaged public var start: Date?
    @NSManaged public var stop: Date?
    @NSManaged public var activity: Activity?

}
