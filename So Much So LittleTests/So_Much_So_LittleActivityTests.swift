//
//  So_Much_So_LittleActivityTests.swift
//  So Much So Little Tests
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import XCTest
@testable import So_Much_So_Little
import CoreData

class So_Much_So_LittleActivityTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var persistentStore: NSPersistentStore!
    
    func getFetchedResultsController(fetchRequest: NSFetchRequest) -> NSFetchedResultsController {
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }
    
    let mockActivityList: [String:[String:AnyObject]] = [
        "alpha": [
            Activity.Keys.Task: "Activity Alpha",
            Activity.Keys.EstimatedTimeboxes: 4,
            Activity.Keys.TaskInfo: "Alpha task info",
        ],
        "bravo": [
            Activity.Keys.Task: "Activity Bravo",
            Activity.Keys.EstimatedTimeboxes: 2,
            Activity.Keys.Today: NSNumber(bool: true),
            Activity.Keys.Completed: NSNumber(bool: true)
        ],
        "charlie": [
            Activity.Keys.Task: "Activity Charlie",
        ],
        "delta": [
            Activity.Keys.Task: "Activity Delta",
            Activity.Keys.Completed: NSNumber(bool: true)
        ],
        "echo": [
            Activity.Keys.Task: "Activity Echo",
            Activity.Keys.EstimatedTimeboxes: 4,
            Activity.Keys.Today: NSNumber(bool: true),
        ]
    ]
    
    override func setUp() {
        super.setUp()
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            persistentStore = try storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        }
        catch {
            print(error)
            abort()
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    override func tearDown() {
        managedObjectContext = nil
        try! storeCoordinator.removePersistentStore(persistentStore)
        
        super.tearDown()
    }
    
    func testIncompleteActivityData() {
        let defaultActivity = Activity(context: managedObjectContext)
        XCTAssertEqual(defaultActivity.task, Activity.defaultTask)
        
        let blankActivity = Activity(withTaskNamed: "", context: managedObjectContext)
        XCTAssertEqual(blankActivity.task, Activity.defaultTask)
    }
    
    func testOneActivity() {
        let task = "test activity"
        let activity = Activity(withTaskNamed: task, context: managedObjectContext)
        try! managedObjectContext.save()
        
        let fetchRequest = Activity.fetchRequest

        let fetchedResultsController = getFetchedResultsController(fetchRequest)
        
        try! fetchedResultsController.performFetch()

        XCTAssertEqual(fetchedResultsController.sections?.count, 1)
        XCTAssertEqual(fetchedResultsController.fetchedObjects?.count, 1)

        let fetchedActivity = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Activity

        XCTAssertEqual(fetchedActivity.completed, false, "Default Activity completed should be false")
        XCTAssertNil(fetchedActivity.completed_date, "Default Activity completed_data should be nil")
        XCTAssertNil(fetchedActivity.deferred_to, "Default Activity deferred_to should be nil")
        XCTAssertNil(fetchedActivity.deferred_to_response_due_date, "Default Activity deferred_to_response_due_date should be nil")
        XCTAssertEqual(fetchedActivity.display_order, 0, "Default Activity display_order should be 0")
        XCTAssertNil(fetchedActivity.due_date, "Default Activity due_date should be nil")
        XCTAssertEqual(fetchedActivity.estimated_timeboxes, 0, "Default Activity estimated_timeboxes should be 0")
        XCTAssertNil(fetchedActivity.milestone, "Default Activity milestone should be nil")
        XCTAssertNil(fetchedActivity.project, "Default Activity project should be nil")
        XCTAssertEqual(fetchedActivity.roles, [], "Default Activity roles should be []")
        XCTAssertNil(fetchedActivity.scheduled_start, "Default Activity scheduled_start should be nil")
        XCTAssertNil(fetchedActivity.scheduled_end, "Default Activity scheduled_end should be nil")
        XCTAssertEqual(fetchedActivity.task, task, "Default Activity task should be \"\(task)\"")
        XCTAssertNil(fetchedActivity.task_info, "Default Activity task_info should be nil")
        XCTAssertEqual(fetchedActivity.timeboxes, [], "Default Activity timeboxes should be []")
        XCTAssertEqual(fetchedActivity.today, false, "Default Activity today should be false")
        XCTAssertEqual(fetchedActivity.today_display_order, 0, "Default Activity today_display_order should be 0")
        XCTAssertEqual(fetchedActivity.typeValue, 0, "Default Activity typeValue should be 0")
        
        XCTAssertEqual(fetchedActivity.type, ActivityType.Flexible, "Default Activity type should be .Flexible")
        XCTAssertEqual(fetchedActivity.actual_timeboxes, 0, "Default Activity actual_timeboxes should be 0")
        
        XCTAssertEqual(fetchedActivity, activity)
    }
    
    func testManageActivity() {
        
        let fetchRequest = Activity.fetchRequest
        let fetchedResultsController = getFetchedResultsController(fetchRequest)
        var fetchedActivityList: [Activity] {
            return fetchedResultsController.fetchedObjects as! [Activity]
        }

        // create an activity
        let alphaData = mockActivityList["alpha"]!
        let alpha = Activity(data: alphaData, context: managedObjectContext)
        XCTAssertTrue(alpha.objectID.temporaryID, "Activity should have a temporaryID")
        try! managedObjectContext.save()
        XCTAssertFalse(alpha.objectID.temporaryID, "Activity should not have a temporaryID")
    
        try! fetchedResultsController.performFetch()
        let fetchedActivity = fetchedActivityList[0]
        
        // confirm only one activity
        XCTAssertEqual(fetchedActivityList.count, 1)
        
        // confirm activity is in the results
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        
        // compare activity details
        XCTAssertEqual(fetchedActivity, alpha)
        
        let task = alphaData[Activity.Keys.Task] as! String
        XCTAssertEqual(alpha.task, task, "Activity task should be \"\(task)\"")

        let estimated_timeboxes = alphaData[Activity.Keys.EstimatedTimeboxes] as? Activity.EstimatedTimeboxesType
        XCTAssertEqual(alpha.estimated_timeboxes, estimated_timeboxes, "Activity estimated_timeboxes should be \(estimated_timeboxes)")
        
        // update acitivity details
        alpha.completed = true
        XCTAssertTrue(alpha.completed, "Activity completed should be true")
        
        alpha.today = true
        XCTAssertTrue(alpha.today, "Activity today should be true")
        
        alpha.type = .Reference
        XCTAssertEqual(alpha.type, ActivityType.Reference, "Activity type should be .Reference")
        
        
        // create another activity
        let bravoData = mockActivityList["bravo"]!
        let bravo = Activity(data: bravoData, context: managedObjectContext)
        try! managedObjectContext.save()
        
        try! fetchedResultsController.performFetch()

        XCTAssertEqual(fetchedActivityList.count, 2)
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertTrue(fetchedActivityList.contains(bravo))

        let charlieData = mockActivityList["charlie"]!
        let charlie = Activity(data: charlieData, context: managedObjectContext)

        XCTAssertTrue(charlie.objectID.temporaryID, "Activity Charlie should have temporary ID")
        try! fetchedResultsController.performFetch()
        XCTAssertTrue(charlie.objectID.temporaryID, "Activity Charlie should have temporary ID")
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertTrue(fetchedActivityList.contains(bravo))
        XCTAssertTrue(fetchedActivityList.contains(charlie))

        XCTAssertFalse(bravo.deleted, "Activity bravo should not be in a deleted state")
        managedObjectContext.deleteObject(bravo)

        try! fetchedResultsController.performFetch()

        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertFalse(fetchedActivityList.contains(bravo))
        XCTAssertTrue(fetchedActivityList.contains(charlie))

        XCTAssertTrue(bravo.deleted, "Activity bravo should be in a deleted state")
        try! fetchedResultsController.performFetch()
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertFalse(fetchedActivityList.contains(bravo))
        XCTAssertTrue(fetchedActivityList.contains(charlie))
    }
    
    func testActivityLists() {
        let alphaData = mockActivityList["alpha"]!
        let alpha = Activity(data: alphaData, context: managedObjectContext)
        let bravoData = mockActivityList["bravo"]!
        let bravo = Activity(data: bravoData, context: managedObjectContext)
        let charlieData = mockActivityList["charlie"]!
        let charlie = Activity(data: charlieData, context: managedObjectContext)
        let deltaData = mockActivityList["delta"]!
        let delta = Activity(data: deltaData, context: managedObjectContext)
        let echoData = mockActivityList["echo"]!
        let echo = Activity(data: echoData, context: managedObjectContext)
        
        let activityListFetchRequest = Activity.fetchRequest
        activityListFetchRequest.predicate = NSPredicate(format: "(completed != YES) AND (typeValue != \(ActivityType.Reference.rawValue))")
        activityListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]

        let activityList = getFetchedResultsController(activityListFetchRequest)
        try! activityList.performFetch()
    }
}
