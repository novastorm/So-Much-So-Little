//
//  Activity+CoreDataProperties.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/18/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var completed: CompletedType
    @NSManaged public var completedDate: CompletedDateType?
    @NSManaged public var deferredTo: DeferredToType?
    @NSManaged public var deferredToResponseDueDate: DeferredToResponseDueDateType?
    @NSManaged public var displayOrder: DisplayOrderType
    @NSManaged public var dueDate: DueDateType?
    @NSManaged public var encodedCKRecord: EncodedCKRecordType?
    @NSManaged public var estimatedTimeboxes: EstimatedTimeboxesType
    @NSManaged public var info: InfoType?
    @NSManaged public var kind: Kind
    @NSManaged public var name: NameType
    @NSManaged public var scheduledEnd: ScheduledEndType?
    @NSManaged public var scheduledStart: ScheduledStartType?
    @NSManaged public var today: TodayType
    @NSManaged public var todayDisplayOrder: TodayDisplayOrderType
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
