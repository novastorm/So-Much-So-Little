//
//  Project+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/19/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var active: Bool
    @NSManaged public var ckRecordIdName: String?
    @NSManaged public var completed: Bool
    @NSManaged public var completedDate: Date?
    @NSManaged public var displayOrder: Int16
    @NSManaged public var dueDate: Date?
    @NSManaged public var encodedCKRecord: Data?
    @NSManaged public var info: String?
    @NSManaged public var isSynced: Bool
    @NSManaged public var name: String
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
