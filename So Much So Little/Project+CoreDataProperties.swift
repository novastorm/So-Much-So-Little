//
//  Project+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/18/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var active: ActiveType
    @NSManaged public var completed: CompletedType
    @NSManaged public var completedDate: CompletedDateType?
    @NSManaged public var displayOrder: DisplayOrderType
    @NSManaged public var dueDate: DueDateType?
    @NSManaged public var encodedCKRecord: EncodedCKRecordType?
    @NSManaged public var info: InfoType?
    @NSManaged public var name: NameType
    @NSManaged public var activities: ActivitiesType

}

// MARK: Generated accessors for activities
extension Project {

    @objc(addActivitiesObject:)
    @NSManaged public func addToActivities(_ value: Activity)

    @objc(removeActivitiesObject:)
    @NSManaged public func removeFromActivities(_ value: Activity)

    @objc(addActivities:)
    @NSManaged public func addToActivities(_ values: ActivitiesType)

    @objc(removeActivities:)
    @NSManaged public func removeFromActivities(_ values: ActivitiesType)

}
