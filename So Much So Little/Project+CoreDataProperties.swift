//
//  Project+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/16/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData

extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project");
    }

    @NSManaged public var active: Bool
    @NSManaged public var ckRecordID: String?
    @NSManaged public var completed: Bool
    @NSManaged public var completedDate: Date?
    @NSManaged public var displayOrder: NSNumber
    @NSManaged public var dueDate: Date?
    @NSManaged public var info: String?
    @NSManaged public var name: String
    
    @NSManaged public var activities: Set<Activity>

}

// MARK: Generated accessors for activities
extension Project {

    @objc(addActivitiesObject:)
    @NSManaged public func addToActivities(_ value: Activity)

    @objc(removeActivitiesObject:)
    @NSManaged public func removeFromActivities(_ value: Activity)

    @objc(addActivities:)
    @NSManaged public func addToActivities(_ values: NSSet)

    @objc(removeActivities:)
    @NSManaged public func removeFromActivities(_ values: NSSet)

}
