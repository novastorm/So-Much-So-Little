//
//  Timebox+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/18/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


extension Timebox {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timebox> {
        return NSFetchRequest<Timebox>(entityName: "Timebox")
    }

    @NSManaged public var completed: CompletedType
    @NSManaged public var encodedCKRecord: EncodedCKRecordType?
    @NSManaged public var externalInterruptions: ExternalInterruptionsType
    @NSManaged public var internalInterruptions: InternalInterruptionsType
    @NSManaged public var start: StartType?
    @NSManaged public var stop: StopType?
    @NSManaged public var activity: Activity?

}
