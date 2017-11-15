//
//  Activity+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/19/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var ckRecordIdName: String?
    @NSManaged public var completed: Bool
    @NSManaged public var completedDate: Date?
    @NSManaged public var deferredTo: String?
    @NSManaged public var deferredToResponseDueDate: Date?
    @NSManaged public var displayOrder: Int16
    @NSManaged public var dueDate: Date?
    @NSManaged public var encodedCKRecord: Data?
    @NSManaged public var estimatedTimeboxes: Int16
    @NSManaged public var info: String?
    @NSManaged public var isSynced: Bool
    @NSManaged public var kind: Kind
    @NSManaged public var name: String
    @NSManaged public var scheduledEnd: Date?
    @NSManaged public var scheduledStart: Date?
    @NSManaged public var today: Bool
    @NSManaged public var todayDisplayOrder: Int16
    @NSManaged public var project: Project?
    @NSManaged public var timeboxes: TimeBoxesType

}

// MARK: Generated accessors for timeboxes
extension Activity {

    @objc(addTimeboxesObject:)
    @NSManaged public func addToTimeboxes(_ value: Timebox)

    @objc(removeTimeboxesObject:)
    @NSManaged public func removeFromTimeboxes(_ value: Timebox)

    @objc(addTimeboxes:)
    @NSManaged public func addToTimeboxes(_ values: TimeBoxesType)

    @objc(removeTimeboxes:)
    @NSManaged public func removeFromTimeboxes(_ values: TimeBoxesType)

}
