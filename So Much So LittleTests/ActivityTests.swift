//
//  So_Much_So_LittleActivityTests.swift
//  So Much So Little Tests
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import XCTest
import CoreData
@testable import So_Much_So_Little


class ActivityTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var persistentStore: NSPersistentStore!
    
    func getFetchedResultsController(_ fetchRequest: NSFetchRequest<Activity>) -> NSFetchedResultsController<Activity> {
        let fetchedResultsController = NSFetchedResultsController<Activity>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }
    
    func getActivityFetchRequest() -> NSFetchRequest<Activity> {
        let fetchRequest = NSFetchRequest<Activity>.init(entityName: "Activity")
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    let mockActivityList: [AnyHashable:[AnyHashable:Any]] = [
        "alpha": [
            Activity.Keys.Name: "Activity Alpha",
            Activity.Keys.EstimatedTimeboxes: 4,
            Activity.Keys.Info: "Alpha info",
        ],
        "bravo": [
            Activity.Keys.Name: "Activity Bravo",
            Activity.Keys.EstimatedTimeboxes: 2,
            Activity.Keys.Today: true,
            Activity.Keys.Completed: true
        ],
        "charlie": [
            Activity.Keys.Name: "Activity Charlie",
        ],
        "delta": [
            Activity.Keys.Name: "Activity Delta",
            Activity.Keys.Completed: true
        ],
        "echo": [
            Activity.Keys.Name: "Activity Echo",
            Activity.Keys.EstimatedTimeboxes: 4,
            Activity.Keys.Today: true,
        ]
    ]
    
    override func setUp() {
        super.setUp()
        
        managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            persistentStore = try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        }
        catch {
            print(error)
            abort()
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    override func tearDown() {
        managedObjectContext = nil
        try! storeCoordinator.remove(persistentStore)
        
        super.tearDown()
    }
    
    func testIncompleteActivityData() {
        let defaultActivity = Activity(context: managedObjectContext)
        XCTAssertEqual(defaultActivity.name, Activity.defaultName)
        
        let blankActivity = Activity(context: managedObjectContext, name: "")
        XCTAssertEqual(blankActivity.name, Activity.defaultName)
    }
    
    func testOneActivity() {
        let name = "test activity"
        let activity = Activity(context: managedObjectContext, name: name)
        try! managedObjectContext.save()
        
        let fetchRequest = getActivityFetchRequest()

        let fetchedResultsController = getFetchedResultsController(fetchRequest)

        try! fetchedResultsController.performFetch()

        XCTAssertEqual(fetchedResultsController.sections?.count, 1)
        XCTAssertEqual(fetchedResultsController.fetchedObjects?.count, 1)

        let fetchedActivity = fetchedResultsController.object(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(fetchedActivity.completed, false, "Default Activity completed should be false")
        XCTAssertNil(fetchedActivity.completedDate, "Default Activity completedDate should be nil")
        XCTAssertNil(fetchedActivity.deferredTo, "Default Activity deferredTo should be nil")
        XCTAssertNil(fetchedActivity.deferredToResponseDueDate, "Default Activity deferredToResponseDueDate should be nil")
        XCTAssertEqual(fetchedActivity.displayOrder, 0, "Default Activity displayOrder should be 0")
        XCTAssertNil(fetchedActivity.dueDate, "Default Activity dueDate should be nil")
        XCTAssertEqual(fetchedActivity.estimatedTimeboxes, 0, "Default Activity estimatedTimeboxes should be 0")
        XCTAssertNil(fetchedActivity.info, "Default Activity info should be nil")
        XCTAssertEqual(fetchedActivity.kind, .flexible, "Default Activity kind should be .flexible")
        XCTAssertEqual(fetchedActivity.name, name, "Default Activity name should be \"\(name)\"")
        XCTAssertNil(fetchedActivity.project, "Default Activity project should be nil")
        XCTAssertNil(fetchedActivity.scheduledEnd, "Default Activity scheduledEnd should be nil")
        XCTAssertNil(fetchedActivity.scheduledStart, "Default Activity scheduledStart should be nil")
        XCTAssertEqual(fetchedActivity.today, false, "Default Activity today should be false")
        XCTAssertEqual(fetchedActivity.todayDisplayOrder, 0, "Default Activity todayDisplayOrder should be 0")
        
        XCTAssertNil(fetchedActivity.project, "Default Activity projects should be nil")
        XCTAssertEqual(fetchedActivity.timeboxes, [], "Default Activity timeboxes should be []")
        XCTAssertEqual(fetchedActivity.actualTimeboxes, 0, "Default Activity actualTimeboxes should be 0")
        
        XCTAssertEqual(fetchedActivity, activity)
    }
    
    func testManageActivity() {
        
        let fetchRequest = getActivityFetchRequest()
        let fetchedResultsController = getFetchedResultsController(fetchRequest)
        var fetchedActivityList: [Activity] {
            return fetchedResultsController.fetchedObjects!
        }

        // create an activity
        let alphaData = mockActivityList["alpha"]!
        let alpha = Activity(context: managedObjectContext, data: alphaData)
        XCTAssertTrue(alpha.objectID.isTemporaryID, "Activity should have a temporaryID")
        try! managedObjectContext.save()
        XCTAssertFalse(alpha.objectID.isTemporaryID, "Activity should not have a temporaryID")
    
        try! fetchedResultsController.performFetch()
        let fetchedActivity = fetchedActivityList.first
        
        // confirm only one activity
        XCTAssertEqual(fetchedActivityList.count, 1)
        
        // confirm activity is in the results
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        
        // compare activity details
        XCTAssertEqual(fetchedActivity, alpha)
        
        let name = alphaData[Activity.Keys.Name] as! String
        XCTAssertEqual(alpha.name, name, "Activity name should be \"\(name)\"")

        let estimatedTimeboxes = alphaData[Activity.Keys.EstimatedTimeboxes] as? Activity.EstimatedTimeboxesType
        XCTAssertEqual(alpha.estimatedTimeboxes, estimatedTimeboxes, "Activity estimatedTimeboxes should be \(estimatedTimeboxes)")
        
        // update acitivity details
        alpha.completed = true
        XCTAssertTrue(alpha.completed, "Activity completed should be true")
        
        alpha.today = true
        XCTAssertTrue(alpha.today, "Activity today should be true")
        
        alpha.kind = .reference
        XCTAssertEqual(alpha.kind, Activity.Kind.reference, "Activity type should be \(Activity.Kind.reference)")
        
        
        // create another activity
        let bravoData = mockActivityList["bravo"]!
        let bravo = Activity(context: managedObjectContext, data: bravoData)
        try! managedObjectContext.save()
        
        try! fetchedResultsController.performFetch()

        XCTAssertEqual(fetchedActivityList.count, 2)
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertTrue(fetchedActivityList.contains(bravo))

        let charlieData = mockActivityList["charlie"]!
        let charlie = Activity(context: managedObjectContext, data: charlieData)

        XCTAssertTrue(charlie.objectID.isTemporaryID, "Activity Charlie should have temporary ID")
        try! fetchedResultsController.performFetch()
        XCTAssertTrue(charlie.objectID.isTemporaryID, "Activity Charlie should have temporary ID")
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertTrue(fetchedActivityList.contains(bravo))
        XCTAssertTrue(fetchedActivityList.contains(charlie))

        XCTAssertFalse(bravo.isDeleted, "Activity bravo should not be in a deleted state")
        managedObjectContext.delete(bravo)
        XCTAssertTrue(bravo.isDeleted, "Activity bravo should be in a deleted state")

        try! fetchedResultsController.performFetch()
        
        XCTAssertTrue(fetchedActivityList.contains(alpha))
        XCTAssertFalse(fetchedActivityList.contains(bravo))
        XCTAssertTrue(fetchedActivityList.contains(charlie))
    }
    
    func testActivityLists() {
        let alphaData = mockActivityList["alpha"]!
        let alpha = Activity(context: managedObjectContext, data: alphaData)
        let bravoData = mockActivityList["bravo"]!
        let bravo = Activity(context: managedObjectContext, data: bravoData)
        let charlieData = mockActivityList["charlie"]!
        let charlie = Activity(context: managedObjectContext, data: charlieData)
        let deltaData = mockActivityList["delta"]!
        let delta = Activity(context: managedObjectContext, data: deltaData)
        let echoData = mockActivityList["echo"]!
        let echo = Activity(context: managedObjectContext, data: echoData)
        
        // test activity list
        
        let activityListFetchRequest = getActivityFetchRequest()
        activityListFetchRequest.predicate = NSPredicate(format: "(completed != YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        activityListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.DisplayOrder, ascending: true)]

        let fetchedResultsController = getFetchedResultsController(activityListFetchRequest)
        try! fetchedResultsController.performFetch()
        
        let activityList = fetchedResultsController.fetchedObjects!
        XCTAssertTrue(activityList.contains(alpha))
        XCTAssertFalse(activityList.contains(bravo))
        XCTAssertTrue(activityList.contains(charlie))
        XCTAssertFalse(activityList.contains(delta))
        XCTAssertTrue(activityList.contains(echo))
        
        // test today's activity list
        
        let todayListFetchRequest = getActivityFetchRequest()
        todayListFetchRequest.predicate = NSPredicate(format: "(today == YES) AND (completed != YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        todayListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.TodayDisplayOrder, ascending: true)]
        
        let todayFetchedResultsController = getFetchedResultsController(todayListFetchRequest)
        try! todayFetchedResultsController.performFetch()
        
        let todayList = todayFetchedResultsController.fetchedObjects!
        XCTAssertFalse(todayList.contains(alpha))
        XCTAssertFalse(todayList.contains(bravo))
        XCTAssertFalse(todayList.contains(charlie))
        XCTAssertFalse(todayList.contains(delta))
        XCTAssertTrue(todayList.contains(echo))
        
        // test completed activity list
        
        let completedListFetchRequest = getActivityFetchRequest()
        completedListFetchRequest.predicate = NSPredicate(format: "(completed == YES) AND (kind != \(Activity.Kind.reference.rawValue))")
        completedListFetchRequest.sortDescriptors = [NSSortDescriptor(key: Activity.Keys.CompletedDate, ascending: true)]
        
        let completedFetchedResultsController = getFetchedResultsController(completedListFetchRequest)
        try! completedFetchedResultsController.performFetch()
        
        let completedList = completedFetchedResultsController.fetchedObjects!
        XCTAssertFalse(completedList.contains(alpha))
        XCTAssertTrue(completedList.contains(bravo))
        XCTAssertFalse(completedList.contains(charlie))
        XCTAssertTrue(completedList.contains(delta))
        XCTAssertFalse(completedList.contains(echo))
    }
}
