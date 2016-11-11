//
//  Activity+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/16/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData

extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity");
    }

    @NSManaged public var ckRecordID: Data?
    @NSManaged public var completed: Bool
    @NSManaged public var completedDate: Date?
    @NSManaged public var deferredTo: String?
    @NSManaged public var deferredToResponseDueDate: Date?
    @NSManaged public var displayOrder: NSNumber
    @NSManaged public var dueDate: Date?
    @NSManaged public var estimatedTimeboxes: NSNumber
    @NSManaged public var info: String?
    @NSManaged public var kind: Kind
    @NSManaged public var scheduledEnd: Date?
    @NSManaged public var scheduledStart: Date?
    @NSManaged public var name: String
    @NSManaged public var today: Bool
    @NSManaged public var todayDisplayOrder: NSNumber
    
    @NSManaged public var project: Project?
    @NSManaged public var timeboxes: [Timebox]

}

// MARK: Generated accessors for timeboxes
extension Activity {

    @objc(insertObject:inTimeboxesAtIndex:)
    @NSManaged public func insertIntoTimeboxes(_ value: Timebox, at idx: Int)

    @objc(removeObjectFromTimeboxesAtIndex:)
    @NSManaged public func removeFromTimeboxes(at idx: Int)

    @objc(insertTimeboxes:atIndexes:)
    @NSManaged public func insertIntoTimeboxes(_ values: [Timebox], at indexes: NSIndexSet)

    @objc(removeTimeboxesAtIndexes:)
    @NSManaged public func removeFromTimeboxes(at indexes: NSIndexSet)

    @objc(replaceObjectInTimeboxesAtIndex:withObject:)
    @NSManaged public func replaceTimeboxes(at idx: Int, with value: Timebox)

    @objc(replaceTimeboxesAtIndexes:withTimeboxes:)
    @NSManaged public func replaceTimeboxes(at indexes: NSIndexSet, with values: [Timebox])

    @objc(addTimeboxesObject:)
    @NSManaged public func addToTimeboxes(_ value: Timebox)

    @objc(removeTimeboxesObject:)
    @NSManaged public func removeFromTimeboxes(_ value: Timebox)

    @objc(addTimeboxes:)
    @NSManaged public func addToTimeboxes(_ values: NSOrderedSet)

    @objc(removeTimeboxes:)
    @NSManaged public func removeFromTimeboxes(_ values: NSOrderedSet)

}
