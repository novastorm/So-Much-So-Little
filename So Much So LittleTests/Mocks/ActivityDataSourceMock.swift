//
//  ActivityDataSourceMock.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

@testable import So_Much_So_Little

@objc
class ActivityDataSourceMock: NSObject, ActivityDataSource {
    
    private class SectionInfo: NSFetchedResultsSectionInfo {
        var name: String
        var indexTitle: String?
        var numberOfObjects: Int
        var objects: [Any]?
        
        init(name: String, indexTitle: String? = nil, numberOfObjects: Int, objects: [Any]? = nil) {
            self.name = name
            self.indexTitle = indexTitle
            self.numberOfObjects = numberOfObjects
            self.objects = objects
        }
    }

    var context: NSManagedObjectContext!

    lazy var activityData: [[Activity]]! = {
        return [
            [
                Activity(
                    insertInto: context,
                    with: ActivityOptions(
                        completed: false,
                        completedDate: nil,
                        deferredTo: nil,
                        deferredToResponseDueDate: nil,
                        displayOrder: 0,
                        dueDate: nil,
                        estimatedTimeboxes: 0,
                        info: nil,
                        kind: .flexible,
                        name: "A 1",
                        scheduledEnd: nil,
                        scheduledStart: nil,
                        today: false,
                        todayDisplayOrder: 0
                    )
                ),
                Activity(
                    insertInto: context,
                    with: ActivityOptions(
                        completed: false,
                        completedDate: nil,
                        deferredTo: nil,
                        deferredToResponseDueDate: nil,
                        displayOrder: 1,
                        dueDate: nil,
                        estimatedTimeboxes: 0,
                        info: nil,
                        kind: .flexible,
                        name: "A 2",
                        scheduledEnd: nil,
                        scheduledStart: nil,
                        today: false,
                        todayDisplayOrder: 0
                    )
                )
            ]
        ]
    }()

    var performFetchWasCalled = false
    
    init(managedObjectContext context: NSManagedObjectContext) {
        self.context = context
    }

    func performFetch() throws {
        performFetchWasCalled = true
    }

    var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    var sections: [NSFetchedResultsSectionInfo]? {
        return activityData.map({
            SectionInfo(
                name: "",
                indexTitle: nil,
                numberOfObjects: $0.count,
                objects: $0)
        })
    }

    var fetchedObjects: [Activity]? {
        return activityData.flatMap { $0 }
    }
    
    func object(at indexPath: IndexPath) -> Activity {
        return activityData[indexPath.section][indexPath.item]
    }
}
