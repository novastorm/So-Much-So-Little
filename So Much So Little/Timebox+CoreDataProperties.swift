//
//  Timebox+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import CoreData

extension Timebox {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timebox> {
        return NSFetchRequest<Timebox>(entityName: "Timebox");
    }

    @NSManaged public var completed: Bool
    @NSManaged public var external_interruptions: Int32
    @NSManaged public var internal_interruptions: Int32
    @NSManaged public var start: NSDate?
    @NSManaged public var stop: NSDate?
    @NSManaged public var activity: Activity?

}
