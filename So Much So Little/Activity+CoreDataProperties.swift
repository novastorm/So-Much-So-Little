//
//  Activity+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import CoreData

extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity");
    }

    @NSManaged public var completed: Bool
    @NSManaged public var completed_date: Date?
    @NSManaged public var deferred_to: String?
    @NSManaged public var deferred_to_response_due_date: Date?
    @NSManaged public var display_order: Int32
    @NSManaged public var due_date: Date?
    @NSManaged public var estimated_timeboxes: Int32
    @NSManaged public var kind: Kind
    @NSManaged public var scheduled_end: Date?
    @NSManaged public var scheduled_start: Date?
    @NSManaged public var task: String?
    @NSManaged public var task_info: String?
    @NSManaged public var today: Bool
    @NSManaged public var today_display_order: Int32
    @NSManaged public var project: Project?
    @NSManaged public var timeboxes: Set<Timebox>

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
